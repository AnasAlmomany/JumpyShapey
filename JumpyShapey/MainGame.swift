//
//  MainGame.swift
//  JumpyShapey
//
//  Created by Justin Davis on 2/13/18.
//  Copyright © 2018 Trekk. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MainGame: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var hero = SKSpriteNode()
    var floor = SKSpriteNode()
    
    // These blank nodes are used as spawn point locations for enemy objects
    var positionOne = SKSpriteNode()
    var positionTwo = SKSpriteNode()
    var positionThree = SKSpriteNode()
    var positionFour = SKSpriteNode()
    var positionFive = SKSpriteNode()
    
    // Jumping flags
    var isJumping = Bool()
    var isInAir = Bool()
    
    struct PhysicsCatagory {
        static let Enemy: UInt32 = 1
        static let Hero: UInt32 = 2
        static let Floor: UInt32 = 4
        static let Collectable: UInt32 = 8
    }
    
     override func sceneDidLoad() {
  
        backgroundColor = randomBackgroundColor() // Says background - really sets entire interface color
        setupUI() // Sets up the interface with a randomly selected color scheme
        setupNodes() // I have a small pile of nodes to setup, it get's done here
        UIApplication.shared.isIdleTimerDisabled = true // Keep the device awake
        
        physicsWorld.contactDelegate = self // Required for physics delegate calls

        isJumping = false
        isInAir = false
        
        spawnCircle(friend: true)
    }
    
    func setupNodes(){
        
        hero = childNode(withName: "hero") as! SKSpriteNode // Main Player Node
        hero.physicsBody?.categoryBitMask = PhysicsCatagory.Hero
        hero.name = "hero"
        hero.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy | PhysicsCatagory.Floor
        
        floor = childNode(withName: "floor") as! SKSpriteNode // The game scene ground object
        floor.physicsBody?.categoryBitMask = PhysicsCatagory.Floor
        floor.physicsBody?.contactTestBitMask = PhysicsCatagory.Hero
        
        positionOne = childNode(withName: "pOne") as! SKSpriteNode
        positionTwo = childNode(withName: "pTwo") as! SKSpriteNode
        positionThree = childNode(withName: "pThree") as! SKSpriteNode
        positionFour = childNode(withName: "pFour") as! SKSpriteNode
        positionFive = childNode(withName: "pFive") as! SKSpriteNode
    

    }
    
    
    func randomBackgroundColor() -> SKColor {
        let colorArray = [SKColor.red, SKColor.yellow, SKColor.blue, SKColor.orange, SKColor.cyan]
        let selectedColor = GKRandomDistribution(lowestValue: 0, highestValue: colorArray.count - 1)
        return colorArray[selectedColor.nextInt()]
    }
    
    override func didMove(to view: SKView) {
        // I'm using UIGestureRecognizers to control the hero avatar
        setupGestureRecognizers()
    }
    
    func setupUI(){
        
        switch backgroundColor {
        case SKColor.red:
            setUIColorElements(FloorColor: selectedColor(number: 2), PlayerColor: selectedColor(number: 1), ScoreColor: selectedColor(number: 0))
        case SKColor.yellow:
            setUIColorElements(FloorColor: selectedColor(number: 3), PlayerColor: selectedColor(number: 8), ScoreColor: selectedColor(number: 4))
        case SKColor.blue:
            setUIColorElements(FloorColor: selectedColor(number: 8), PlayerColor: selectedColor(number: 2), ScoreColor: selectedColor(number: 1))
        case SKColor.orange:
            setUIColorElements(FloorColor: selectedColor(number: 3), PlayerColor: selectedColor(number: 6), ScoreColor: selectedColor(number: 3))
        case SKColor.cyan:
            setUIColorElements(FloorColor: selectedColor(number: 8), PlayerColor: selectedColor(number: 5), ScoreColor: selectedColor(number: 5))
        default:
            setUIColorElements(FloorColor: selectedColor(number: 8), PlayerColor: selectedColor(number: 5), ScoreColor: selectedColor(number: 5))
        }
    }
    
    // Since I use a bunch of colors, I keep them here
    func selectedColor(number: Int) -> SKColor {
        let colorArray = [SKColor.white, SKColor.yellow, SKColor.cyan, SKColor.blue, SKColor.black, SKColor.purple, SKColor.green, SKColor.orange, SKColor.red]
        return colorArray[number]
    }
    
    func setUIColorElements(FloorColor: SKColor, PlayerColor: SKColor, ScoreColor: SKColor){
        let floorNode = childNode(withName: "floor") as! SKSpriteNode
        let heroNode = childNode(withName: "hero") as! SKSpriteNode
        let scoreNode = childNode(withName: "score") as! SKLabelNode
        
        floorNode.color = FloorColor
        heroNode.color = PlayerColor
        scoreNode.fontColor = ScoreColor
    }
    
    func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(tap:)))
        view?.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(double:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view?.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleGesture(tap: UITapGestureRecognizer){
//        let heroNode = childNode(withName: "hero")
        
        isInAir = false
        if !isJumping{
            hero.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 300.0))
            isJumping = true
            isInAir = true
        }
    }
    
    @objc func handleDoubleTap(double: UIGestureRecognizer){
        
        if (isInAir){
            hero.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 300.0))
            isInAir = false
        }
        
    }
    func removeAllGestures(){
        
        //Gesture Recognizers need to be removed when we leave the scene. Just saving this for later.
        for gesture in (self.view?.gestureRecognizers)! {
            self.view?.removeGestureRecognizer(gesture)
        }
        
    }

    override func update(_ currentTime: TimeInterval) {

//        detectContactBetweenPlayerAndCollectable()
    }
    
    func spawnCircle(friend: Bool){
        // Circle Sprite
        let circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = SKColor.white
        circle.strokeColor = SKColor.white
        circle.position = positionOne.position
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 50)
       
        
        if friend {
            circle.physicsBody?.categoryBitMask = PhysicsCatagory.Collectable
            circle.physicsBody?.contactTestBitMask = PhysicsCatagory.Hero
            circle.name = "circleFriend"
        }else {
//            circle.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
//            circle.physicsBody?.contactTestBitMask = PhysicsCatagory.Hero
            circle.name = "circleEnemy"
        }
        
        
        addChild(circle)
        // Circle Sprite Actions
        let moveForward: SKAction = SKAction.moveTo(x: -size.width, duration: 2)
        let removeSelf: SKAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveForward,removeSelf])
        circle.run(sequence)
        
    }
    
     func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody:SKPhysicsBody = contact.bodyA
        let secondBody:SKPhysicsBody = contact.bodyB
        
            // I don't want the hero jumping nine hundred feet in the air, so this flag
            // prevents it from doing so
        
            if firstBody.categoryBitMask == PhysicsCatagory.Hero && secondBody.categoryBitMask == PhysicsCatagory.Floor || firstBody.categoryBitMask == PhysicsCatagory.Floor && secondBody.categoryBitMask == PhysicsCatagory.Hero  {
                
                // Hero & Floor
                if firstBody.categoryBitMask == PhysicsCatagory.Hero {
                    isJumping = false
                    isInAir = false
                }else if firstBody.categoryBitMask == PhysicsCatagory.Floor{
                    isJumping = false
                    isInAir = false
                }
            }
        

            // Why not check a different way? I've been toying with using this idea as it seems a little more succinct
            // Additionally, since I'm dealing with very gentle physics contacts here, I don't like casting and
            // recasting objects that often. This seems to work the best given the contact scenario I'm dealing
            // with here.
            if firstBody.node?.name == "hero" && secondBody.node?.name == "circleFriend" {
                secondBody.node?.physicsBody?.categoryBitMask = 0
                secondBody.node?.removeFromParent()
            }

    }

    
    func gameOver(){
        print("Game Over")
    }
    
    


}
