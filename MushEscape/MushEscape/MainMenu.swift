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
    var highScoreLabel: SKLabelNode!
    var lastScoreLabel: SKLabelNode!
    
    var elapsedTime: TimeInterval = 0
    
    //MARK: - Systems
    
    override func didMove(to view: SKView){
        setupBG()
        setupGrounds()
        highScore()
        lastScore()
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
            setupSetting()
        } else if node.name == "container" {
            containerNode.removeFromParent()
        
        } else if node.name == "music" {
            let node = node as! SKSpriteNode
            SKTAudio.musicEnabled = !SKTAudio.musicEnabled
            node.texture = SKTexture(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
            
        } else if node.name == "effect" {
            let node = node as! SKSpriteNode
            effectEnabled = !effectEnabled
            node.texture = SKTexture(imageNamed: effectEnabled ? "effectOn" : "effectOff")
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
    
    func highScore() {
        let storedHighScore = UserDefaults.standard.integer(forKey: "HighestScore")
        let minutes = Int(storedHighScore) / 60
        let seconds = Int(storedHighScore) % 60
        highScoreLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
        highScoreLabel.text = String(format: "Your highest score: %02d:%02d", minutes, seconds)
        highScoreLabel.fontSize = 65
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: 1000, y: 930)
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
        
        let storedHighScore1 = UserDefaults.standard.integer(forKey: "HighestScore")
        highScoreLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
        highScoreLabel.text = String(format: "Your highest score: %02d:%02d", minutes, seconds)
        highScoreLabel.fontSize = 65
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.position = CGPoint(x: 997, y: 929)
        highScoreLabel.zPosition = 19
        addChild(highScoreLabel)
    }
    
    func lastScore() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        lastScoreLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
//        lastScoreLabel.text = "Your latest score:\(elapsedTime)"
        lastScoreLabel.text = String(format: "Your latest score: %02d:%02d", minutes, seconds)
        lastScoreLabel.fontSize = 50
        lastScoreLabel.fontColor = SKColor.white
        lastScoreLabel.position = CGPoint(x: 1000, y: 840)
        lastScoreLabel.zPosition = 20
        addChild(lastScoreLabel)
        
        lastScoreLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
//        lastScoreLabel.text = "Your latest score:\(elapsedTime)"
        lastScoreLabel.text = String(format: "Your latest score: %02d:%02d", minutes, seconds)
        lastScoreLabel.fontSize = 50
        lastScoreLabel.fontColor = SKColor.black
        lastScoreLabel.position = CGPoint(x: 997, y: 839)
        lastScoreLabel.zPosition = 19
        addChild(lastScoreLabel)
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
        play.position = CGPoint(x: size.width/2.0, y: size.height/2.0 + play.frame.height - 230)
        addChild(play)
        

        
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "setting"
        setting.setScale(0.85)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: size.width/2.0, y: size.height/2.0 - setting.size.height - 100)
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
    
    func setupSetting() {
        setupContainer()
        
        //Panel
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        //Music
        let music = SKSpriteNode(imageNamed: SKTAudio.musicEnabled ? "musicOn" : "musicOff")
        music.name = "music"
        music.setScale(0.7)
        music.zPosition = 25.0
        music.position = CGPoint(x: -music.frame.width - 50.0, y: 0.0)
        panel.addChild(music)
        
        //Sound
        let effect = SKSpriteNode(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        effect.name = "effect"
        effect.setScale(0.7)
        effect.zPosition = 25.0
        effect.position = CGPoint(x: music.frame.width + 50.0, y: 0.0)
        panel.addChild(effect)
    }
}

