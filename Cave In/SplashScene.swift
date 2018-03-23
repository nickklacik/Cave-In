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
        title.text = "Cave In";
        title.fontSize = 64
        title.fontColor = SKColor.black
        title.position = CGPoint(x: xMid, y: yMid)
        title.zPosition = 10
        addChild(title)
        
        let start = SKLabelNode(fontNamed: "Arial")
        start.text = "Tap to Start";
        start.fontSize = 32
        start.fontColor = SKColor.black
        start.position = CGPoint(x: xMid, y: (yMid - 100) )
        start.zPosition = 10
        addChild(start)
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
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
            let reveal = SKTransition.crossFade(withDuration: 5)
            view.presentScene(scene, transition: reveal)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
