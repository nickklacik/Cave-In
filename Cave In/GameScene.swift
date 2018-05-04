//
//  GameScene.swift
//  Cave In
//
//  Created by Marist User on 2/27/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameState {
    case waiting
    case running
    case ended
    case gameOver
}

struct Score {
    static var hiScore: UInt32 = 0
    static var score: UInt32 = 0
}

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
    var state = GameState.ended
    var targeter : SKShapeNode = SKShapeNode()
    var wait = false
    var ballLabel = SKLabelNode()
    var roundLabel = SKLabelNode()
    //Add black bar for label
    
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
        
        let barSize = CGSize(width: frame.width, height: 30)
        let bottomBar = SKSpriteNode(color: UIColor.black, size: barSize)
        bottomBar.zPosition = 20
        bottomBar.position = CGPoint(x: xMid, y: 15)
        addChild(bottomBar)

        roundLabel.text = "Round: 1"
        roundLabel.fontName = "Arial"
        roundLabel.fontSize = 18
        roundLabel.zPosition = 25
        roundLabel.position = CGPoint(x: 40, y: 8)
        addChild(roundLabel)
        
        ballLabel.text = "Balls: 1"
        ballLabel.fontName = "Arial"
        ballLabel.fontSize = 18
        ballLabel.zPosition = 25
        ballLabel.position = CGPoint(x: frame.maxX - 60, y: 8)
        addChild(ballLabel)
        
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

    // Randomly generates blocks on the top row
    func spawnBlocks() {
        let maxHealth = ballCount + 10
        let minHealth = ballCount
        let maxBlocks: UInt32 = ((9*round*round) / (round*round + 5*round))
        let totalBlocks = arc4random_uniform(maxBlocks) + 1
        print(totalBlocks)
        var blocksSpawned = 0
        var x = 0
        while blocksSpawned < totalBlocks {
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

    // Creates a new Block at a given X position and randomly calculates its health
    func spawnBlock(at gridX: Int, min minHealth: Int, max maxHealth: Int) {
        let block = Block(color: UIColor.blue, size: CGSize(width: 50, height: 50))
        block.gridX = gridX
        block.updatePosition(inside: frame)
        block.zPosition = 5
        block.health = Int(arc4random_uniform(UInt32(maxHealth-minHealth+1))) + minHealth
        block.initLabel()
        block.initTextures()
        blocks.append(block)
        addChild(block)
    }

    // Randomly creates new powerUp at any available locations
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

    // Creates a New Ball PowerUp at a given x position
    func spawnNewBallPowerUp(at gridX: Int) {
        let powerUp = PowerUp(color: UIColor.green, size: CGSize(width: 20, height: 20))
        powerUp.type = .newBall
        powerUp.gridX = gridX
        powerUp.zPosition = 5
        powerUp.updatePosition(inside: frame)
        addChild(powerUp)
        powerUps.append(powerUp)
    }

    // Checks if the x position in the top row is empty
    func isEmpty(at gridX: Int) -> Bool {
        for block in blocks {
            if block.gridY == 0 && block.gridX == gridX {
                return false
            }
        }

        for powerUp in powerUps {
            if powerUp.gridY == 0 && powerUp.gridX == gridX {
                return false
            }
        }

        return true
    }

    // Creates a New Ball
    func spawnBall() {
        let ball = Ball(color: UIColor.red, size: CGSize(width: 30, height: 30))
        ball.position = CGPoint(x: startPosition, y: 15)
        ball.zPosition = 10
        ball.xVel = startXVel
        ball.yVel = startYVel
        ball.zRotation = atan2(startYVel, startXVel)
        ball.initAnimationFrames()
        ball.animateBall()
        addChild(ball)
        balls.append(ball)
    }

    // Moves Balls and checks for collision
    func updateBalls() {
        var isBallMoving = false
        for ball in balls {
            ball.position.x += ball.xVel
            ball.position.y += ball.yVel

            powerUpCollision(with: ball)
            blockCollision(with: ball)

            ball.zRotation = atan2(ball.yVel, ball.xVel)

            if ball.frame.minY <= 0 {
                ball.xVel = 0
                ball.yVel = 0
                ball.position.y = 15
            }

            if ball.xVel != 0 && ball.yVel != 0 {
                isBallMoving = true
            }
        }

        if !isBallMoving {
            state = .ended
        }
    }
    
    // Updates every block in the Scene
    func updateBlocks() {
        for block in blocks {
            block.updateTexture()
        }
    }

    // Checks if a given ball collides with any powerUps
    func powerUpCollision(with ball: Ball) {
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
    }

    // Checks if a given ball collides with any blocks and updates its velocity
    func blockCollision(with ball: Ball) {
        var flipXVel = false
        var flipYVel = false

        // Check if the ball has reached the edge of the screen
        if ball.frame.maxX >= frame.maxX || ball.frame.minX <= 0 {
            flipXVel = true
        }
        if ball.frame.maxY >= frame.maxY {
            flipYVel = true
        }

        for block in blocks {
            if ball.intersects(block) {
                block.health -= 1
                block.updateLabel()
                run(SKAction.playSoundFileNamed("BlockHit.wav", waitForCompletion: false))
                
                // Uses the balls velocity to determine how the ball hit the block and how it should bounce
                if ball.xVel == 0 {
                    flipYVel = true
                }
                else if ball.yVel == 0 {
                    flipXVel = true
                }
                else if ball.xVel > 0 {
                    let m = ball.yVel/ball.xVel
                    var dy = CGFloat()
                    if ball.yVel > 0 {
                        dy = block.frame.minY - ball.frame.maxY
                    }
                    else {
                        dy = block.frame.maxY - ball.frame.minY
                    }
                    let dx = dy/m
                    if ball.frame.maxX + dx > block.frame.minX {
                        flipYVel = true
                    }
                    else {
                        flipXVel = true
                    }
                }
                else {
                    let m = ball.yVel/ball.xVel
                    var dy = CGFloat()
                    if ball.yVel > 0 {
                        dy = block.frame.minY - ball.frame.maxY
                    }
                    else {
                        dy = block.frame.maxY - ball.frame.minY
                    }
                    let dx = dy/m
                    if ball.frame.minX + dx > block.frame.maxX {
                        flipXVel = true
                    }
                    else {
                        flipYVel = true
                    }
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
    }

    // Start the next round of the game
    func nextRound() {
        state = .waiting
        round += 1
        roundLabel.text = "Round: \(round)"
        for ball in balls {
            ball.removeFromParent()
            if let index = balls.index(of: ball) {
                balls.remove(at: index)
            }
        }
        for block in blocks {
            block.gridY += 1
            //Check if any Blocks have reached the bottom of the screen
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

    // Called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        updateBlocks()
        if state == .running {
            if balls.count < ballCount && !wait {
                spawnBall()
                wait = true
            } else {
                wait = false
            }
            updateBalls()
        } else if state == .ended {
            nextRound()
        } else if state == .gameOver {
            gameOver()
        }
    }

    func gameOver() {
        // Save score
        Score.score = round
        if Score.score > Score.hiScore {
            Score.hiScore = Score.score
        }
        goNext(scene: GameOverScene()) // Go to Game Over Scene
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
                addChild(targeter)
                targeter.strokeColor = UIColor.white
                targeter.zPosition = 8
            } else if panGesture.state == .changed {
                let currentLocation = panGesture.location(in: panGesture.view)
                let dY = currentLocation.y - panOrigin.y
                let dX = panOrigin.x - currentLocation.x
                let path = CGMutablePath()
                path.move(to: CGPoint(x: startPosition, y: 0))
                path.addLine(to: CGPoint(x: startPosition + dX, y: dY))
                targeter.path = path
            } else if panGesture.state == .ended {
                // shoot ball
                let panEndLocation = panGesture.location(in: panGesture.view)
                let dY = panEndLocation.y - panOrigin.y
                let dX = panOrigin.x - panEndLocation.x
                let theta = atan2(dY, dX)
                startXVel = Ball.maxSpeed * cos(theta)
                startYVel = Ball.maxSpeed * sin(theta)
                state = .running
                targeter.removeFromParent()
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
        }
    }
}
