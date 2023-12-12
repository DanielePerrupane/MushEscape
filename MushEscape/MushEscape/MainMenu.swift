//
//  MainMenu.swift
//  FungitopiaDevelopment
//
//  Created by manuel on 08/12/23.
//

import SpriteKit

class MainMenu: SKScene {
    
    
    //MARK: - Properties
    
    var containerNode: SKSpriteNode!
    
    //MARK: - Systems
    
    override func didMove(to view: SKView){
        setupBG()
        setupGrounds()
        setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsOpenVertical(withDuration: 0.3))
            
        } else if node.name == "highscore" {
            setupPanel()
        } else if node.name == "setting" {
        } else if node.name == "container" {
            containerNode.removeFromParent()
        
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveGrounds()
    }
}

//MARK: - Configurations

extension MainMenu {
    
    func setupBG() {
        let bgNode = SKSpriteNode(imageNamed: "bgmenu")
        bgNode.zPosition = -1.0
        bgNode.anchorPoint = .zero
        bgNode.position = CGPoint(x: -250.0, y: -200)
        addChild(bgNode)
    }
    
    func setupGrounds() {
        for i in 0...2 {
            let groundNode = SKSpriteNode(imageNamed: "ground")
            groundNode.name = "ground"
            groundNode.anchorPoint = .zero
            groundNode.zPosition = 1.0
            groundNode.position = CGPoint(x: -CGFloat(i)*groundNode.frame.width, y: 0.0)
            addChild(groundNode)
        }
    }
    
    func moveGrounds() {
        enumerateChildNodes(withName: "ground") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= 8.0
            
            if node.position.x < -self.frame.width {
                node.position.x += node.frame.width*2.0
            }
        }
    }
    
    func setupNodes() {
        let play = SKSpriteNode(imageNamed: "play")
        play.name = "play"
        play.setScale(0.85)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/2.0, y: size.height/2.0 + play.frame.height - 160)
        addChild(play)
        

        
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "setting"
        setting.setScale(0.85)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - setting.size.height - 50)
        addChild(setting)
    }
    
    func setupPanel() {
        setupContainer()
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        //Highscore
        let x = -panel.frame.width/2.0 + 250.0
        let highscoreLbl = SKLabelNode(fontNamed: "SF Pro")
        //highscoreLbl.text = "Highscore: \(ScoreGenerator.sharedInstance.getHighscore())"
        highscoreLbl.horizontalAlignmentMode = .left
        highscoreLbl.fontSize = 80.0
        highscoreLbl.zPosition = 25.0
        highscoreLbl.position = CGPoint(x: x, y: highscoreLbl.frame.height/2.0 - 30.0)
        panel.addChild(highscoreLbl)
        
        let scoreLbl = SKLabelNode(fontNamed: "SF Pro")
        //scoreLbl.text = "Score: \(ScoreGenerator.sharedInstance.getHighscore())"
        scoreLbl.horizontalAlignmentMode = .left
        scoreLbl.fontSize = 80.0
        scoreLbl.zPosition = 25.0
        scoreLbl.position = CGPoint(x: x, y: -scoreLbl.frame.height - 30)
        panel.addChild(scoreLbl)
    }
    
    func setupContainer() {
        containerNode = SKSpriteNode()
        containerNode.name = "container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(containerNode)
    }
    
}

