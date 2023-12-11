//
//  GameScene.swift
//  MushEscape
//
//  Created by Daniele Perrupane on 07/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: - Properties
    
    var ground: SKSpriteNode!
    var player: SKSpriteNode!
    var cameraNode = SKCameraNode()
    var obstacles: [SKSpriteNode] = []
    
    var mushroomRun = SKTexture(imageNamed: "walk1")
    var SurikenAn = SKTexture(imageNamed: "Suriken-1")
    var SpikeAn = SKTexture(imageNamed: "Spike-B_1")
    
    let textures = Textures()
    
    var cameraMovePointPerSecond: CGFloat = 450.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    var scale: CGSize = (CGSize(width: 200, height: 200))
    
    var isTime: CGFloat = 2.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var numberOfJumps = 0
    let maxJumps = 2
    
    var playableRect: CGRect {
        let ratio: CGFloat
        switch UIScreen.main.nativeBounds.height {
        case 2688, 1792, 2436:
            ratio = 2.16
        default:
            ratio = 16/9
        }
        
        let playableHeight = size.width / ratio
        let playableMargin =  (size.height - playableHeight) / 2
        
        return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
    }
    
    var cameraRect: CGRect {
        let width = playableRect.width
        let height = playableRect.height
        let x = cameraNode.position.x - size.width/2.0 + (size.width - width)/2
        let y = cameraNode.position.y - size.height/2.0 + (size.height - height)/2
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    //MARK: - systems
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !isPaused {
            if onGround || numberOfJumps < maxJumps {
                if onGround {
                    // Se il giocatore è a terra, consenti un salto
                    numberOfJumps += 1
                } else if numberOfJumps == 1 {
                    // Se il giocatore è in aria e ha già effettuato il primo salto, consenti il doppio salto solo se è atterrato
                    numberOfJumps += 1
                }
                velocityY = -25
                onGround = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -12.5 {
            velocityY = -12.5
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        
        lastUpdateTime = currentTime
        cameraMove()
        movePlayer()
        
        velocityY += gravity
        player.position.y -= velocityY
        
        if player.position.y < playerPosY {
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
            if onGround {
                numberOfJumps = 0 // Resetta i salti disponibili quando il giocatore è atterrato
            }
        }
    }
}

//MARK: - Configuration

extension GameScene {
    
    func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        setupSpike()
        setupSuriken()
        spawnObstacles()
        setupCamera()
        
        
    }
    
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
    
    func createGround() {
        for i in 0...2 {
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1
            ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 80.0)
            addChild(ground)
        }
    }
    
    func createPlayer() {
        player = SKSpriteNode(texture: mushroomRun)
        let RunAnimation = SKAction.animate(with: textures.mushroomRun, timePerFrame: 0.09)
        let RunMush = SKAction.repeatForever(RunAnimation)
        player.run(RunMush)
        player.name = "Player"
        player.zPosition = 5.0
        player.scale(to: scale)
        player.position = CGPoint(x: 140, y: ground.frame.height + player.frame.height - 45)
        
        playerPosY = player.position.y
        addChild(player)
    }
    
    func setupCamera() {
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    func cameraMove () {
        let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0)
        cameraNode.position += amountToMove
        
        //background
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2  , y: node.position.y)
            }
        }
        
        //ground
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            
            if node.position.x + node.frame.width < self.cameraRect.origin.x {
                node.position = CGPoint(x: node.position.x + node.frame.width*2, y: node.position.y)
            }
        }
    }
    
    func movePlayer() {
        let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
        player.position.x += amountToMove
    }
    
    func setupSuriken() {
        let suriken = SKSpriteNode(texture: SurikenAn)
        let surikenAn = SKAction.animate(with: textures.Suriken, timePerFrame: 0.09)
        let AnSuriken = SKAction.repeatForever(surikenAn)
        suriken.run(AnSuriken)
        suriken.scale(to: scale)
        suriken.name = "Suriken"
        obstacles.append(suriken)
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let surikenR = obstacles[index].copy() as! SKSpriteNode
        surikenR.zPosition = 5.0
        surikenR.position = CGPoint(x: cameraRect.maxX + surikenR.frame.width/2, y: ground.frame.height + player.frame.height - 45)
        addChild(surikenR)
        surikenR.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    func setupSpike() {
        
        let spike = SKSpriteNode(texture: SpikeAn)
        let spikeAn = SKAction.animate(with: textures.Spike, timePerFrame: 0.09)
        let AnSpike = SKAction.repeatForever(spikeAn)
        spike.run(AnSpike)
        spike.scale(to: scale)
        spike.name = "Spike"
        obstacles.append(spike)
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let spikeR = obstacles[index].copy() as! SKSpriteNode
        spikeR.zPosition = 5.0
        spikeR.position = CGPoint(x: cameraRect.maxX + spikeR.frame.width/2, y: ground.frame.height + spikeR.frame.height - 45)
        addChild(spikeR)
        spikeR.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    
    func spawnObstacles() {
        let random = Double(CGFloat.random(min: 1.0, max: isTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupSpike()
                self?.setupSuriken()
            }
            
        ])))
        
        run(.repeatForever(.sequence([
            .wait(forDuration: 5),
            .run {
                self.isTime -= 0.01
                
                if self.isTime <= 1.5 {
                    self.isTime = 1.5
                }
            }
        ])))
    }
    
}
