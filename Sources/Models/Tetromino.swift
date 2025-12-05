import Foundation

enum TetrominoShape: CaseIterable {
    case i, o, t, s, z, j, l

    var color: BlockColor {
        switch self {
        case .i: return .cyan
        case .o: return .yellow
        case .t: return .purple
        case .s: return .green
        case .z: return .red
        case .j: return .blue
        case .l: return .orange
        }
    }

    var blocks: [[Bool]] {
        switch self {
        case .i:
            return [
                [false, false, false, false],
                [true, true, true, true],
                [false, false, false, false],
                [false, false, false, false]
            ]
        case .o:
            return [
                [true, true],
                [true, true]
            ]
        case .t:
            return [
                [false, true, false],
                [true, true, true],
                [false, false, false]
            ]
        case .s:
            return [
                [false, true, true],
                [true, true, false],
                [false, false, false]
            ]
        case .z:
            return [
                [true, true, false],
                [false, true, true],
                [false, false, false]
            ]
        case .j:
            return [
                [true, false, false],
                [true, true, true],
                [false, false, false]
            ]
        case .l:
            return [
                [false, false, true],
                [true, true, true],
                [false, false, false]
            ]
        }
    }
}

struct Tetromino {
    let shape: TetrominoShape
    var position: Point
    var rotation: Int = 0

    struct Point {
        var x: Int
        var y: Int
    }

    var blocks: [[Bool]] {
        var rotated = shape.blocks
        for _ in 0..<rotation {
            rotated = rotateMatrix(rotated)
        }
        return rotated
    }

    private func rotateMatrix(_ matrix: [[Bool]]) -> [[Bool]] {
        let size = matrix.count
        var result = Array(repeating: Array(repeating: false, count: size), count: size)
        for i in 0..<size {
            for j in 0..<size {
                result[j][size - 1 - i] = matrix[i][j]
            }
        }
        return result
    }

    func rotated() -> Tetromino {
        var newTetromino = self
        newTetromino.rotation = (rotation + 1) % 4
        return newTetromino
    }

    func moved(by delta: Point) -> Tetromino {
        var newTetromino = self
        newTetromino.position = Point(x: position.x + delta.x, y: position.y + delta.y)
        return newTetromino
    }
}

// BlockColor type for compatibility
struct BlockColor {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    static let cyan = BlockColor(red: 0, green: 1, blue: 1, alpha: 1)
    static let yellow = BlockColor(red: 1, green: 1, blue: 0, alpha: 1)
    static let purple = BlockColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
    static let green = BlockColor(red: 0, green: 1, blue: 0, alpha: 1)
    static let red = BlockColor(red: 1, green: 0, blue: 0, alpha: 1)
    static let blue = BlockColor(red: 0, green: 0, blue: 1, alpha: 1)
    static let orange = BlockColor(red: 1, green: 0.5, blue: 0, alpha: 1)
    static let black = BlockColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let gray = BlockColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
}