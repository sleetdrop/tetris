import SwiftUI

struct GameBoardView: View {
    @ObservedObject var gameController: GameController
    private let blockSize: CGFloat = 28
    private let boardWidth = GameBoard.width
    private let boardHeight = GameBoard.height

    var body: some View {
        ZStack {
            // Board background
            Rectangle()
                .fill(SwiftUI.Color.black.opacity(0.8))
                .border(SwiftUI.Color.white, width: 2)

            // Grid lines
            gridView

            // Placed blocks
            placedBlocksView

            // Current tetromino
            if let tetromino = gameController.currentTetromino {
                tetrominoView(tetromino)
            }
        }
        .frame(width: CGFloat(boardWidth) * blockSize,
               height: CGFloat(boardHeight) * blockSize)
    }

    private var gridView: some View {
        GeometryReader { geometry in
            Path { path in
                // Vertical lines
                for x in 0...boardWidth {
                    let xPos = CGFloat(x) * blockSize
                    path.move(to: CGPoint(x: xPos, y: 0))
                    path.addLine(to: CGPoint(x: xPos, y: geometry.size.height))
                }

                // Horizontal lines
                for y in 0...boardHeight {
                    let yPos = CGFloat(y) * blockSize
                    path.move(to: CGPoint(x: 0, y: yPos))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yPos))
                }
            }
            .stroke(SwiftUI.Color.white.opacity(0.3), lineWidth: 0.5)
        }
    }

    private var placedBlocksView: some View {
        ForEach(0..<boardHeight, id: \.self) { y in
            ForEach(0..<boardWidth, id: \.self) { x in
                if let color = gameController.board.blockAt(x: x, y: y) {
                    blockView(at: x, y, color: color)
                }
            }
        }
    }

    private func tetrominoView(_ tetromino: Tetromino) -> some View {
        Group {
            ForEach(0..<tetromino.blocks.count, id: \.self) { y in
                ForEach(0..<tetromino.blocks[y].count, id: \.self) { x in
                    if tetromino.blocks[y][x] {
                        let boardX = tetromino.position.x + x
                        let boardY = tetromino.position.y + y - GameBoard.hiddenRows

                        // Only show if within visible area
                        if boardY >= 0 && boardY < boardHeight && boardX >= 0 && boardX < boardWidth {
                            blockView(at: boardX, boardY, color: tetromino.shape.color)
                        }
                    }
                }
            }
        }
    }

    private func blockView(at x: Int, _ y: Int, color: BlockColor) -> some View {
        Rectangle()
            .fill(swiftUIColor(from: color))
            .border(SwiftUI.Color.white.opacity(0.5), width: 1)
            .frame(width: blockSize, height: blockSize)
            .position(x: CGFloat(x) * blockSize + blockSize / 2,
                      y: CGFloat(y) * blockSize + blockSize / 2)
    }

    private func swiftUIColor(from color: BlockColor) -> SwiftUI.Color {
        SwiftUI.Color(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
    }
}