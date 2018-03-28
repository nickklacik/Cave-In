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
    var powerUps: [PowerUp] = []
    var startXVel: CGFloat = 0.0
    var startYVel: CGFloat = 0.0
    var panOrigin = CGPoint()
    var round: UInt32 = 1
    var state = gameState.ended
    
    enum gameState {
        case waiting
        case running
        case ended
        case gameOver
    }
    
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
        
        let panMethod = #selector(GameScene.handlePan(panGesture:))
        let panGesture = UIPanGestureRecognizer(target: self, action: panMethod)
        view.addGestureRecognizer(panGesture)
        
        startGame()
    }
    
    func startGame() {
        state = .waiting
        ballCount = 1
        round = 1
        startPosition = frame.midX
        spawnBlocks()
        spawnPowerUps()
    }
    
    func spawnBlocks() {
        let maxHealth = ballCount + 10
        let minHealth = ballCount
        let maxBlocks: UInt32 = ((9*round*round) / (round*round + 5*round))
        let totalBlocks = arc4random_uniform(maxBlocks) + 1
        print(totalBlocks)
        var blocksSpawned = 0
        var x = 0
        while(blocksSpawned < totalBlocks) {
            let spawnChance = arc4random_uniform(8)+1
            print("spawnChance: " + String(spawnChance))
            if spawnChance <= totalBlocks && isEmpty(at: x) {
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
    
    func spawnPowerUps() {
        for x in 0..<8 {
            if isEmpty(at: x) {
                let spawnChance = arc4random_uniform(100)
                if spawnChance < 25 {
                    spawnNewBallPowerUp(at: x)
                }
            }
        }
    }
    
    func spawnNewBallPowerUp(at x: Int) {
        let powerUp = PowerUp(color: UIColor.green, size: CGSize(width: 20, height: 20))
        powerUp.type = .newBall
        powerUp.gridX = x
        powerUp.zPosition = 5
        powerUp.updatePosition(inside: frame)
        addChild(powerUp)
        powerUps.append(powerUp)
    }
    
    
    func isEmpty(at x: Int) -> Bool {
        for block in blocks {
            if block.gridY == 0 && block.gridX == x {
                return false
            }
        }
        
        for powerUp in powerUps {
            if powerUp.gridY == 0 && powerUp.gridX == x {
                return false
            }
        }
        
        return true
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
        var isBallMoving = false
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
            
            for powerUp in powerUps {
                if ball.intersects(powerUp) {
                    //activate Power Up
                    if powerUp.type == .newBall {
                        ballCount += 1
                    }
                    
                    powerUp.removeFromParent()
                    if let index = powerUps.index(of: powerUp) {
                        powerUps.remove(at: index)
                    }
                }
            }
            
            for block in blocks {
                if ball.intersects(block) {
                    block.health -= 1
                    block.updateLabel()
                    //collision is very buggy
                    if ball.position.y > block.frame.maxY{
                        flipYVel = true
                    }
                    if ball.position.y < block.frame.minY {
                        flipYVel = true
                    }
                    
                    if ball.position.x > block.frame.maxX {
                        flipXVel = true
                    }
                    if ball.position.x < block.frame.minX {
                        flipXVel = true
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
            
            if ball.xVel != 0 && ball.yVel != 0 {
                isBallMoving = true
            }
        }
        
        if !isBallMoving {
            state = .ended
        }
    }
    
    func nextRound() {
        state = .waiting
        round += 1
        for ball in balls {
            ball.removeFromParent()
            if let index = balls.index(of: ball) {
                balls.remove(at: index)
            }
        }
        for block in blocks {
            block.gridY += 1
            if block.gridY == 13 {
                state = .gameOver
            }
            block.updatePosition(inside: frame)
        }
        for powerUp in powerUps {
            powerUp.gridY += 1
            powerUp.updatePosition(inside: frame)
        }
        spawnBlocks()
        spawnPowerUps()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if state == .running {
            if balls.count < ballCount {
                spawnBall()
            }
            updateBalls()
        }
        else if state == .ended {
            nextRound()
        }
        else if state == .gameOver {
            gameOver()
        }
    }
    
    func gameOver() {
        goNext(scene: SplashScene()) // Go Back to the Splash Screen
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
//        let tapLocation = tapGesture.location(in: tapGesture.view)
//        print(tapLocation)
//        let dY = frame.maxY - tapLocation.y
//        let dX = tapLocation.x - startPosition
//        let theta = atan(dX/dY)
//        startXVel = Ball.maxSpeed * sin(theta)
//        startYVel = Ball.maxSpeed * cos(theta)
//        spawnBall()
    }
    
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        if state == .waiting {
            if panGesture.state == .began {
                panOrigin = panGesture.location(in: panGesture.view)
                //Create targeter
            }
            else if panGesture.state == .changed {
                //Update targeter
            }
            else if panGesture.state == .ended {
                // shoot ball
                let panEndLocation = panGesture.location(in: panGesture.view)
                let dY = panEndLocation.y - panOrigin.y
                let dX = panOrigin.x - panEndLocation.x
                let theta = atan(dX/dY)
                startXVel = Ball.maxSpeed * sin(theta)
                startYVel = Ball.maxSpeed * cos(theta)
                //spawnBall()
                state = .running
            }
        }
    }
    
    func goNext(scene: SKScene) {
        // view is an SKView? so we have to check
        if let view = self.view {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            // Adjust the size of the scene to match the view
            let width = view.bounds.width
            let height = view.bounds.height
            scene.size = CGSize(width: width, height: height)
            // let reveal = SKTransition.reveal(with: .down, duration:5)
            let reveal = SKTransition.crossFade(withDuration: 5)
            view.presentScene(scene, transition: reveal)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
