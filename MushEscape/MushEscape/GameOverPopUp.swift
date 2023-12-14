//
//  GameOverPopUp.swift
//  MushEscape
//
//  Created by Daniele Perrupane on 12/12/23.
//

import Foundation
import SpriteKit

//MARK: - System

class GameOverPopUp : SKScene {
    
    var titleLabel: SKLabelNode!
    var imageView: SKSpriteNode!
    var highScoreLabel: SKLabelNode!
    var lastScoreLabel: SKLabelNode!
    var playerS: CGSize = (CGSize(width: 180, height: 180))
    
    var elapsedTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        createBG()
        setupTable()
        setupTitle()
        setupImage()
        highScore()
        lastScore()
        createPanel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "resume" {
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene)
            
        } else if node.name == "quit" {
            let scene = MainMenu(size: size)
            scene.elapsedTime = self.elapsedTime
            scene.scaleMode = scaleMode
            view!.presentScene(scene)
        }
    }
}
    //MARK: -Configuration
    
    extension GameOverPopUp {
        
        // imposta background
        func createBG() {
            for i in 0...2 {
                let bg = SKSpriteNode(imageNamed: "background")
                bg.name = "BG"
                bg.anchorPoint = .zero
                bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 100.0)
                bg.zPosition = -1
                addChild(bg)
            }
            
        }
        // imposta tabella
        func setupTable() {
            let table = SKSpriteNode(color: .black, size: CGSize(width: 2100, height: 1540))
            table.position = CGPoint(x: 1000, y: 750)
            table.zPosition = 10
            table.alpha = 0.5
            addChild(table)
        }
        
        // imposta bottoni
        func createPanel() {
            
            let resume = SKSpriteNode(imageNamed: "effectOn")
            resume.zPosition = 70.0
            resume.name = "resume"
            resume.setScale(0.7)
            resume.position = CGPoint(x: 750, y: 500)
            addChild(resume)
            
            let quit = SKSpriteNode(imageNamed: "effectOff")
            quit.zPosition = 70.0
            quit.name = "quit"
            quit.setScale(0.7)
            quit.position = CGPoint(x: 1250, y: 500)
            addChild(quit)
        }
        
        // Imposta il titolo
        func setupTitle() {
            titleLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
            titleLabel.text = "YOU DIED"
            titleLabel.fontSize = 100
            titleLabel.fontColor = SKColor.white
            titleLabel.position = CGPoint(x: 1000, y: 1100)
            titleLabel.zPosition = 20
            addChild(titleLabel)
        }
        
        // Aggiungi l'immagine (sostituisci "yourImageName" con il nome effettivo dell'immagine)
        func setupImage() {
            imageView = SKSpriteNode(imageNamed: "4_mushy")
            imageView.position = CGPoint(x: 1000, y: 950)
            imageView.scale(to: playerS)
            imageView.zPosition = 20
            addChild(imageView)
        }
        
        // Etichetta per il record più alto
        func highScore() {
            let storedHighScore = UserDefaults.standard.integer(forKey: "HighestScore")
            let minutes = Int(storedHighScore) / 60
            let seconds = Int(storedHighScore) % 60
            highScoreLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
            highScoreLabel.text = String(format: "Your highest score: %02d:%02d", minutes, seconds)
            highScoreLabel.fontSize = 40
            highScoreLabel.fontColor = SKColor.white
            highScoreLabel.position = CGPoint(x: 1000, y: 780)
            highScoreLabel.zPosition = 20
            addChild(highScoreLabel)
        }
        
        // Etichetta per l'ultimo record
        func lastScore() {
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            lastScoreLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
            lastScoreLabel.text = String(format: "Your latest score: %02d:%02d", minutes, seconds)
            lastScoreLabel.fontSize = 40
            lastScoreLabel.fontColor = SKColor.white
            lastScoreLabel.position = CGPoint(x: 1000, y: 700)
            lastScoreLabel.zPosition = 20
            addChild(lastScoreLabel)
        }
        
        // Nascondi il pop-up inizialmente
        func hidePopup() {
            isHidden = true
        }
        
        func showPopup(highScore: TimeInterval, lastScore: TimeInterval) {
            // Aggiorna le etichette con i record
            highScoreLabel.text = "High Score: \(formatTime(time: highScore))"
            lastScoreLabel.text = "Last Score: \(formatTime(time: lastScore))"
            
            // Mostra il pop-up
            isHidden = false
        }
        
        // Funzione per formattare il tempo in mm:ss
        func formatTime(time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    
    
    
