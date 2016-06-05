//
//  global.swift
//  SpriteKitSimpleGame
//
//  Created by David Park on 6/4/16.
//  Copyright © 2016 David Park. All rights reserved.
//

import Foundation

class Main {
    var scoreCount = 0
    init(scoreCount: Int) {
        self.scoreCount = scoreCount
    }
}

var mainInstance = Main(scoreCount:0)