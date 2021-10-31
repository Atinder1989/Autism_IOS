//
//  GameScene.swift
//  MajeSample
//
//  Created by mac on 09/06/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import CoreMotion
import SpriteKit
import CoreGraphics

//protocol GameSceneDelegate:NSObject {
//    func submitQuestionResponse(response:MazesInfo)
//}

 

struct Collision {
    static let Ball: UInt32 = 0x1 << 0       // bin(001) = dec(1)
    static let BlackHole: UInt32 = 0x1 << 1  // bin(010) = dec(2)
    static let FinishHole: UInt32 = 0x1 << 2 // bin(100) = dec(4)
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    
    var manager: CMMotionManager?
    var ball: SKSpriteNode!
    
    var myScene = SKScene()
    
    var timer: Timer?
    var seconds: Int?
    
    private var success_count = 0
    private var timeTakenToSolve = 0
    private var questionCompletionTimer: Timer? = nil
    
    
    
    override func didMove(to view: SKView) {
      
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(increaseTimer), userInfo: nil, repeats: true)
   
        physicsWorld.contactDelegate = self
        
        ball = self.childNode(withName: "ball") as? SKSpriteNode

        ball.physicsBody?.mass = 4.5
       ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.isDynamic = true // necessary to detect collision
        ball.physicsBody?.categoryBitMask = Collision.Ball
        ball.physicsBody?.collisionBitMask = Collision.Ball
        ball.physicsBody?.contactTestBitMask = Collision.BlackHole | Collision.FinishHole
       ball.physicsBody?.affectedByGravity = false
//        addChild(ball)
        
        manager = CMMotionManager()
        
   
        
        if let manager = manager, manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
           // manager.accelerometerUpdateInterval = 0.1
            manager.startDeviceMotionUpdates()
        }
       
    }
  
    
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: self)
//            
//            ball.position.x = location.x
//            ball.position.y = location.y
//            
//        }
//    }
    
    
    func didBegin(_ contact: SKPhysicsContact){
    //print("colliding!")
            if contact.bodyA.categoryBitMask == Collision.BlackHole || contact.bodyB.categoryBitMask == Collision.BlackHole {
                centerBall()
                resetTimer()
            } else if contact.bodyA.categoryBitMask == Collision.FinishHole || contact.bodyB.categoryBitMask == Collision.FinishHole {
               // alertWon()
                
              let strseconds = String(seconds!)
                
                UserDefaults.standard.set(strseconds, forKey: "time")
                
                timer?.invalidate()
                
                 NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
                
             
            }
        }
    
    
    
    
    override func update(_ currentTime: CFTimeInterval) {
        if let gravityX = manager?.deviceMotion?.gravity.x, let gravityY = manager?.deviceMotion?.gravity.y, ball != nil {
            // let newPosition = CGPoint(x: Double(ball.position.x) + gravityX * 35.0, y: Double(ball.position.y) + gravityY * 35.0)
            // let moveAction = SKAction.moveTo(newPosition, duration: 0.0)
            // ball.runAction(moveAction)
            
            // applyImpulse() is much better than applyForce()
            // ball.physicsBody?.applyForce(CGVector(dx: CGFloat(gravityX) * 5000.0, dy: CGFloat(gravityY) * 5000.0))
            
            ball.physicsBody?.applyImpulse(CGVector(dx: CGFloat(gravityX) * 200.0, dy: CGFloat(gravityY) * 200.0))
        }
    }
    
    // MARK: - Ball Methods
    
    func centerBall() {
        ball.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        let moveAction = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY), duration: 0.0)
        ball.run(moveAction)
    }
    
    func alertWon() {
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: .default) { action in
            // Handle when button is clicked
        }
        alert.addAction(action)
        if let vc = self.scene?.view?.window?.rootViewController {
           vc.present(alert, animated: true, completion: nil)
        }
       
        
    }
    
    // MARK: - Timer Methods
    
    @objc func increaseTimer() {
        seconds = (seconds ?? 0) + 1
    }
    
    func resetTimer() {
        seconds = 0
    }
}



