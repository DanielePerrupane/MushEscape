//
//  GameOverPopUp.swift
//  MushEscape
//
//  Created by Daniele Perrupane on 12/12/23.
//

import Foundation
import SpriteKit

class GameOverPopUp : SKNode {

    var titleLabel: SKLabelNode!
    var imageView: SKSpriteNode!
    var highScoreLabel: SKLabelNode!
    var lastScoreLabel: SKLabelNode!

    override init() {

        super.init()

        // Imposta il titolo
        titleLabel = SKLabelNode(fontNamed: "mushescape")
        titleLabel.text = "YOU DIED"
        titleLabel.fontSize = 36
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: 0, y: 350)
        titleLabel.zPosition = 20
        addChild(titleLabel)

        // Aggiungi l'immagine (sostituisci "yourImageName" con il nome effettivo dell'immagine)
        imageView = SKSpriteNode(imageNamed: "4_mushy")
        imageView.position = CGPoint(x: 0, y: 0)
        imageView.zPosition = 20
        addChild(imageView)

        // Etichetta per il record più alto
        highScoreLabel = SKLabelNode(fontNamed: "mushescape")
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: 0, y: -30)
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)

        // Etichetta per l'ultimo record
        lastScoreLabel = SKLabelNode(fontNamed: "mushescape")
        lastScoreLabel.fontSize = 20
        lastScoreLabel.fontColor = SKColor.white
        lastScoreLabel.position = CGPoint(x: 0, y: -50)
        lastScoreLabel.zPosition = 20
        addChild(lastScoreLabel)

        // Nascondi il pop-up inizialmente
        isHidden = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
