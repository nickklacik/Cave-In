//
//  Ball.swift
//  Cave In
//
//  Created by Marist User on 3/23/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit

class Ball: SKSpriteNode {
    static let maxSpeed: CGFloat = 30.0
    var xVel: CGFloat = 0.0
    var yVel: CGFloat = 0.0
    let flyingAtlas = SKTextureAtlas(named: "BallFlying")
    var flyingFrames: [SKTexture] = []

    func initAnimationFrames() {
        for i in 0..<flyingAtlas.textureNames.count {
            let name = "ball_flying000\(i)"
            flyingFrames.append(flyingAtlas.textureNamed(name))
        }
    }

    func animateBall() {
        let animate = SKAction.animate(with: flyingFrames, timePerFrame: 0.1, resize: false, restore: true)
        run(SKAction.repeatForever(animate))
    }
}
