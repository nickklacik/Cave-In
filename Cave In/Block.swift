//
//  Block.swift
//  Cave In
//
//  Created by Marist User on 3/23/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit

class Block: SKSpriteNode {
    var health = 0
    var maxHealth = 0
    var gridX = 0
    var gridY = 0
    var healthLabel = SKLabelNode(fontNamed: "Arial")
    var textures : [SKTexture] = []

    /*
        grid coords -> real coords
        f(x,y) = (52x + 25, maxY-(52y + 25))

        gridX = 0 -> x = 25
                        +52
                1 -> x = 77
                        +52
                2 -> x = 129
                        etc...
     */
    func updatePosition(inside gameFrame: CGRect) {
        position.x = CGFloat(52 * gridX + 25)
        position.y = gameFrame.maxY - CGFloat(52 * gridY + 25)
    }

    func initLabel() {
        addChild(healthLabel)
        healthLabel.fontSize = 32
        healthLabel.fontColor = UIColor.white
        healthLabel.zPosition = 6
        healthLabel.horizontalAlignmentMode = .center
        healthLabel.verticalAlignmentMode = .center
        updateLabel()
    }
    
    func initTextures() {
        for i in 0...4 {
            textures.append(SKTexture(imageNamed: "Block000\(i)"))
        }
        maxHealth = health
        updateTexture()
    }

    func updateLabel() {
        healthLabel.text = String(health)
    }
    
    func updateTexture() {
        if health > 4*maxHealth/5 {
            texture = textures[0]
        }
        else if health > 3*maxHealth/5 {
            texture = textures[1]
        }
        else if health > 2*maxHealth/5 {
            texture = textures[2]
        }
        else if health > 1*maxHealth/5 {
            texture = textures[3]
        }
        else {
            texture = textures[4]
        }
    }
}
