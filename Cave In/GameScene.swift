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
        let maxHealth = ballCount + 10
        let minHealth = ballCount
        let totalBlocks = arc4random_uniform(8) + 1
        print(totalBlocks)
        var blocksSpawned = 0
        var x = 0
        while(blocksSpawned < totalBlocks) {
            let spawnChance = arc4random_uniform(8)+1
            print("spawnChance: " + String(spawnChance))
            if spawnChance <= totalBlocks && !isDuplicate(at: x) {
                print("x " + String(x))
                spawnBlock(at: x, min: minHealth, max: maxHealth)
                blocksSpawned += 1
            }
            x = (x+1) % 8
        }
        
    }
    
    func spawnBlock(at x: Int, min minHealth: Int, max maxHealth: Int) {
        let block = Block(color: UIColor.blue, size: CGSize(width: 50, height: 50))
        block.gridX = x
        block.updatePosition(inside: frame)
        block.zPosition = 5
        block.health = Int(arc4random_uniform(UInt32(maxHealth-minHealth+1))) + minHealth
        block.initLabel()
        blocks.append(block)
        addChild(block)
    }
    
    func isDuplicate(at x: Int) -> Bool{
        for block in blocks {
            if block.gridY == 0 && block.gridX == x {
                return true
            }
        }
        
        return false
    }
    
    func spawnBall() {
        let ball = Ball(color: UIColor.red, size: CGSize(width: 20, height: 20))
        ball.position = CGPoint(x: startPosition, y: 10)
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
            var flipXVel = false
            var flipYVel = false
            
            if ball.frame.maxX >= frame.maxX || ball.frame.minX <= 0 {
                flipXVel = true
            }
            
            if ball.frame.maxY >= frame.maxY {
                flipYVel = true
            }
            
            for block in blocks {
                if ball.frame.intersects(block.frame) {
                    block.health -= 1
                    block.updateLabel()
                    //collision is very buggy
                    if ball.position.y > block.frame.maxY{
                        flipYVel = true
                        ball.position.y = block.frame.maxY + ball.frame.height/2
                    }
                    if ball.position.y < block.frame.minY {
                        flipYVel = true
                        ball.position.y = block.frame.minY - ball.frame.height/2
                    }
                    
                    if ball.position.x > block.frame.maxX {
                        flipXVel = true
                        ball.position.x = block.frame.maxX + ball.frame.height/2
                    }
                    if ball.position.x < block.frame.minX {
                        flipXVel = true
                        ball.position.x = block.frame.minY - ball.frame.height/2
                    }
                    if block.health == 0 {
                        block.removeFromParent()
                        if let index = blocks.index(of: block) {
                            blocks.remove(at: index)
                        }
                    }
                }
            }
            
            if flipXVel {
                ball.xVel *= -1
            }
            if flipYVel {
                ball.yVel *= -1
            }
            
            if ball.frame.minY <= 0 {
                ball.xVel = 0
                ball.yVel = 0
                ball.position.y = 10
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
