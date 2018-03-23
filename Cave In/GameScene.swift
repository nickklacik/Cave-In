//
//  GameScene.swift
//  Cave In
//
//  Created by Marist User on 2/27/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var ballCount = 1
    var startPosition: CGFloat = 0
    var blocks: [Block] = []
    var balls: [Ball] = []
    var startXVel: CGFloat = 0.0
    var startYVel: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        print(frame.size)
        background.position = CGPoint(x: xMid, y: yMid)
        background.size = frame.size
        print(background.zPosition)
        addChild(background)
        
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        startGame()
    }
    
    func startGame() {
        ballCount = 1
        startPosition = frame.midX
        spawnBlocks();
    }
    
    func spawnBlocks() {
        
    }
    
    func spawnBall() {
        let ball = Ball(color: UIColor.red, size: CGSize(width: 30, height: 30))
        ball.position = CGPoint(x: startPosition, y: 15)
        ball.zPosition = 10
        ball.xVel = startXVel
        ball.yVel = startYVel
        addChild(ball)
        balls.append(ball)
    }
    
    func updateBalls() {
        for ball in balls {
            ball.position.x += ball.xVel
            ball.position.y += ball.yVel
            
            if ball.frame.maxX >= frame.maxX || ball.frame.minX <= 0 {
                ball.xVel *= -1
            }
            
            if ball.frame.maxY >= frame.maxY {
                ball.yVel *= -1
            }
            
            if ball.frame.minY <= 0 {
                ball.xVel = 0
                ball.yVel = 0
                ball.position.y = 15
            }
        }
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        let tapLocation = tapGesture.location(in: tapGesture.view)
        print(tapLocation)
        let dY = frame.maxY - tapLocation.y
        let dX = tapLocation.x - startPosition
        let theta = atan(dX/dY)
        startXVel = Ball.maxSpeed * sin(theta)
        startYVel = Ball.maxSpeed * cos(theta)
        spawnBall()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updateBalls()
    }
}
