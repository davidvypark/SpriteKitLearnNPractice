//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by David Park on 6/2/16.
//  Copyright (c) 2016 David Park. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let Monster      : UInt32 = 0b1             // 1
    static let Projectile   : UInt32 = 0b10            // 2
}


func + (left:CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left:CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint{
    func length() -> CGFloat{
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint{
        return self / length()
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0
    //var scoreCount = 0                             // I dont need this anymore scoreCount on global.swift
    var scoreLabel = SKLabelNode()                          // Declaring score
    let scoreLabelName = "scoreLabel"                       // label variables
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addMonster),SKAction.waitForDuration(1.0)])))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        //implementation of score label    <--------------------------------------------------------
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.name = scoreLabelName
        scoreLabel.fontSize = 80
        scoreLabel.fontColor = SKColor.blackColor()
        scoreLabel.text = "\(mainInstance.scoreCount)"
        print(size.height)
        scoreLabel.position = CGPointMake(frame.size.width / 2, frame.size.height / 14)
        self.addChild(scoreLabel)
        
    }
    
    func updateScoreLabel(){
        mainInstance.scoreCount += 1
        scoreLabel.text = "\(mainInstance.scoreCount)"
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    func addMonster(){
        
        let monster = SKSpriteNode(imageNamed: "monster")
        
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        addChild(monster)
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true                                              //projectile will not be controlled
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile                //set to above bitmask
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster                //indicates objects of this category should notify when intersects
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None                     //.None is no bounce off upon collision
        projectile.physicsBody?.usesPreciseCollisionDetection = true                        //make true for fast moving objects more precise
    
        
        let offset = touchLocation - projectile.position
        
        if (offset.x < 0) { return }                                   //what does this return in curly brackets mean?
        
        addChild(projectile)
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        runAction(SKAction.playSoundFileNamed("pew-pew-lei", waitForCompletion: false))
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed += 1
        
        updateScoreLabel()
        
        //if (monstersDestroyed > 30) {
        //    let reveal = SKTransition.flipHorizontalWithDuration(0.5)         //This is a potential
        //    let gameOverScene = GameOverScene(size: self.size, won:true)      //win condition that
        //    self.view?.presentScene(gameOverScene, transition: reveal)        //I'm not using right now
        //}
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyB
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)){
            
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
    
    
    }

    
    
    
}














