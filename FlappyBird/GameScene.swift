//
//  GameScene.swift
//  FlappyBirdSwift
//
//  Created by Leonardo Lee on 9/1/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var flappy = SKSpriteNode(imageNamed: "bird")
    var pipes = [PipeNode]()
    var availablePipe : PipeNode!
    
    var deltaTime = 0.0
    var nextPipeTime = 2.0
    var timeSinceLastPipe = 0.0
    var previousTime = 0.0
    
    //Physics Categories
    let flappyCategory : UInt32 = 0x1
    let pipeCategory : UInt32 = 0x1 << 1
    
    //head and tail to do without the array.
    
    override func didMoveToView(view: SKView) {
        //Scrolling BG
        self.setupBackground()
        self.setupPipes()
        self.physicsWorld.contactDelegate = self

        /* Setup your scene here */
        //Character
        
        //Convert to an atlas (for the flappy).
        self.flappy.position = CGPoint(x: 200, y: 500)
        self.flappy.name = "flappy"
        self.addChild(flappy)
        
        //Physics body
        self.flappy.physicsBody = SKPhysicsBody(rectangleOfSize: flappy.size)
        //flappy.physicsBody.dynamic = false
        flappy.physicsBody.mass = 0.04
        self.flappy.physicsBody.categoryBitMask = self.flappyCategory
        self.flappy.physicsBody.contactTestBitMask = self.pipeCategory
        
        //Physics World
        //self.physicsWorld.contactDelegate
       
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            self.flappy.physicsBody.velocity = CGVector(0,0)
            self.flappy.physicsBody.applyImpulse(CGVector(0, 15))
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //Setting up time intervals. To figure out delta time (time since last update)
        self.deltaTime = currentTime - previousTime
        self.previousTime = currentTime
        self.timeSinceLastPipe += self.deltaTime
        
        if self.timeSinceLastPipe > self.nextPipeTime {
            //Create pipe.
            var pipeNode = self.fetchFirstAvailablePipe()
            pipeNode.pipe.position = CGPointMake(1100, 200)
            
            //create location to move to with an action
            var location = CGPointMake(-300, 200)
            var moveAction = SKAction.moveTo(location, duration: 3.5)
            
            var completionAction = SKAction.runBlock({
                () -> Void in
                self.doneWithPipe(pipeNode)
            })
            var sequence = SKAction.sequence([moveAction, completionAction])
            pipeNode.pipe.runAction(moveAction)
            
            self.timeSinceLastPipe = 0.0
        }
        
        //Enumerate through BG nodes
        self.enumerateChildNodesWithName("background", usingBlock: {
            (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x - 5, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width{
                    bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                }
            }
        })
    }
    
    func didBeginContact(contact: SKPhysicsContact!) {
        println("Contact")
    }
    
//MARK: Background
    func fetchFirstAvailablePipe() -> PipeNode {
        var firstPipe = self.availablePipe
        
        if self.availablePipe.nextNode != nil {
            self.availablePipe = self.availablePipe.nextNode
        }
        firstPipe.pipe.hidden = false
        return firstPipe
    }
    
    func doneWithPipe(pipeNode: PipeNode) {
        pipeNode.pipe.hidden = true
        pipeNode.nextNode = self.availablePipe
        self.availablePipe = pipeNode
    }
    
    func setupBackground() {
        for var i = 0; i < 2; i++ {
            var bg = SKSpriteNode(imageNamed: "cloudbg.jpeg")
            bg.anchorPoint = CGPointZero
            bg.position = CGPointMake( CGFloat(i) * bg.size.width, 0)
            bg.yScale = 1
            bg.xScale = 1
            bg.name = "background"
            self.addChild(bg)
        }
    }
    
    func setupPipes() {
        for var i = 0; i < 10; i++ {
            var pipeNode = PipeNode()
            pipeNode.pipe.position = CGPointMake(600, 0)
            pipeNode.pipe.physicsBody = SKPhysicsBody(rectangleOfSize: pipeNode.pipe.size)
            pipeNode.pipe.physicsBody.affectedByGravity = false
            pipeNode.pipe.physicsBody.dynamic = false
            pipeNode.pipe.physicsBody.categoryBitMask = UInt32(self.pipeCategory)
            pipeNode.pipe.hidden = true
            self.addChild(pipeNode.pipe)
            self.pipes.insert(pipeNode, atIndex: 0)
            
            if self.pipes.count > 1 {
                pipeNode.nextNode = self.pipes[1]
            }
        }
        self.availablePipe = self.pipes[0]
    }
    
//MARK: SKPhysicsContactDelegate
    
    
}
