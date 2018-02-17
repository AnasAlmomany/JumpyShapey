//
//  GameOverScene.swift
//  JumpyShapey
//
//  Created by Justin Davis on 2/15/18.
//  Copyright © 2018 Trekk. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
     override func sceneDidLoad() {
        backgroundColor = .black
        
        guard let lastGameScorelabel: SKLabelNode = childNode(withName: "scoreLabel") as? SKLabelNode else {return}
        
        let defaults = UserDefaults.standard
        guard let lastGameScore = defaults.value(forKey: "gameOverScore") else {return}
        lastGameScorelabel.text = "\(lastGameScore)"
        
        guard let highScoreLabel: SKLabelNode = childNode(withName: "highScoreLabel") as? SKLabelNode else {return}
        guard let highScore = defaults.value(forKey: "highScore") else {return}
        highScoreLabel.text = "\(highScore)"

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startButton = childNode(withName: "homeButton") as? SKLabelNode else {return}
        
        for touch in touches {
            let location = touch.location(in: self)
            if startButton .contains(location){
                startButton.fontColor = .green
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
    
     override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startButton = childNode(withName: "homeButton") as? SKLabelNode else {return}
        startButton.fontColor = .white
    }

}
