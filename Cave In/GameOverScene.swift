//
//  GameOverScene.swift
//  CaveIn
//
//  Created by Nick on 4/19/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        let background = SKSpriteNode(color: UIColor.black, size: frame.size)
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        let tapMethod = #selector(SplashScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        let title = SKLabelNode(fontNamed: "Arial")
        title.text = "Game Over"
        title.fontSize = 64
        title.fontColor = SKColor.white
        title.position = CGPoint(x: xMid, y: yMid + 200)
        title.zPosition = 10
        addChild(title)
        
        let score = SKLabelNode(fontNamed: "Arial")
        score.text = "Score: \(Score.score)"
        score.fontSize = 48
        score.fontColor = SKColor.white
        score.position = CGPoint(x: xMid, y: yMid)
        score.zPosition = 10
        addChild(score)
        
        let hiScore = SKLabelNode(fontNamed: "Arial")
        hiScore.text = "HiScore: \(Score.hiScore)"
        hiScore.fontSize = 32
        hiScore.fontColor = SKColor.white
        hiScore.position = CGPoint(x: xMid, y: yMid - 100)
        hiScore.zPosition = 10
        addChild(hiScore)
        
        let start = SKLabelNode(fontNamed: "Arial")
        start.text = "Tap to return to splash screen"
        start.fontSize = 24
        start.fontColor = SKColor.white
        start.position = CGPoint(x: xMid, y: (yMid - 300))
        start.zPosition = 10
        addChild(start)
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        goNext(scene: SplashScene())
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
            let reveal = SKTransition.crossFade(withDuration: 2)
            view.presentScene(scene, transition: reveal)
            view.ignoresSiblingOrder = true        }
    }
}
