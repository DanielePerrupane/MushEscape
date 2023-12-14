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
    var obstaclesSpike : [SKSpriteNode] = []
    var obstaclesDog : [SKSpriteNode] = []
    var obstaclesBird : [SKSpriteNode] = []
    var dog: SKSpriteNode!
    var bird: SKSpriteNode!
    
    var mushroomRun = SKTexture(imageNamed: "walk1")
    var LongWoodAn = SKTexture(imageNamed: "long_wood_spike_01")
    var DogAn = SKTexture(imageNamed: "dog1")
    var BirdAn = SKTexture(imageNamed: "bird1")
    var mushroomDead = SKTexture(imageNamed: "1_mushy")
    
    let textures = Textures()
    
    var cameraMovePointPerSecond: CGFloat = 450.0
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    var playerS: CGSize = (CGSize(width: 180, height: 180))
    var spikeS: CGSize = (CGSize(width: 80, height: 400))
    var dogS: CGSize = (CGSize(width: 300, height: 300))
    var BirdS: CGSize = (CGSize(width: 200, height: 200))
    
    //Properties TIMER
    var elapsedTime: TimeInterval = 0
    var timerLabel: SKLabelNode!
    var timerLabel1: SKLabelNode!
    var isTimerPaused = false
    
    var isTime: CGFloat = 2.0
    var isTimeD: CGFloat = 5.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var numberOfJumps = 0
    let maxJumps = 2
    
//    var bgMusic = SKAction.playSoundFileNamed("backgroundmusic.mp3")

    var soundJump = SKAction.playSoundFileNamed("jump.mp3")
      
    var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
      
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
        SKTAudio.shared.playBGMusic("backgroundmusic.mp3")
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
                velocityY = -22
                onGround = false
                run(soundJump)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if velocityY < -10.5 {
            velocityY = -10.5
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
    func stopBackgroundMusic() {
              SKTAudio.musicEnabled = false
          }
}

//MARK: - Configuration

extension GameScene {
    
    func setupNodes() {
        createBG()
        createGround()
        createPlayer()
        setupTimer()
        setupSpike()
        setupDog()
        setupBird()
        spawnObstacles()
        spawnBird()
        spawnDog()
        setupPhysics()
        setupCamera()
        
        
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
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
        player.scale(to: playerS)
        player.position = CGPoint(x: 190, y: ground.frame.height + player.frame.height - 35)
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 140, height: 115))
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacles
        
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
        timerLabel.position.x += amountToMove
        timerLabel1.position.x += amountToMove
    }
    
    func setupPause() {
        pauseNode = SKSpriteNode(imageNamed: "pausebutton")
        pauseNode.setScale(0.5)
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        pauseNode.position = CGPoint(x: playableRect.width/2.0 - pauseNode.frame.width/2.0 - 30.0, y: playableRect.height/2.0 - pauseNode.frame.height/2.0 - 10.0)
        cameraNode.addChild(pauseNode)
    }
    
    func createPanel() {
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(imageNamed: "panel")
        panel.zPosition = 60.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale(0.7)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + resume.frame.width*1.5, y:0.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "back")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.setScale(0.7)
        quit.position = CGPoint(x: panel.frame.width/2.0 - quit.frame.width*1.5, y: 0.0)
        panel.addChild(quit)
    }
    
    //MARK: - Obstacles Function
    func setupBird() {
        bird = SKSpriteNode(texture: BirdAn)
        let BirdAn = SKAction.animate(with: textures.Bird, timePerFrame: 0.09)
        let AnBird = SKAction.repeatForever(BirdAn)
        bird.run(AnBird)
        bird.scale(to: BirdS)
        bird.zPosition = 5.0
        bird.name = "Bird"
        obstaclesBird.append(bird)
        
        let index = Int(arc4random_uniform(UInt32(obstaclesBird.count)))
        let BirdR = obstaclesBird[index].copy() as! SKSpriteNode
        BirdR.zPosition = 10.0
        let randomY = CGFloat.random(in: 800...1150)
        BirdR.position = CGPoint(x: cameraRect.maxX + 2060, y: randomY)
        let baseDuration: TimeInterval = 10.0
        let randomFactor: TimeInterval = TimeInterval.random(in: 9.0...11.0)
        let moveDuration = baseDuration + randomFactor
        let destinationPoint = CGPoint(x: -1000,y: randomY)
        let moveAction = SKAction.move(to: destinationPoint, duration: moveDuration)
        BirdR.run(moveAction)
        BirdR.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 70))
        BirdR.physicsBody!.affectedByGravity = false
        BirdR.physicsBody!.isDynamic = false
        BirdR.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        BirdR.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(BirdR)
        BirdR.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    func spawnBird() {
        let random = Double(CGFloat.random(min: 3.0, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupBird()
            }
            
        ])))
    }
    
    func setupDog() {
        dog = SKSpriteNode(texture: DogAn)
        let DogAn = SKAction.animate(with: textures.Dog, timePerFrame: 0.09)
        let AnDog = SKAction.repeatForever(DogAn)
        dog.run(AnDog)
        dog.scale(to: dogS)
        dog.zPosition = 5.0
        dog.name = "Dog"
        obstaclesDog.append(dog)
        
        let index = Int(arc4random_uniform(UInt32(obstaclesDog.count)))
        let DogR = obstaclesDog[index].copy() as! SKSpriteNode
        DogR.zPosition = 10.0
        DogR.position = CGPoint(x: cameraRect.maxX + 2060, y: ground.frame.height + player.frame.height + 10)
        let baseDuration: TimeInterval = 10.0 // Base duration for movement
        let randomFactor: TimeInterval = TimeInterval.random(in: 9.0...11.0) // Random factor
        let moveDuration = baseDuration + randomFactor
        let destinationPoint = CGPoint(x: -1000,y: ground.frame.height + DogR.frame.height - 50)
        let moveAction = SKAction.move(to: destinationPoint, duration: moveDuration)
        DogR.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 20))
        DogR.physicsBody!.affectedByGravity = false
        DogR.physicsBody!.isDynamic = false
        DogR.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        DogR.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        DogR.run(moveAction)
        addChild(DogR)
        DogR.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    func spawnDog() {
        let random = Double(CGFloat.random(min: 3.0, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupDog()
            }
            
        ])))
    }
    
    
    func setupSpike() {
        
        let spike = SKSpriteNode(imageNamed: "long_wood_spike_05")
        //        let spikeAn = SKAction.animate(with: textures.LongWood, timePerFrame: 0.2)
        //        let AnSpike = SKAction.repeatForever(spikeAn)
        //        spike.run(AnSpike)
        spike.scale(to: spikeS)
        spike.name = "Spike"
        obstaclesSpike.append(spike)
        
        let index = Int(arc4random_uniform(UInt32(obstaclesSpike.count-1)))
        let spikeR = obstaclesSpike[index].copy() as! SKSpriteNode
        spikeR.zPosition = 5.0
        let randomY = CGFloat.random(in: -300 ... -200)
        spikeR.position = CGPoint(x: cameraRect.maxX + CGFloat.random(in: 0...size.width), y: ground.frame.height + spikeR.frame.height + randomY)
        spikeR.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 235))
        spikeR.physicsBody!.affectedByGravity = false
        spikeR.physicsBody!.isDynamic = false
        spikeR.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        spikeR.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(spikeR)
        spikeR.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    
    func spawnObstacles() {
        let random = Double(CGFloat.random(min: 1.5, max: isTime))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                self?.setupSpike()
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
    
    //MARK: - Timer Function
    
    func startTimer() {
        // Esegui un'azione che incrementa il tempo ogni secondo
        let waitAction = SKAction.wait(forDuration: 1)
        let updateAction = SKAction.run { [weak self] in
            guard let self = self, !self.isTimerPaused else { return }
            self.elapsedTime += 1
            self.updateTimerLabel()
        }
        let sequenceAction = SKAction.sequence([waitAction, updateAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        run(repeatAction, withKey: "timerAction")
    }
    
    func updateTimerLabel() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        timerLabel1.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func createTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "VCR OSD Mono")
        timerLabel.name = "TimerLabel"
        timerLabel.text = "00:00"
        timerLabel.zPosition = 5.0
        timerLabel.fontSize = 100
        timerLabel.position = CGPoint(x: 1000, y: 1100)
        addChild(timerLabel)
        
        timerLabel1 = SKLabelNode(fontNamed: "VCR OSD Mono")
        timerLabel1.name = "TimerLabel"
        timerLabel1.text = "00:00"
        timerLabel1.zPosition = 4.0
        timerLabel1.fontSize = 105
        timerLabel1.fontColor = .black
        timerLabel1.position = CGPoint(x: 1010, y: 1095)
        addChild(timerLabel1)
        
        
    }
    
    
    func setupTimer() {
        createTimerLabel()
        startTimer()
    }
    
    //MARK: - Game Over Function
    
    func setupGameOver() {

//        let highScore = elapsedTime // Recupera il tuo record più alto
//        let lastScore = elapsedTime // O il tempo dell'ultima partita
        
        player.removeAllActions()
        let RunAnimation = SKAction.animate(with: textures.mushroomDead, timePerFrame: 0.3)
        player.run(RunAnimation)
    }
    
    
}

//MARK: -SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Obstacles:
            isTimerPaused = true
            cameraMovePointPerSecond = 0
            setupGameOver()
            
            let storedHighScore = UserDefaults.standard.integer(forKey: "HighestScore")
                
            if elapsedTime > TimeInterval(storedHighScore) {
                UserDefaults.standard.set(elapsedTime, forKey: "HighestScore")
            }

            
            let delay = SKAction.wait(forDuration: 2)
            let action = SKAction.run {
                let scene = GameOverPopUp(size: self.size)
                scene.elapsedTime = self.elapsedTime
                scene.scaleMode = self.scaleMode
                self.view!.presentScene(scene)
            }
            
            let sequency = SKAction.sequence([delay, action])
            
            self.run(sequency)
            
            
        default:
            break
        }
    }
}

