import SwiftUI

struct NextPieceView: View {
    let tetromino: Tetromino
    private let blockSize: CGFloat = 20

    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .fill(SwiftUI.Color.black.opacity(0.3))
                .border(SwiftUI.Color.white.opacity(0.5), width: 1)

            // Tetromino preview
            ForEach(0..<tetromino.blocks.count, id: \.self) { y in
                ForEach(0..<tetromino.blocks[y].count, id: \.self) { x in
                    if tetromino.blocks[y][x] {
                        blockView(at: x, y, color: tetromino.shape.color)
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
            .position(x: CGFloat(x) * blockSize + blockSize / 2 + 10,
                      y: CGFloat(y) * blockSize + blockSize / 2 + 10)
    }

    private func swiftUIColor(from color: BlockColor) -> SwiftUI.Color {
        SwiftUI.Color(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)
    }
}