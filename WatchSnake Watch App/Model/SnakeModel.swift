import Foundation
import WatchKit
import SwiftUI

enum Direction {
    case up, down, left, right
}

enum GameModo: String {
    case easy = "Fácil"
    case medium = "Médio"
    case hard = "Difícil"
    case expert = "Experiente"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .expert: return .purple
            
        }
    }
}

// Monster do Game
struct Monster {
    var position: CGPoint
    var direction: Direction
}

struct ScreenSize {
    static let width = WKInterfaceDevice.current().screenBounds.width
    static let height = WKInterfaceDevice.current().screenBounds.height
}

struct HighScore: Identifiable, Codable, Hashable {
    let id: UUID
    let playerName: String
    let score: Int
    let level: Int
    let modo: String
    let date: Date
    
    init(id: UUID = UUID(), playerName: String, score: Int, level: Int, modo: String, date: Date) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.level = level
        self.modo = modo
        self.date = date
    }
}

// 🐍 **Modelo do jogo Snake**
struct SnakeModel {
    var snake: [(x: Int, y: Int)]
    var food: (x: Int, y: Int)?
    var foods: [(x: Int, y: Int)] = []
    var specialFood: (x: Int, y: Int)?
    var colorChangingFood: (x: Int, y: Int)?
    var direction: Direction
    var score: Int
    var level: Int
    var startTime: Date
    var obstacles: [(x: Int, y: Int)] = []
    var monster: [(x: Int, y: Int)] = [(5, 5), (5, 6), (5, 7), (5, 8)]
    var starPowerUp: (x: Int, y: Int)?
    var isInvincible: Bool = false
    
    /// ⏳ **Tempo jogado**
    var elapsedTime: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
    
    /// 🔄 **Resetar o jogo**
    mutating func resetGame() {
        self = SnakeModel.newGame()
    }
    
    /// 📊 **Criar uma instância inicial do jogo**
    static func newGame() -> SnakeModel {
        return SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
            foods: [
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10))
            ],
            direction: .right,
            score: 0,
            level: 1,
            startTime: Date()
        )
    }
} 
