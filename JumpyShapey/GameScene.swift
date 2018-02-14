//
//  GameScene.swift
//  JumpyShapey
//
//  Created by Justin Davis on 2/13/18.
//  Copyright © 2018 Trekk. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func sceneDidLoad() {
        // A background color is randomly selected at startup
        backgroundColor = randomBackgroundColor()
        setupUI()
        
//            Since I'm using a custom font, I needed to get the name of the font to use it.
//            for family: String in UIFont.familyNames {
//                    print("\(family)")
//
//                for names: String in UIFont.fontNames(forFamilyName: family){
//                        print("== \(names)")
//                    }
//                }
        
    }
    
    func randomBackgroundColor() -> SKColor {
        let colorArray = [SKColor.red, SKColor.yellow, SKColor.blue, SKColor.orange, SKColor.cyan]
        let selectedColor = GKRandomDistribution(lowestValue: 0, highestValue: colorArray.count - 1)
        return colorArray[selectedColor.nextInt()]
    }
    
    func setupUI(){
        // Set the color of the labels so they stand out against the randonly selected
        // background color
        
        switch backgroundColor {
            case SKColor.red:
                setUIColorTo(ThisColor: .white)
            case SKColor.yellow:
                setUIColorTo(ThisColor: .black)
            case SKColor.blue:
                setUIColorTo(ThisColor: .white)
            case SKColor.orange:
                setUIColorTo(ThisColor: .white)
            case SKColor.cyan:
                setUIColorTo(ThisColor: .blue)
            default:
                setUIColorTo(ThisColor: .white)
            }
    }
    
    func setUIColorTo(ThisColor: SKColor){
        // This method sets the UI color to stand out against the randomly selected background color
        // In order to do this we grab a reference to the nodes created in GameScene.sks
        guard let titleLabelOne = childNode(withName: "mainLabelOne") as? SKLabelNode else {return}
        guard let titleLabelTwo = childNode(withName: "mainLabelTwo") as? SKLabelNode else {return}
        guard let startLabel = childNode(withName: "start") as? SKLabelNode else {return}
        guard let copyrightLabel = childNode(withName: "copyrightLabel") as? SKLabelNode else {return}
        
        titleLabelOne.fontColor = ThisColor
        titleLabelTwo.fontColor = ThisColor
        startLabel.fontColor = ThisColor
        copyrightLabel.fontColor = ThisColor
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startButton = childNode(withName: "start") else {return}
        
        for touch in touches {
         let location = touch.location(in: self)
            if startButton .contains(location){
                let transition:SKTransition = SKTransition.moveIn(with: SKTransitionDirection.up, duration: 1.0)
                if let scene = GKScene(fileNamed: "MainGame") {
                    if let sceneNode = scene.rootNode as! MainGame?{
                        sceneNode.scaleMode = .aspectFill
                        self.view?.presentScene(sceneNode, transition: transition)
                    }
                }
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
}
