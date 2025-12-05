import Foundation
import Combine

@MainActor
class GameController: ObservableObject {
    @Published var gameState: GameState = .ready
    @Published var score: Int = 0
    @Published var level: Int = 1
    @Published var linesCleared: Int = 0
    @Published var board: GameBoard
    @Published var currentTetromino: Tetromino?
    @Published var nextTetromino: Tetromino

    private var timer: Timer?
    private let fallInterval: TimeInterval = 1.0
    private var lastUpdateTime: Date?
    private let queue = DispatchQueue(label: "com.tetris.gamecontroller", qos: .userInteractive)

    enum GameState {
        case ready
        case playing
        case paused
        case gameOver
    }

    init() {
        board = GameBoard()
        nextTetromino = GameController.randomTetromino()
        spawnNewTetromino()
    }

    func startGame() {
        guard gameState != .playing else { return }

        if gameState == .ready {
            // Already reset, just start playing
            gameState = .playing
            startGameLoop()
        } else {
            // Need to reset first (coming from game over or paused)
            resetGame()
            gameState = .playing
            startGameLoop()
        }
    }

    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        stopGameLoop()
    }

    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        startGameLoop()
    }

    func resetGame() {
        stopGameLoop()
        board = GameBoard()
        score = 0
        level = 1
        linesCleared = 0
        nextTetromino = GameController.randomTetromino()
        spawnNewTetromino()
        gameState = .ready
    }

    private func startGameLoop() {
        stopGameLoop()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.update()
            }
        }
        self.lastUpdateTime = Date()
    }

    private func stopGameLoop() {
        timer?.invalidate()
        timer = nil
    }

    private func update() {
        guard gameState == .playing, let lastUpdate = lastUpdateTime else { return }

        let currentTime = Date()
        let deltaTime = currentTime.timeIntervalSince(lastUpdate)

        // Move tetromino down based on level speed
        let fallSpeed = fallInterval / Double(level)
        if deltaTime >= fallSpeed {
            moveDown()
            lastUpdateTime = currentTime
        }
    }

    // MARK: - Tetromino Control

    func moveLeft() {
        guard let tetromino = currentTetromino else { return }
        let moved = tetromino.moved(by: Tetromino.Point(x: -1, y: 0))
        if board.canPlace(moved) {
            currentTetromino = moved
        }
    }

    func moveRight() {
        guard let tetromino = currentTetromino else { return }
        let moved = tetromino.moved(by: Tetromino.Point(x: 1, y: 0))
        if board.canPlace(moved) {
            currentTetromino = moved
        }
    }

    func moveDown() {
        guard let tetromino = currentTetromino else { return }
        let moved = tetromino.moved(by: Tetromino.Point(x: 0, y: 1))
        if board.canPlace(moved) {
            currentTetromino = moved
        } else {
            lockTetromino()
        }
    }

    func rotate() {
        guard let tetromino = currentTetromino else { return }
        let rotated = tetromino.rotated()
        if board.canPlace(rotated) {
            currentTetromino = rotated
        } else {
            // Try wall kicks (standard SRS wall kicks)
            let kicks = [(-1, 0), (1, 0), (0, -1), (-1, -1), (1, -1)]
            for (dx, dy) in kicks {
                let kicked = rotated.moved(by: Tetromino.Point(x: dx, y: dy))
                if board.canPlace(kicked) {
                    currentTetromino = kicked
                    return
                }
            }
        }
    }

    func hardDrop() {
        guard var tetromino = currentTetromino else { return }
        var dropCount = 0
        let maxDrops = GameBoard.height + GameBoard.hiddenRows // Maximum possible drops

        while dropCount < maxDrops && board.canPlace(tetromino.moved(by: Tetromino.Point(x: 0, y: 1))) {
            tetromino = tetromino.moved(by: Tetromino.Point(x: 0, y: 1))
            dropCount += 1
        }
        currentTetromino = tetromino
        lockTetromino()
    }

    private func lockTetromino() {
        guard let tetromino = currentTetromino else { return }
        board.place(tetromino)

        let lines = board.clearLines()
        if lines > 0 {
            updateScore(linesCleared: lines)
        }

        if board.isGameOver() {
            gameState = .gameOver
            stopGameLoop()
        } else {
            spawnNewTetromino()
        }
    }

    private func spawnNewTetromino() {
        currentTetromino = nextTetromino
        nextTetromino = GameController.randomTetromino()

        // Reset position to top center (spawn in first visible row)
        if var tetromino = currentTetromino {
            tetromino.position = Tetromino.Point(x: GameBoard.width / 2 - 1, y: GameBoard.hiddenRows)
            if board.canPlace(tetromino) {
                currentTetromino = tetromino
            } else {
                // Game over if can't place new tetromino
                gameState = .gameOver
                stopGameLoop()
            }
        }
    }

    private func updateScore(linesCleared: Int) {
        self.linesCleared += linesCleared

        // Scoring based on original Tetris
        let points: Int
        switch linesCleared {
        case 1:
            points = 40 * level
        case 2:
            points = 100 * level
        case 3:
            points = 300 * level
        case 4:
            points = 1200 * level
        default:
            points = 0
        }

        score += points

        // Level up every 10 lines
        level = (self.linesCleared / 10) + 1
    }

    private static func randomTetromino() -> Tetromino {
        let shape = TetrominoShape.allCases.randomElement() ?? .t
        return Tetromino(shape: shape, position: Tetromino.Point(x: 0, y: 0))
    }
}