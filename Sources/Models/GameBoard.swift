import Foundation

struct GameBoard {
    static let width = 10
    static let height = 20
    static let hiddenRows = 4

    private var grid: [[BlockColor?]]

    init() {
        grid = Array(repeating: Array(repeating: nil, count: GameBoard.width), count: GameBoard.height + GameBoard.hiddenRows)
    }

    subscript(x: Int, y: Int) -> BlockColor? {
        get {
            guard x >= 0 && x < GameBoard.width && y >= 0 && y < grid.count else {
                return nil
            }
            return grid[y][x]
        }
        set {
            guard x >= 0 && x < GameBoard.width && y >= 0 && y < grid.count else {
                return
            }
            grid[y][x] = newValue
        }
    }

    func canPlace(_ tetromino: Tetromino) -> Bool {
        let blocks = tetromino.blocks
        for y in 0..<blocks.count {
            for x in 0..<blocks[y].count {
                if blocks[y][x] {
                    let boardX = tetromino.position.x + x
                    let boardY = tetromino.position.y + y

                    // Check bounds
                    if boardX < 0 || boardX >= GameBoard.width || boardY >= grid.count {
                        return false
                    }

                    // Check if below the visible area (hidden rows allow placement)
                    if boardY < 0 {
                        continue
                    }

                    // Check collision with existing blocks
                    if self[boardX, boardY] != nil {
                        return false
                    }
                }
            }
        }
        return true
    }

    mutating func place(_ tetromino: Tetromino) {
        let blocks = tetromino.blocks
        for y in 0..<blocks.count {
            for x in 0..<blocks[y].count {
                if blocks[y][x] {
                    let boardX = tetromino.position.x + x
                    let boardY = tetromino.position.y + y

                    // Only place if within bounds
                    if boardX >= 0 && boardX < GameBoard.width && boardY >= 0 && boardY < grid.count {
                        self[boardX, boardY] = tetromino.shape.color
                    }
                }
            }
        }
    }

    mutating func clearLines() -> Int {
        var linesCleared = 0
        var newGrid = Array(repeating: Array(repeating: nil as BlockColor?, count: GameBoard.width), count: grid.count)

        var destRow = grid.count - 1
        for srcRow in (0..<grid.count).reversed() {
            if grid[srcRow].allSatisfy({ $0 != nil }) {
                // This is a complete line, skip it
                linesCleared += 1
            } else {
                // Copy the row
                newGrid[destRow] = grid[srcRow]
                destRow -= 1
            }
        }

        // Fill remaining rows with nil
        if destRow >= 0 {
            for row in 0...destRow {
                newGrid[row] = Array(repeating: nil, count: GameBoard.width)
            }
        }

        grid = newGrid
        return linesCleared
    }

    func isGameOver() -> Bool {
        // Check if any block is in the hidden area (top rows)
        for y in 0..<GameBoard.hiddenRows {
            for x in 0..<GameBoard.width {
                if self[x, y] != nil {
                    return true
                }
            }
        }
        return false
    }

    // Helper for rendering
    func blockAt(x: Int, y: Int) -> BlockColor? {
        // Convert from visible coordinates (0-19) to board coordinates (hiddenRows-23)
        let boardY = y + GameBoard.hiddenRows
        return self[x, boardY]
    }
}