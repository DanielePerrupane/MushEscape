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
    var gems: SKSpriteNode!
    var border: SKSpriteNode!
    var progressBar: SKSpriteNode!
    var textProgress: SKLabelNode!
    var textProgress1: SKLabelNode!
    var cameraNode = SKCameraNode()
    var dog: SKSpriteNode!
    var bird: SKSpriteNode!
    var shark: SKSpriteNode!
    var hyena: SKSpriteNode!
    var bg: SKSpriteNode!
    var bgD: SKSpriteNode!
    var bgDNodes = [SKSpriteNode]()
    
    var generateObstacles = true
    var generateObstaclesD = false
    var generateGems = true
    
    
    var timeSinceLastSpeedIncrease: TimeInterval = 0.0
    let speedIncreaseInterval: TimeInterval = 30.0 // Interval for increasing speed (30 seconds)
    let speedIncreaseAmount: CGFloat = 50.0 // Amount by which the speed will increase
    
    var mushroomRun = SKTexture(imageNamed: "walk1")
    var LongWoodAn = SKTexture(imageNamed: "long_wood_spike_01")
    var DogAn = SKTexture(imageNamed: "dog1")
    var BirdAn = SKTexture(imageNamed: "bird1")
    var mushroomDead = SKTexture(imageNamed: "1_mushy")
    var Gems = SKTexture(imageNamed: "gems_1")
    var mushroomRainbow = SKTexture(imageNamed: "walk1")
    var BgDistorted = SKTexture(imageNamed: "distortedbg1")
    var Hyena = SKTexture(imageNamed: "hyena1")
    var Shark = SKTexture(imageNamed: "shark1")
    
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
    var isAccelerated = false
    
    var isTime: CGFloat = 2.0
    var isTimeD: CGFloat = 5.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    var numberOfJumps = 0
    let maxJumps = 2
    var collectedGem = 0
    let maxGems = 10
    
    //    var bgMusic = SKAction.playSoundFileNamed("backgroundmusic.mp3")
    
    var soundJump = SKAction.playSoundFileNamed("jump.mp3")
    var gemCollected = SKAction.playSoundFileNamed("gem")
    
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
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "pause" {
            if isPaused { return }
            createPanel()
            lastUpdateTime = 0.0
            dt = 0.0
            isPaused = true
            
        } else if node.name == "resume" {
            containerNode.removeFromParent()
            isPaused = false
            
        } else if node.name == "quit" {
            let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene) }
        else {
            
            if !isPaused {
                if onGround || numberOfJumps < maxJumps {
                    if onGround {
                        // Se il giocatore è a terra, consenti un salto
                        numberOfJumps += 1
                    } else if numberOfJumps == maxJumps {
                        // Se il giocatore è in aria e ha già effettuato il primo salto, consenti il doppio salto solo se è atterrato
                        numberOfJumps = 1
                    }
                    velocityY = -25
                    onGround = false
                    run(soundJump)
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
        
        timeSinceLastSpeedIncrease += dt
        if timeSinceLastSpeedIncrease >= speedIncreaseInterval {
            cameraMovePointPerSecond += speedIncreaseAmount
            timeSinceLastSpeedIncrease = 0.0 // Reset the timer
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
        setupBorder()
        setupTimer()
        setupGems()
        setupProgressBar()
        setupSpike()
        setupDog()
        setupBird()
        spawnGems()
        spawnObstacles()
        spawnBird()
        spawnDog()
        setupPhysics()
        setupPause()
        setupCamera()
    }
    
    func setupPhysics() {
        physicsWorld.contactDelegate = self
    }
    
    func createBG() {
        for i in 0...2 {
            bg = SKSpriteNode(imageNamed: "background")
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
    
    func setupBorder() {
        // Crea uno sprite con un rettangolo trasparente
        border = SKSpriteNode(color: UIColor.red, size: CGSize(width: 2048, height: 500))
        border.alpha = 0.0 // Imposta l'alpha a 0 per renderlo completamente trasparente
        border.position = CGPoint(x: 1000, y: 1490)
        border.zPosition = 10
        border.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2048, height: 500))
        border.physicsBody!.affectedByGravity = false
        border.physicsBody!.isDynamic = false
        border.physicsBody!.restitution = 0.0
        border.physicsBody!.categoryBitMask = PhysicsCategory.Border
        border.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(border)
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
        player.physicsBody!.contactTestBitMask = PhysicsCategory.Obstacles | PhysicsCategory.Gems
        
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
        
        enumerateChildNodes(withName: "bg") { (node, _) in
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
        border.position.x += amountToMove
        timerLabel1.position.x += amountToMove
        progressBar.position.x += amountToMove
        textProgress.position.x += amountToMove
        textProgress1.position.x += amountToMove
    }
    
    func setupPause() {
        pauseNode = SKSpriteNode(imageNamed: "pausebutton")
        pauseNode.setScale(1.0) // Adjust the scale as needed
        pauseNode.zPosition = 50.0
        pauseNode.name = "pause"
        
        pauseNode.position = CGPoint(x: cameraRect.minX + 1900, y: cameraRect.maxY - 200)
        
        cameraNode.addChild(pauseNode)
    }
    
    func createPanel() {
        cameraNode.addChild(containerNode)
        
        let panel = SKSpriteNode(color: .black, size: CGSize(width: 2100, height: 1540))
        panel.zPosition = 60.0
        panel.position = .zero
        panel.alpha = 0.5
        containerNode.addChild(panel)
        
        let pause = SKLabelNode(fontNamed: "VCR OSD Mono")
        pause.zPosition = 70.0
        pause.text = "PAUSE"
        pause.name = "name"
        pause.alpha = 100.0
        pause.fontSize = 200
        pause.position = CGPoint(x: 10.0, y:100.0)
        panel.addChild(pause)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.zPosition = 70.0
        resume.name = "resume"
        resume.setScale(1.7)
        resume.alpha = 100.0
        resume.position = CGPoint(x: -200, y: -150.0)
        panel.addChild(resume)
        
        let quit = SKSpriteNode(imageNamed: "home")
        quit.zPosition = 70.0
        quit.name = "quit"
        quit.alpha = 100.0
        quit.setScale(1.7)
        quit.position = CGPoint(x: 200, y: -150.0)
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
        let randomY = CGFloat.random(in: 800...1150)
        bird.position = CGPoint(x: cameraRect.maxX + 2060, y: randomY)
        let baseDuration: TimeInterval = 10.0
        let randomFactor: TimeInterval = TimeInterval.random(in: 10...15)
        let moveDuration = baseDuration + randomFactor
        let destinationPoint = CGPoint(x: -1000,y: randomY)
        let moveAction = SKAction.move(to: destinationPoint, duration: moveDuration)
        bird.run(moveAction)
        bird.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 70))
        bird.physicsBody!.affectedByGravity = false
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        bird.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(bird)
        bird.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    func spawnBird() {
        let random = Double(CGFloat.random(min: 3.0, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                if self?.generateObstacles ?? false {
                    self?.setupBird()
                }
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
        dog.position = CGPoint(x: cameraRect.maxX + 2060, y: ground.frame.height + player.frame.height + 10)
        let baseDuration: TimeInterval = 10.0 // Base duration for movement
        let randomFactor: TimeInterval = TimeInterval.random(in: 10.0...15.0) // Random factor
        let moveDuration = baseDuration + randomFactor
        let destinationPoint = CGPoint(x: -1000,y: ground.frame.height + dog.frame.height - 50)
        let moveAction = SKAction.move(to: destinationPoint, duration: moveDuration)
        dog.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 20))
        dog.physicsBody!.affectedByGravity = false
        dog.physicsBody!.isDynamic = false
        dog.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        dog.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        dog.run(moveAction)
        addChild(dog)
        dog.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    func spawnDog() {
        let random = Double(CGFloat.random(min: 3.0, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                if self?.generateObstacles ?? false {
                    self?.setupDog()
                }
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
        spike.zPosition = 5.0
        let randomY = CGFloat.random(in: -300 ... -200)
        spike.position = CGPoint(x: cameraRect.maxX + CGFloat.random(in: 0...size.width), y: ground.frame.height + spike.frame.height + randomY)
        spike.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 235))
        spike.physicsBody!.affectedByGravity = false
        spike.physicsBody!.isDynamic = false
        spike.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        spike.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(spike)
        spike.run(.sequence([
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
    
    func setupGems() {
        gems = SKSpriteNode(texture: Gems)
        let GemAn = SKAction.animate(with: textures.Gems, timePerFrame: 0.09)
        let AnGem = SKAction.repeatForever(GemAn)
        gems.run(AnGem)
        gems.zPosition = 5.0
        gems.setScale(5)
        let randomY = CGFloat.random(in: 200 ... 600)
        gems.position = CGPoint(x: cameraRect.maxX + CGFloat.random(in: 0...size.width), y: ground.frame.height + randomY)
        gems.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 90))
        gems.physicsBody!.affectedByGravity = false
        gems.physicsBody!.isDynamic = false
        gems.physicsBody!.categoryBitMask = PhysicsCategory.Gems
        gems.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(gems)
        gems.run(.sequence([
            .wait(forDuration: 15),
            .removeFromParent()
        ]))
    }
    
    func spawnGems() {
        _ = Double(CGFloat.random(min: 1.0, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: 2),
            .run { [weak self] in
                if self?.generateGems ?? false {
                    self?.setupGems()
                }
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
    
    func setupProgressBar() {
        textProgress = SKLabelNode(fontNamed: "VCR OSD Mono")
        textProgress.zPosition = 4.0
        textProgress.text = "Go to a new dimension"
        textProgress.fontColor = .black
        textProgress.position = CGPoint(x: 295, y: 1145)
        textProgress.fontSize = 40
        addChild(textProgress)
        
        textProgress1 = SKLabelNode(fontNamed: "VCR OSD Mono")
        textProgress1.zPosition = 5.0
        textProgress1.text = "Go to a new dimension"
        textProgress1.fontColor = .white
        textProgress1.position = CGPoint(x: 300, y: 1150)
        textProgress1.fontSize = 40
        addChild(textProgress1)
        
        progressBar = SKSpriteNode(imageNamed: "progress")
        progressBar.zPosition = 5.0
        progressBar.position = CGPoint(x: 300, y: 1100)
        progressBar.setScale(2)
        addChild(progressBar)
    }
    
    //MARK: - Timer Function
    
    func startTimer() {
        // Esegui un'azione che incrementa il tempo ogni secondo
        let waitAction = SKAction.wait(forDuration: 1)
        let updateAction = SKAction.run { [weak self] in
            guard let self = self, !self.isTimerPaused else { return }
//            self.elapsedTime += 1
//            self.updateTimerLabel()
            if self.isAccelerated {
                        self.elapsedTime += 5
                    } else {
                        self.elapsedTime += 1
                    }
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
    //MARK: - New Dimension
    func setupNewDimension() {
        // Player setup
        let runAnimation = SKAction.animate(with: textures.mushroomRainbow, timePerFrame: 0.09)
        let runMush = SKAction.repeatForever(runAnimation)
        player.run(runMush)
        
    }
    
    func normalDimension() {
        let RunAnimation = SKAction.animate(with: textures.mushroomRun, timePerFrame: 0.09)
        let RunMush = SKAction.repeatForever(RunAnimation)
        player.run(RunMush)
        
        isAccelerated = false

    }
    
    func setupShark() {
        shark = SKSpriteNode(texture: Shark)
        let BirdAn = SKAction.animate(with: textures.Shark, timePerFrame: 0.09)
        let AnBird = SKAction.repeatForever(BirdAn)
        shark.run(AnBird)
        shark.scale(to: BirdS)
        shark.zPosition = 5.0
        shark.name = "Bird"
        let randomY = CGFloat.random(in: 800...1150)
        shark.position = CGPoint(x: cameraRect.maxX + 2060, y: randomY)
        let baseDuration: TimeInterval = 10.0
        let randomFactor: TimeInterval = TimeInterval.random(in: 10...15)
        let moveDuration = baseDuration + randomFactor
        let destinationPoint = CGPoint(x: -1000,y: randomY)
        let moveAction = SKAction.move(to: destinationPoint, duration: moveDuration)
        shark.run(moveAction)
        shark.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 70))
        shark.physicsBody!.affectedByGravity = false
        shark.physicsBody!.isDynamic = false
        shark.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        shark.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        addChild(shark)
        shark.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
    }
    
    func spawnShark() {
        let random = Double(CGFloat.random(min: 3, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                if self?.generateObstaclesD ?? true {
                    self?.setupShark()
                }
            }
            
        ])))
    }
    
    func setupHyena() {
        hyena = SKSpriteNode(texture: Hyena)
        let DogAn = SKAction.animate(with: textures.Hyena, timePerFrame: 0.09)
        let AnDog = SKAction.repeatForever(DogAn)
        hyena.run(AnDog)
        hyena.scale(to: dogS)
        hyena.zPosition = 5.0
        hyena.name = "Dog"
        hyena.position = CGPoint(x: cameraRect.maxX + 2060, y: ground.frame.height + player.frame.height + 10)
        let baseDuration: TimeInterval = 10.0 // Base duration for movement
        let randomFactor: TimeInterval = TimeInterval.random(in: 10.0...15.0) // Random factor
        let moveDuration = baseDuration + randomFactor
        let destinationPoint = CGPoint(x: -1000,y: ground.frame.height + hyena.frame.height - 50)
        let moveAction = SKAction.move(to: destinationPoint, duration: moveDuration)
        hyena.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 20))
        hyena.physicsBody!.affectedByGravity = false
        hyena.physicsBody!.isDynamic = false
        hyena.physicsBody!.categoryBitMask = PhysicsCategory.Obstacles
        hyena.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        hyena.run(moveAction)
        addChild(hyena)
        hyena.run(.sequence([
            .wait(forDuration: 10),
            .removeFromParent()
        ]))
        
    }
    
    func spawnHyena() {
        let random = Double(CGFloat.random(min: 3, max: isTimeD))
        run(.repeatForever(.sequence([
            .wait(forDuration: random),
            .run { [weak self] in
                if self?.generateObstaclesD ?? true {
                    self?.setupHyena()
                }
            }
            
        ])))
    }
    
    func createBGD() {
        for i in 0...2 {
            bgD = SKSpriteNode(texture: BgDistorted)
            let animation = SKAction.animate(with: textures.BgDistorted, timePerFrame: 0.3)
            let An = SKAction.repeatForever(animation)
            bgD.run(An)
            bgD.name = "bg"
            bgD.anchorPoint = .zero
            bgD.position = CGPoint(x: CGFloat(i)*bgD.frame.width, y: 100.0)
            bgD.zPosition = 1
            addChild(bgD)
            
            bgDNodes.append(bgD)
        }
    }
    
    //MARK: - Game Over Function
    
    func setupGameOver() {
        
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
            dog.removeFromParent()
            bird.removeFromParent()
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: cameraRect.minX + size.width/2, y: size.height/2)
            gameOver.zPosition = 10
            addChild(gameOver)
            
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
            let fullScale = SKAction.sequence([scaleUp, scaleDown])
            gameOver.run(.repeatForever(fullScale))
            
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
        case PhysicsCategory.Gems:
            if let node = other.node {
                collectedGem += 1
                run(gemCollected)
                node.removeFromParent()
                
                let progressBarTextures = ["progress", "progress1", "progress2", "progress3", "progress4", "progress5", "progress6", "progress7", "progress8", "progress9", "progress10"]
                let index = min(collectedGem, progressBarTextures.count - 1)
                progressBar.texture = SKTexture(imageNamed: progressBarTextures[index])
                
                
                if index == 10  {
                    let waitAction = SKAction.wait(forDuration: 15)
                    
                    // Creazione di un'azione per eseguire il codice dopo il ritardo di 30 secondi
                    let runAction = SKAction.run { [weak self] in
                        self?.generateObstaclesD = true
                        self?.generateObstacles = false
                        self?.generateGems = false
                        self?.dog.removeFromParent()
                        self?.bird.removeFromParent()
                        self?.gems.removeFromParent()
                        self?.setupShark()
                        self?.spawnShark()
                        self?.setupHyena()
                        self?.spawnHyena()
                        self?.createBGD()
                        self?.collectedGem = 0
                        self?.isAccelerated = true
                        self?.progressBar.texture = SKTexture(imageNamed: "progress")
                        self?.setupNewDimension()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
                                self?.isAccelerated = false // Riporta il timer alla velocità normale
                        }
                    }
                    
                    let normalDimension = SKAction.run { [weak self] in
                        self?.generateObstaclesD = false
                        self?.generateObstacles = true
                        self?.generateGems = true
                        self?.shark.removeFromParent()
                        self?.hyena.removeFromParent()
                        for node in self?.bgDNodes ?? [] {
                            node.removeFromParent()
                        }
                        self?.normalDimension()
                    }
                    // Creazione di una sequenza di azioni: attesa di 30 secondi e poi eseguire il codice
                    let sequence = SKAction.sequence([runAction, waitAction, normalDimension])
                    
                    // Esegui la sequenza di azioni
                    self.run(sequence)
                }
            }
        case PhysicsCategory.Border:
            print("border")
        default:
            break
        }
    }
}

