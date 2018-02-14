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

class MainGame: SKScene {
    
    
    
     override func sceneDidLoad() {
        backgroundColor = randomBackgroundColor()
        setupUI()
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
        
        let floorNode = childNode(withName: "floor") as! SKSpriteNode
        let heroNode = childNode(withName: "hero") as! SKSpriteNode
        let scoreNode = childNode(withName: "score") as! SKLabelNode
        
        switch backgroundColor {
        case SKColor.red:
            floorNode.color = .cyan
            heroNode.color = .yellow
            scoreNode.fontColor = .white
        case SKColor.yellow:
            floorNode.color = .blue
            heroNode.color = .red
            scoreNode.fontColor = .black
        case SKColor.blue:
            floorNode.color = .red
            heroNode.color = .cyan
            scoreNode.fontColor = .yellow
        case SKColor.orange:
            floorNode.color = .blue
            heroNode.color = .green
            scoreNode.fontColor = .blue
        case SKColor.cyan:
            floorNode.color = .red
            heroNode.color = .purple
            scoreNode.color = .purple
        default:
            floorNode.color = .white
        }
    }
    
    func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture(tap:)))
        view?.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleGesture(tap: UITapGestureRecognizer){
        let heroNode = childNode(withName: "hero")
        var isJumping = false;
        
        if !isJumping{
            heroNode?.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 250.0))
            isJumping = true
        }
        
        if tap.state == .ended {
            isJumping = false
        }
        
    }
    
    
    
    

}
