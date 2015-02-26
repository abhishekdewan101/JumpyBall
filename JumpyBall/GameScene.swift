//
//  GameScene.swift
//  JumpyBall
//
//  Created by Abhishek Dewan on 2/26/15.
//  Copyright (c) 2015 Abhishek Dewan. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let playButton = SKSpriteNode(imageNamed: "play")
    
    override func didMoveToView(view: SKView) {
        self.playButton.position = CGPointMake(CGRectGetMidX((self.frame)), CGRectGetMidY(self.frame))
        self.addChild(self.playButton)
        self.backgroundColor = UIColor(hex:0x80D9FF);
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches{
            let location = touch.locationInNode(self)
            if(self.nodeAtPoint(location) == self.playButton){
                var scene = PlayScene(size:self.size)
                let skView = self.view as SKView!
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene);
            }
        }
    }
   
}
