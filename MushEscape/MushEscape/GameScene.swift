//
//  GameScene.swift
//  MushEscape
//
//  Created by Daniele Perrupane on 07/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
        private var character: SKSpriteNode?
        
    
    
    
        override func didMove(to view: SKView) {
            // Creare uno sprite node con un'immagine dagli assets
            character = SKSpriteNode(imageNamed: "mushroom")
            character?.position = CGPoint(x: size.width / 2, y: size.height / 2)
                    addChild(character!)
            
            
            
            
        }
    
    
    
    func touchDown(atPoint pos: CGPoint) {
        if let characterCopy = self.character?.copy() as? SKSpriteNode {
            characterCopy.position = pos
            characterCopy.color = SKColor.green // Colore di sfondo del personaggio
            self.addChild(characterCopy)
        }
    }

    func touchMoved(toPoint pos: CGPoint) {
        if let characterCopy = self.character?.copy() as? SKSpriteNode {
            characterCopy.position = pos
            characterCopy.color = SKColor.blue
            self.addChild(characterCopy)
        }
    }

    func touchUp(atPoint pos: CGPoint) {
        if let characterCopy = self.character?.copy() as? SKSpriteNode {
            characterCopy.position = pos
            characterCopy.color = SKColor.red
            self.addChild(characterCopy)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchDown(atPoint: touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchMoved(toPoint: touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchUp(atPoint: touch.location(in: self))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            self.touchUp(atPoint: touch.location(in: self))
        }
    }

}
