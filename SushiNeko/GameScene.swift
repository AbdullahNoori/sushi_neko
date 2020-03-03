import GameplayKit
import SpriteKit

/* Tracking enum for game state */
enum GameState {
    case title, ready, playing, gameOver
}

/* Tracking enum for use with character and sushi side */
enum Side {
    case left, right, none
}

class GameScene: SKScene {
    /* Game objects */
    var sushiBasePiece: SushiPiece!
    /* Cat Character */
    var character: Character!
    var playButton: MSButtonNode!
    var healthBar: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    /* Sushi tower array */
    var sushiTower: [SushiPiece] = []
    /* Game management */
    var state: GameState = .title
    var health: CGFloat = 1.0 {
      didSet {
          /* Scale health bar between 0.0 -> 1.0 e.g 0 -> 100% */
        if health > 1.0 { health = 1.0 }
          healthBar.xScale = health
      }
    }
    var score: Int = 0 {
      didSet {
        scoreLabel.text = String(score)
      }
    }
    
    func addTowerPiece(side: Side) {
       /* Add a new sushi piece to the sushi tower */

       /* Copy original sushi piece */
       let newPiece = sushiBasePiece.copy() as! SushiPiece
       newPiece.connectChopsticks()

       /* Access last piece properties */
       let lastPiece = sushiTower.last

       /* Add on top of last piece, default on first piece */
       let lastPosition = lastPiece?.position ?? sushiBasePiece.position
       newPiece.position.x = lastPosition.x
       newPiece.position.y = lastPosition.y + 55

       /* Increment Z to ensure it's on top of the last piece, default on first piece*/
       let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
       newPiece.zPosition = lastZPosition + 1

       /* Set side */
       newPiece.side = side

       /* Add sushi to scene */
       addChild(newPiece)

       /* Add sushi piece to the sushi tower */
       sushiTower.append(newPiece)
    }
    
    func moveTowerDown() {
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215; piece.position.y -= (piece.position.y - y) * 0.5; n += 1 }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        /* Connect game objects */
        sushiBasePiece = childNode(withName: "sushiBasePiece") as? SushiPiece
        sushiBasePiece = childNode(withName: "sushiBasePiece") as? SushiPiece
        character = childNode(withName: "character") as? Character
       
        /* UI game objects */
        playButton = childNode(withName: "playButton") as? MSButtonNode
        
        healthBar = childNode(withName: "healthBar") as? SKSpriteNode
        /* Setup play button selection handler */
        playButton.selectedHandler = {
            /* Start game */
            self.state = .ready
        }
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        

        /* Setup chopstick connections */
        sushiBasePiece.connectChopsticks()
        
        /* Manually stack the start of the tower */
        addTowerPiece(side: .none)
        addTowerPiece(side: .right)
        
        /* Randomize tower to just outside of the screen */
        addRandomPieces(total: 10)
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveTowerDown()
        /* Called before each frame is rendered */
        if state != .playing { return }

        /* Decrease Health */
        health -= 0.01
        /* Has the player ran out of health? */
        if health < 0 {
            gameOver()
        }
    }
     
    func setupGameViews() {
        gameMat = childNode(withName: kGAMEMAT) as? SKSpriteNode
        sushiBasePiece = childNode(withName: kBASESUSHI) as? SushiPiece //connect game object from .sks
        sushiBasePiece.connectChopsticks()
        character = childNode(withName: kCHARACTER) as? Character
        playButton = childNode(withName: kPLAYBUTTON) as? MSButtonNode
        playButton.selectedHandler = { /* Setup play button selection handler */
            self.state = .ready /* Start game */
        }
        scoreLabel = childNode(withName: kSCORELABEL) as? SKLabelNode
        healthBar = childNode(withName: kHEALTHBAR) as? SKSpriteNode
        highScoreLabel = gameMat.childNode(withName: kHIGHSCORELABEL) as? SKLabelNode
        gameTitleLabel = gameMat.childNode(withName: kGAMETITLELABEL) as? SKLabelNode
        tapToPlayLabel = childNode(withName: kTAPTOPLAYLABEL) as? SKLabelNode
        updateMenuLabels()
        highScoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: kHIGHSCORE))"
    }
    
    func gameOver() {
        state = .gameOver
        /* Create turnRed SKAction */
        let turnRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.50)
        /* Turn all the sushi pieces red*/
        sushiBasePiece.run(turnRed)
        for sushiPiece in sushiTower {
            sushiPiece.run(turnRed)
        }
        character.run(turnRed) /* Make the player turn red */
        playButton.selectedHandler = { /* Change play button selection handler */
            let skView = self.view as SKView? /* Grab reference to the SpriteKit view */
            guard let scene = GameScene(fileNamed: "GameScene") as GameScene? else { /* Load Game scene */
                return
            }
            scene.scaleMode = .aspectFill /* Ensure correct aspect mode */
            skView?.presentScene(scene) /* Restart GameScene */
        }
        updateMenuLabels()
        checkHighScore()
    }
    func checkHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: kHIGHSCORE)
        if self.score > highScore {
            UserDefaults.standard.set(self.score, forKey: kHIGHSCORE)
            UserDefaults.standard.synchronize() //set the high score
            highScoreLabel.text = "Highscore: \(UserDefaults.standard.integer(forKey: kHIGHSCORE))" //put the highschore on text
        }
    }
    
    func updateMenuLabels() {
        if self.state == .title || self.state == .gameOver { //if game over, show labels
            gameTitleLabel.isHidden = false
            tapToPlayLabel.isHidden = false
            highScoreLabel.isHidden = false
            let showMatAction = SKAction.moveTo(y: 283, duration: 1.5)
            gameMat.run(showMatAction)
        } else {
            let removeMatAction = SKAction.moveTo(y: 750, duration: 0.5)
            gameMat.run(removeMatAction)
            gameTitleLabel.isHidden = true
            tapToPlayLabel.isHidden = true
            highScoreLabel.isHidden = true
        }
    }
    
    func moveTowerDown() {
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    func addRandomPieces(total: Int) { /* Add random sushi pieces to the sushi tower */
      for _ in 1...total {
          let lastPiece = sushiTower.last! /* Need to access last piece properties */
          if lastPiece.side != .none { /* Need to ensure we don't create impossible sushi structures */
             addTowerPiece(side: .none)
          } else {
             /* Random Number Generator */
             let rand = arc4random_uniform(100)
             if rand < 45 {
                /* 45% Chance of a left piece */
                addTowerPiece(side: .left)
             } else if rand < 90 {
                /* 45% Chance of a right piece */
                addTowerPiece(side: .right)
             } else {
                /* 10% Chance of an empty piece */
                addTowerPiece(side: .none)
             }
          }
      }
    }
    
    func addTowerPiece(side: Side) { /* Add a new sushi piece to the sushi tower */
       let newPiece = sushiBasePiece.copy() as! SushiPiece /* Copy original sushi piece */
       newPiece.connectChopsticks()
       let lastPiece = sushiTower.last /* Access last piece properties */
       /* Add on top of last piece, default on first piece */
       let lastPosition = lastPiece?.position ?? sushiBasePiece.position
       newPiece.position.x = lastPosition.x
       newPiece.position.y = lastPosition.y + 55
       /* Increment Z to ensure it's on top of the last piece, default on first piece*/
       let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
       newPiece.zPosition = lastZPosition + 1
       /* Set side */
       newPiece.side = side
       addChild(newPiece)
       sushiTower.append(newPiece) /* Add sushi piece to the sushi tower */
    }
    
}




