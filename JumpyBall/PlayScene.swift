//
//  PlayScene.swift
//  JumpyBall
//
//  Created by Abhishek Dewan on 2/26/15.
//  Copyright (c) 2015 Abhishek Dewan. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class PlayScene: SKScene,SKPhysicsContactDelegate{
    
    let runningBar = SKSpriteNode(imageNamed: "bar")
    let hero = SKSpriteNode(imageNamed: "hero")
    let block1 = SKSpriteNode(imageNamed: "block1")
    let block2 = SKSpriteNode(imageNamed: "block2")
    let scoreText = SKLabelNode(fontNamed: "Chalkduster")
    
    var originRunningBarPositionX = CGFloat(0)
    var maxBarX = CGFloat(0)
    var groundSpeed = 5
    var heroBaseLine = CGFloat(0)
    var onGround = true
    var velocityY = CGFloat(0)
    let gravity = CGFloat(0.6)
    var blockStatuses:Dictionary<String,BlockStatus> = [:]
    private var backgroundMusicPlayer = AVAudioPlayer()

    
    var blockMaxX = CGFloat(0)
    var originBlockPositionX = CGFloat(0)
    var score = 0
    
    enum ColliderType:UInt32{
        case Hero = 1
        case Block = 2
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        var path = NSBundle.mainBundle().pathForResource(file, ofType:type)
        var url = NSURL.fileURLWithPath(path!)
        
        //2
        var error: NSError?
        
        //3
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        //4
        return audioPlayer!
    }
    
    
    
    override func didMoveToView(view: SKView) {
        
        backgroundMusicPlayer = self.setupAudioPlayerWithFile("sound", type:"mp3")
        backgroundMusicPlayer.play()
        
        self.backgroundColor = UIColor(hex:0x80D9FF)
        
        self.physicsWorld.contactDelegate = self;
        
        self.runningBar.anchorPoint = CGPointMake(0, 0.5)
        self.runningBar.position = CGPointMake(CGRectGetMinX(self.frame),CGRectGetMinY(self.frame)+(self.runningBar.size.height/2))
        self.addChild(self.runningBar)
        self.originRunningBarPositionX = self.runningBar.position.x
        self.maxBarX = self.runningBar.size.width - self.frame.size.width
        self.maxBarX *= -1
        
        self.heroBaseLine = self.runningBar.position.y + (self.runningBar.size.height/2)
        self.hero.position = CGPointMake(CGRectGetMinX(self.frame
            )+(self.hero.size.width),self.heroBaseLine + (self.hero.size.height/2))
        self.hero.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(self.hero.size.width/2))
        self.hero.physicsBody?.affectedByGravity = false
        self.hero.physicsBody?.categoryBitMask = ColliderType.Hero.rawValue
        self.hero.physicsBody?.contactTestBitMask = ColliderType.Block.rawValue
        self.hero.physicsBody?.collisionBitMask = ColliderType.Block.rawValue
        self.addChild(hero)
        
        self.block1.position = CGPointMake((CGRectGetMaxX(self.frame) + self.block1.size.width), self.heroBaseLine + (self.hero.size.height/2))
        self.block2.position = CGPointMake((CGRectGetMaxX(self.frame) + self.block2.size.width + 20), (self.heroBaseLine + self.block2.size.height/2))
        
        self.block1.physicsBody = SKPhysicsBody(rectangleOfSize: self.block1.size)
        self.block1.physicsBody?.dynamic = false
        self.block1.physicsBody?.categoryBitMask = ColliderType.Block.rawValue
        self.block1.physicsBody?.contactTestBitMask = ColliderType.Hero.rawValue
        self.block1.physicsBody?.collisionBitMask = ColliderType.Hero.rawValue
        
        self.block2.physicsBody = SKPhysicsBody(rectangleOfSize: self.block2.size)
        self.block2.physicsBody?.dynamic = false
        self.block2.physicsBody?.categoryBitMask = ColliderType.Block.rawValue
        self.block2.physicsBody?.contactTestBitMask = ColliderType.Hero.rawValue
        self.block2.physicsBody?.collisionBitMask = ColliderType.Hero.rawValue
        
        self.block1.name = "block1"
        self.block2.name = "block2"
        
        blockStatuses["block1"] = BlockStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        blockStatuses["block2"] = BlockStatus(isRunning: false, timeGapForNextRun: random(), currentInterval: UInt32(0))
        
        self.scoreText.text = "Score: \(self.score)"
        self.scoreText.fontSize = 42
        self.scoreText.position = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame)+200))
        self.addChild(self.scoreText)
        
        self.blockMaxX = 0 - self.block1.size.width/2
        self.originBlockPositionX = self.block1.position.x
        
        self.addChild(self.block1)
        self.addChild(self.block2)
    }
    
    func random() -> UInt32{
        let range = UInt32(50)...UInt32(200)
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
    }
    
   
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if self.onGround{
            self.velocityY = -18.0
            self.onGround = false
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if self.velocityY < -9.0{
            self.velocityY = -9.0
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        died()
    }
    
    func died(){
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene{
            let skView = self.view as SKView!
            skView.ignoresSiblingOrder = false
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
        }
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        if self.runningBar.position.x <= maxBarX {
            self.runningBar.position.x = self.originRunningBarPositionX
        }
        
        //jump
        
        self.velocityY += self.gravity
        self.hero.position.y -= self.velocityY
        
        if self.hero.position.y < (self.heroBaseLine + (self.hero.size.height/2)){
            self.hero.position.y = self.heroBaseLine + (self.hero.size.height/2)
            velocityY = 0.0
            self.onGround = true
        }
    
        var degreeRotation = CDouble(self.groundSpeed) * M_PI/180
        //rotate hero
        self.hero.zRotation -= CGFloat(degreeRotation)
        
        //move the ground
        self.runningBar.position.x -= CGFloat(self.groundSpeed)
        
        blockRunner()
    }
    
    func blockRunner(){
        for(block,blockStatus) in self.blockStatuses{
            var thisBlock = self.childNodeWithName(block)
            if blockStatus.shouldRunBlock(){
                blockStatus.timeGapForNextRun = random()
                blockStatus.currentInterval = 0
                blockStatus.isRunning =  true
            }
            
            if blockStatus.isRunning{
                if thisBlock?.position.x > blockMaxX{
                    thisBlock?.position.x -= CGFloat(self.groundSpeed)
                }else{
                    thisBlock?.position.x = self.originBlockPositionX
                    blockStatus.isRunning = false
                    self.score++
                    self.scoreText.text = String("Score: \(self.score)")
                    if self.score % 5 == 0 {
                        self.groundSpeed++
                    }
                }
            }else{
                blockStatus.currentInterval++
            }
        }
    }
}