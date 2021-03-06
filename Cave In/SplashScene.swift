//
//  SplashScene.swift
//  Cave In
//
//  Created by Marist User on 3/6/18.
//  Copyright © 2018 nKlacik. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        background.size = frame.size
        addChild(background)

        let tapMethod = #selector(SplashScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)

        let title = SKLabelNode(fontNamed: "Arial")
        title.text = "Cave In"
        title.fontSize = 64
        title.fontColor = SKColor.white
        title.position = CGPoint(x: xMid, y: yMid)
        title.zPosition = 10
        addChild(title)

        let start = SKLabelNode(fontNamed: "Arial")
        start.text = "Tap to Start"
        start.fontSize = 32
        start.fontColor = SKColor.white
        start.position = CGPoint(x: xMid, y: (yMid - 100))
        start.zPosition = 10
        addChild(start)
        
        let name = SKLabelNode(fontNamed: "Arial")
        name.text = "By Nicholas Klacik"
        name.fontSize = 24
        name.fontColor = SKColor.white
        name.position = CGPoint(x: xMid, y: (yMid - 350))
        name.zPosition = 10
        addChild(name)
        
        // Reload splash screen to fix small text on first load
        if Score.score == 0 {
            Score.score = 1
            goNext(scene: SplashScene())
        }
    }

    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        run(SKAction.playSoundFileNamed("BlockHit.wav", waitForCompletion: false))
        goNext(scene: GameScene())
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
            view.ignoresSiblingOrder = true
        }
    }
}
