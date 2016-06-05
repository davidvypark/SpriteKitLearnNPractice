//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by David Park on 6/2/16.
//  Copyright © 2016 David Park. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.whiteColor()
        
        let message = won ? "(っ◕‿◕)っ You Won! " : "(ಥ﹏ಥ) Score: \(mainInstance.scoreCount)" //the "won"  condition message will never be triggered because I turned off the win condition
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)

        
        
        runAction(SKAction.sequence([SKAction.waitForDuration(3.0), SKAction.runBlock(){
            mainInstance.scoreCount = 0
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let scene = GameScene(size: size)
            self.view?.presentScene(scene, transition:reveal)
            }
        ]))
    }
    
    required init(coder aDecoder:NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}
