//
//  GameViewController.swift
//  JumpyShapey
//
//  Created by Justin Davis on 2/13/18.
//  Copyright © 2018 Trekk. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    
    let leaderboardID = "jumpyshapeyleaderboard"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateWithGameCenter()
        
        NotificationCenter.default .addObserver(self, selector: #selector(GameViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "leaderboard"), object: nil)
        NotificationCenter.default .addObserver(self, selector: #selector(GameViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "reportScore"), object: nil)
        
        
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = false
                    view.showsNodeCount = false
                }
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // GameCenter Methods
    func authenticateWithGameCenter() { // Authenticates player
        // called inside viewDidLoad
        
        GKLocalPlayer.localPlayer().authenticateHandler = {
            viewController, error in
            
            guard let vc = viewController else { return }
            
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    func reportHighScore(_ score: Int){ // Reports high school
        if GKLocalPlayer.localPlayer().isAuthenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
            scoreReporter.value = Int64(score)
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: { error in
                guard error == nil else {return}
                print("High Score Reported")
            })
            
        }
    }
    
    func showLeaderboard(){
        // called through local NSNotification - Shows leaderboard
        let vc = GKGameCenterViewController()
        vc.leaderboardIdentifier = self.leaderboardID
        vc.gameCenterDelegate = self
        vc.viewState = GKGameCenterViewControllerState.leaderboards
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController){
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNotification(_ notification: Notification){
        if notification.name.rawValue == "leaderboard"{
            showLeaderboard()
        }else if notification.name.rawValue == "reportScore"{
            let defaults = UserDefaults.standard
            let highScore: Int = defaults.integer(forKey: "highScore")
            reportHighScore(highScore)
        }
    }
    


}
