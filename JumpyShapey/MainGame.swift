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
import AVFoundation
import Crashlytics

class MainGame: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var hero = SKSpriteNode()
    var floor = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var countDownLabelNode = SKLabelNode()
    
    // These blank nodes are used as spawn point locations for enemy objects
    var positionOne = SKSpriteNode()
    var positionTwo = SKSpriteNode()
    var positionThree = SKSpriteNode()
    var positionFour = SKSpriteNode()
    var positionFive = SKSpriteNode()
    
    // Jumping flags
    var isJumping = Bool()
    var isInAir = Bool()
    var isThirdJump = Bool()
    var gameIsRunning = Bool()
    
    // Pause flag, saving for later
    var gamePaused = Bool()
    
    // Audio player
    var audioPlayer = AVAudioPlayer()
    
    // Array of Enemy/Collectable spawm points
    var spawnPoints = Array<SKSpriteNode>()
    
    var currentScore: Int = 0 {
        didSet {
            scoreLabel.text = "\(currentScore)"
        }
    }
    
    
    struct PhysicsCatagory {
        static let Enemy: UInt32 = 1
        static let Hero: UInt32 = 2
        static let Floor: UInt32 = 4
        static let Collectable: UInt32 = 8
        static let None: UInt32 = 10
    }
    
     override func sceneDidLoad() {
        
        backgroundColor = randomBackgroundColor() // Says background - really sets entire interface color
        setupUI() // Sets up the interface with a randomly selected color scheme
        setupNodes() // I have a small pile of nodes to setup, it get's done here
        UIApplication.shared.isIdleTimerDisabled = true // Keep the device awake
        
        physicsWorld.contactDelegate = self // Required for physics delegate calls

        isJumping = false // First jump flag
        isInAir = false // Second jump flag
        gamePaused = false // Game Paused or not -> Not currently used
        isThirdJump = false // Third jump flag
        gameIsRunning = false // This flag prevents the UIGestureRecognizer from
        // firing when gameplay is not active.
        currentScore = 0
        playAudio()
    }
    
    func playAudio(){
        let themeMusic = URL(fileURLWithPath: Bundle.main.path(forResource: "notmyship", ofType: "mp3")!)
        try! audioPlayer = AVAudioPlayer(contentsOf: themeMusic)
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func setupNodes(){
        
        
        hero = childNode(withName: "hero") as! SKSpriteNode // Main Player Node
        hero.physicsBody?.categoryBitMask = PhysicsCatagory.Hero
        hero.name = "hero"
        hero.physicsBody?.linearDamping = 1.0
        
        // It's very possible - even though we're removing the categorybitmask that allows for contact following
        // initial contact - for a circle to knock the hero off screen. This SKConstrait prevents that from
        // happening.
        
        
        let range = SKRange(lowerLimit: hero.position.x, upperLimit: hero.position.x)
        let lockToX = SKConstraint.positionX(range)
        hero.constraints = [lockToX]
        hero.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy | PhysicsCatagory.Floor
        
        floor = childNode(withName: "floor") as! SKSpriteNode // The game scene ground object
        floor.physicsBody?.categoryBitMask = PhysicsCatagory.Floor
        floor.physicsBody?.contactTestBitMask = PhysicsCatagory.Hero
        
        // These objects provide me with a set number of spawn locations to choose from
        positionOne = childNode(withName: "pOne") as! SKSpriteNode
        positionTwo = childNode(withName: "pTwo") as! SKSpriteNode
        positionThree = childNode(withName: "pThree") as! SKSpriteNode
        positionFour = childNode(withName: "pFour") as! SKSpriteNode
        positionFive = childNode(withName: "pFive") as! SKSpriteNode
        
        // Score Label Node
        scoreLabel = childNode(withName: "score") as! SKLabelNode
        
        
        // Spawn point location array is populated here:
        spawnPoints = [positionOne, positionTwo, positionThree, positionFour, positionFive]
        
        
        hero.physicsBody?.isDynamic = false
    

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
        
//        let colorArray = [0 SKColor.white, 1 SKColor.yellow, 2 SKColor.cyan, 3 SKColor.blue, 4 SKColor.black, 5 SKColor.purple, 6 SKColor.green, 7 SKColor.orange, 8 SKColor.red]
//
        
        
        switch backgroundColor {
        case SKColor.red:
            setUIColorElements(FloorColor: selectedColor(number: 2), PlayerColor: selectedColor(number: 1), ScoreColor: selectedColor(number: 0), CountDownColor: selectedColor(number: 0))
        case SKColor.yellow:
            setUIColorElements(FloorColor: selectedColor(number: 3), PlayerColor: selectedColor(number: 8), ScoreColor: selectedColor(number: 4), CountDownColor: selectedColor(number: 4))
        case SKColor.blue:
            setUIColorElements(FloorColor: selectedColor(number: 8), PlayerColor: selectedColor(number: 2), ScoreColor: selectedColor(number: 1), CountDownColor: selectedColor(number: 1))
        case SKColor.orange:
            setUIColorElements(FloorColor: selectedColor(number: 3), PlayerColor: selectedColor(number: 6), ScoreColor: selectedColor(number: 3), CountDownColor: selectedColor(number: 3))
        case SKColor.cyan:
            setUIColorElements(FloorColor: selectedColor(number: 8), PlayerColor: selectedColor(number: 5), ScoreColor: selectedColor(number: 5), CountDownColor: selectedColor(number: 5))
        default:
            setUIColorElements(FloorColor: selectedColor(number: 8), PlayerColor: selectedColor(number: 5), ScoreColor: selectedColor(number: 5), CountDownColor: selectedColor(number: 5))
        }
        beginCountDown()
    }
    
    func beginCountDown(){
        var countDownAmount = 3
        countDownLabelNode = childNode(withName: "countDown") as! SKLabelNode
        countDownLabelNode.text = "\(countDownAmount)"
        
        let growAction: SKAction = SKAction.scale(to: 3, duration: 1)
        let returnToNormalAction: SKAction = SKAction.scale(to: 1.0, duration: 0.0)
        
        let setTextAction: SKAction = SKAction.run {
            countDownAmount = countDownAmount - 1
            self.countDownLabelNode.text = "\(countDownAmount)"
        }
        let hideSelf: SKAction = SKAction.run {
            self.countDownLabelNode.alpha = 0
            self.gameStart()
        }
        let wait: SKAction = SKAction.wait(forDuration: 1.0)
        let sequence: SKAction = SKAction.sequence([growAction, returnToNormalAction, growAction, returnToNormalAction, growAction, returnToNormalAction, hideSelf])
        let sequenceTwo: SKAction = SKAction.sequence([wait, setTextAction, wait, setTextAction])
        let group: SKAction = SKAction.group([sequence, sequenceTwo])
        countDownLabelNode.run(group)
        
    }
    func gameStart(){
        gameIsRunning = true
        hero.physicsBody?.isDynamic = true
        let infiniteSpawn: SKAction = SKAction.run {
            self.spawnCircle()
        }
        let wait: SKAction = SKAction.wait(forDuration: 1.0)
        let sequence: SKAction = SKAction.sequence([infiniteSpawn, wait])
        let repeatForever: SKAction = SKAction.repeatForever(sequence)
        self.run(repeatForever)
        
        let rotateAction: SKAction = SKAction.rotate(byAngle: 90, duration: 1)
        let rotateForever: SKAction = SKAction.repeatForever(rotateAction)
        hero.run(rotateForever)
    }
    
    // Since I use a bunch of colors, I keep them here
    func selectedColor(number: Int) -> SKColor {
        let colorArray = [SKColor.white, SKColor.yellow, SKColor.cyan, SKColor.blue, SKColor.black, SKColor.purple, SKColor.green, SKColor.orange, SKColor.red]
        return colorArray[number]
    }
    
    func setUIColorElements(FloorColor: SKColor, PlayerColor: SKColor, ScoreColor: SKColor, CountDownColor: SKColor){
            let floorNode = childNode(withName: "floor") as! SKSpriteNode
            let heroNode = childNode(withName: "hero") as! SKSpriteNode
            let scoreNode = childNode(withName: "score") as! SKLabelNode
            let countLabel = childNode(withName: "countDown") as! SKLabelNode
            floorNode.color = FloorColor
            heroNode.color = PlayerColor
            scoreNode.fontColor = ScoreColor
            countLabel.fontColor = CountDownColor
        }
    
    func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(tap:)))
        view?.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleGesture(tap: UITapGestureRecognizer){
        if gameIsRunning {
            if isThirdJump {
                Answers.logCustomEvent(withName: "Jump Three", customAttributes: [:])
                hero.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
                hero.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 450.0))
                let jumpAudio: SKAction = SKAction.playSoundFileNamed("jump_03", waitForCompletion: false)
                self.run(jumpAudio, withKey: "jumpThree")
                isThirdJump = false
            }
            
            if isInAir == true {
                Answers.logCustomEvent(withName: "Jump Two", customAttributes: [:])
                hero.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
                hero.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 450.0))
                let jumpAudio: SKAction = SKAction.playSoundFileNamed("jump_03", waitForCompletion: false)
                self.run(jumpAudio, withKey: "jumpTwo")
                isInAir = false
                isThirdJump = true
            }
            
            if !isJumping{
                Answers.logCustomEvent(withName: "Jump One", customAttributes: [:])
                hero.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 375.0))
                let jumpAudio: SKAction = SKAction.playSoundFileNamed("jump_01", waitForCompletion: false)
                self.run(jumpAudio, withKey: "jumpOne")
                isJumping = true
                isInAir = true
            }
        }
        
        
        
    }
    
    func removeAllGestures(){
        
        //Gesture Recognizers need to be removed when we leave the scene. Just saving this for later.
        for gesture in (self.view?.gestureRecognizers)! {
            self.view?.removeGestureRecognizer(gesture)
        }
        
    }

    override func update(_ currentTime: TimeInterval) {

    }
    
    func spawnCircle(){
        let currentlyCollectable = GKRandomSource.sharedRandom().nextInt(upperBound: 2)
        
        print(currentlyCollectable)
        let selectedPositionIndex = GKRandomDistribution(lowestValue: 0, highestValue: spawnPoints.count - 1)
        let currentSpawnPoint: SKSpriteNode = spawnPoints[selectedPositionIndex.nextInt()]
        let circle = SKShapeNode(circleOfRadius: 50)
        circle.fillColor = SKColor.white
        circle.strokeColor = SKColor.white
        circle.position = currentSpawnPoint.position
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        
        // I want to randomize just how bouncy these circles are.
        let bouncyArray = [0.9,1.1,1.2,1.3]
        let randomRestitution = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: bouncyArray)
        let currentRestitution = randomRestitution[0] as! CGFloat
        circle.physicsBody?.restitution = currentRestitution
        if currentlyCollectable == 0 {
            circle.physicsBody?.categoryBitMask = PhysicsCatagory.Collectable
            circle.physicsBody?.contactTestBitMask = PhysicsCatagory.Hero
            circle.name = "circleCollectable"
            circle.fillColor = hero.color
        }else if currentlyCollectable == 1 {
            circle.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
            circle.physicsBody?.contactTestBitMask = PhysicsCatagory.Hero
            circle.name = "circleEnemy"
        
            //        let colorArray = [0 SKColor.white, 1 SKColor.yellow, 2 SKColor.cyan, 3 SKColor.blue, 4 SKColor.black, 5 SKColor.purple, 6 SKColor.green, 7 SKColor.orange, 8 SKColor.red]
            //
            
            switch hero.color {
            case selectedColor(number: 0):
                circle.fillColor = selectedColor(number: 7)
                circle.strokeColor = selectedColor(number: 7)
            case selectedColor(number: 1):
                circle.fillColor = selectedColor(number: 3)
                circle.strokeColor = selectedColor(number: 3)
            case selectedColor(number: 2):
                circle.fillColor = selectedColor(number: 5)
                circle.strokeColor = selectedColor(number: 5)
            case selectedColor(number: 3):
                circle.fillColor = selectedColor(number: 7)
                circle.strokeColor = selectedColor(number: 7)
            case selectedColor(number: 4):
                circle.fillColor = selectedColor(number: 1)
                circle.strokeColor = selectedColor(number: 1)
            case selectedColor(number: 5):
                circle.fillColor = selectedColor(number: 0)
                circle.strokeColor = selectedColor(number: 0)
            case selectedColor(number: 6):
                circle.fillColor = selectedColor(number: 3)
                circle.strokeColor = selectedColor(number: 3)
            case selectedColor(number: 7):
                circle.fillColor = selectedColor(number: 0)
                circle.strokeColor = selectedColor(number: 0)
            case selectedColor(number: 8):
                circle.fillColor = selectedColor(number: 5)
            default:
                break
            
            }
            
        }
        
        addChild(circle)
        // Circle Sprite Actions
        
        // There is an issue if an enemy circle spawns at position four in the spawnPoints array
        // As this is the top position in the stack of possible spawn points, the circle can land right on
        // the user, providing an unfair game over. To solve this, enemy circles cannot spawn from position number four
        // AKA - the top spawn point
        
        if circle.name == "circleEnemy" && circle.position.y == spawnPoints[4].position.y {
            let spawnPointThree: SKSpriteNode = spawnPoints[3]
            circle.position = spawnPointThree.position
        }
        
//        let randomSpeed = GKRandomDistribution(lowestValue: 2, highestValue: 4)
        let moveForward: SKAction = SKAction.moveTo(x: -size.width, duration: 2)
        let removeSelf: SKAction = SKAction.removeFromParent()
        let sequence: SKAction = SKAction.sequence([moveForward,removeSelf])
        circle.run(sequence)
        
        
        if circle.position.y != spawnPoints[4].position.y{
            
        }else {
            
        }
        
        
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
                isThirdJump = false
                hero.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            }else if firstBody.categoryBitMask == PhysicsCatagory.Floor{
                isJumping = false
                isInAir = false
                isThirdJump = false
                hero.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            }
        }
    

        // Why not check a different way? I've been toying with using this idea as it seems a little more succinct
        // Additionally, since I'm dealing with very gentle physics contacts here, I don't like casting and
        // recasting objects that often. This seems to work the best given the contact scenario I'm dealing
        // with here.
        if firstBody.node?.name == "hero" && secondBody.node?.name == "circleCollectable" {
            secondBody.node?.physicsBody?.categoryBitMask = PhysicsCatagory.None // This is done to prevent the player from being instantly pushed back
            secondBody.node?.removeFromParent()
            currentScore = currentScore + 1
        }else if firstBody.node?.name == "circleCollectable" && secondBody.node?.name == "hero"{
            firstBody.node?.physicsBody?.categoryBitMask = PhysicsCatagory.None
            firstBody.node?.removeFromParent()
            currentScore = currentScore + 1
        }
        
        if firstBody.node?.name == "hero" && secondBody.node?.name == "circleEnemy" {
            secondBody.node?.physicsBody?.categoryBitMask = PhysicsCatagory.None
            gameOver()
        }else if firstBody.node?.name == "circleEnemy" && secondBody.node?.name == "hero" {
            gameOver()
        }

    }

    
    func gameOver(){
        gameIsRunning = false
        guard let ceilingNode = childNode(withName: "ceiling") as? SKSpriteNode else { return }
        ceilingNode.removeFromParent()
        print("Game Over")
        let defaults = UserDefaults.standard
        defaults.set(currentScore, forKey: "gameOverScore")
        
        if currentScore > defaults.integer(forKey: "highScore"){
            defaults.set(currentScore, forKey: "highScore")
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reportScore"), object: nil)
        
        
        stopAllSpritesAndActions(name: "circleCollectable")
        stopAllSpritesAndActions(name: "hero")
        stopAllSpritesAndActions(name: "circleEnemy")
        scene?.removeAllActions()
        
        
        
        guard let gameOverText: SKSpriteNode = childNode(withName: "gameOver") as? SKSpriteNode else {return}
        gameOverText.physicsBody = SKPhysicsBody(rectangleOf: gameOverText.frame.size)
        gameOverText.physicsBody?.isDynamic = true
        gameOverText.physicsBody?.affectedByGravity = true
        
        let waitAction: SKAction = SKAction.wait(forDuration: 0.5)
        let closeOffScene: SKAction = SKAction.run {
            let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
            self.physicsBody = borderBody
        }
        let waitActionTwo: SKAction = SKAction.wait(forDuration: 3.0)
        let moveToGameOverScene = SKAction.run {
            
        let transition:SKTransition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1.0)
        if let scene = GKScene(fileNamed: "GameOverScene") {
            if let sceneNode = scene.rootNode as! GameOverScene?{
                sceneNode.scaleMode = .aspectFill
                self.audioPlayer.stop()
                self.resetSceneVariables()
                self.removeAllGestures()
                Answers.logCustomEvent(withName: "Game Over", customAttributes: [:])
                self.view?.presentScene(sceneNode, transition: transition)
            }
        }
            
        }
        let sequence: SKAction = SKAction.sequence([waitAction, closeOffScene, waitActionTwo, moveToGameOverScene])
        self.run(sequence)
        
        
        
        
        
    }
    
    func stopAllSpritesAndActions(name: String){
        enumerateChildNodes(withName: name) { (node, stop) in
            node.isPaused = true
            node.physicsBody?.isDynamic = false
            node.physicsBody?.restitution = 1.0 // The cirlces don't need extra bouncyness for this part. 
        }
    }
    
    func resetSceneVariables(){
        currentScore = 0
    }
    
    


}
