import SwiftUI

struct ContentView: View {
    @StateObject private var gameController = GameController()

    var body: some View {
        VStack(spacing: 20) {
            // Game title
            Text("TETRIS")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)

            HStack(spacing: 40) {
                // Game board
                GameBoardView(gameController: gameController)
                    .frame(width: 300, height: 600)

                // Side panel
                VStack(spacing: 20) {
                    // Game info
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(label: "Score:", value: "\(gameController.score)")
                        InfoRow(label: "Level:", value: "\(gameController.level)")
                        InfoRow(label: "Lines:", value: "\(gameController.linesCleared)")
                    }
                    .padding()
                    .background(SwiftUI.Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Next piece preview
                    VStack {
                        Text("NEXT")
                            .font(.headline)
                        NextPieceView(tetromino: gameController.nextTetromino)
                            .frame(width: 120, height: 120)
                    }
                    .padding()
                    .background(SwiftUI.Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Controls
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CONTROLS")
                            .font(.headline)
                        ControlRow(key: "← →", action: "Move")
                        ControlRow(key: "↑", action: "Rotate")
                        ControlRow(key: "↓", action: "Soft Drop")
                        ControlRow(key: "Space", action: "Hard Drop")
                        ControlRow(key: "P", action: "Pause")
                        ControlRow(key: "R", action: "Restart")
                    }
                    .padding()
                    .background(SwiftUI.Color.gray.opacity(0.1))
                    .cornerRadius(10)

                    // Game state controls
                    GameStateView(gameController: gameController)
                }
                .frame(width: 200)
            }

            // Status message
            if gameController.gameState == .gameOver {
                Text("GAME OVER")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(SwiftUI.Color.black.opacity(0.05))
        .onAppear {
            setupKeyboardHandling()
        }
    }

    private func setupKeyboardHandling() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleKeyDown(event: event)
            return event
        }
    }

    private func handleKeyDown(event: NSEvent) {
        guard gameController.gameState == .playing || gameController.gameState == .paused else { return }

        switch event.keyCode {
        case 123: // Left arrow
            gameController.moveLeft()
        case 124: // Right arrow
            gameController.moveRight()
        case 125: // Down arrow
            gameController.moveDown()
        case 126: // Up arrow
            gameController.rotate()
        case 49: // Space
            gameController.hardDrop()
        case 35: // P
            if gameController.gameState == .playing {
                gameController.pauseGame()
            } else if gameController.gameState == .paused {
                gameController.resumeGame()
            }
        case 15: // R
            gameController.resetGame()
        default:
            break
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .monospaced))
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced).weight(.bold))
        }
    }
}

struct ControlRow: View {
    let key: String
    let action: String

    var body: some View {
        HStack {
            Text(key)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(SwiftUI.Color.blue.opacity(0.2))
                .cornerRadius(4)
            Text(action)
                .font(.caption)
            Spacer()
        }
    }
}

struct GameStateView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack(spacing: 10) {
            switch gameController.gameState {
            case .ready:
                Button("Start Game") {
                    gameController.startGame()
                }
                .buttonStyle(PrimaryButtonStyle())
            case .playing:
                Button("Pause") {
                    gameController.pauseGame()
                }
                .buttonStyle(SecondaryButtonStyle())
            case .paused:
                Button("Resume") {
                    gameController.resumeGame()
                }
                .buttonStyle(PrimaryButtonStyle())
            case .gameOver:
                Button("New Game") {
                    gameController.resetGame()
                    gameController.startGame()
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            Button("Reset") {
                gameController.resetGame()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(SwiftUI.Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(SwiftUI.Color.gray.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}