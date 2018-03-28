//
//  PowerUp.swift
//  Cave In
//
//  Created by Marist User on 3/23/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {
    var gridX = 0
    var gridY = 0
    var type = powerUpType.newBall
    
    enum powerUpType {
        case newBall
    }
    
    func updatePosition(inside gameFrame: CGRect) {
        position.x = CGFloat(52 * gridX + 25)
        position.y = gameFrame.maxY - CGFloat(52 * gridY + 25)
    }
}
