import Foundation
import CloudKit
import SwiftUI

enum Direction {
    case up, down, left, right
}

enum GameMode: String {
    case easy = "Fácil"
    case medium = "Médio"
    case hard = "Difícil"
    case expert = "Experiente"
}

struct HighScore: Identifiable {
    let id: CKRecord.ID
    let playerName: String
    let score: Int
    let date: Date
    
    init(record: CKRecord) {
        self.id = record.recordID
        self.playerName = record["playerName"] as? String ?? "Unknown"
        self.score = record["score"] as? Int ?? 0
        self.date = record["date"] as? Date ?? Date()
    }
}

struct SnakeModel {
    var snake: [(x: Int, y: Int)]
    var food: (x: Int, y: Int)
    var direction: Direction
    var score: Int
    var level: Int
    var startTime: Date // ⏳ Tempo de início da partida

    var starPowerUp: (x: Int, y: Int)? // ⭐️ Power-Up de Invencibilidade
    var isInvincible: Bool = false // 🔥 Estado de Invencibilidade


    /// ⏳ **Calcula o tempo jogado**
    var elapsedTime: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }

    /// 🔄 **Reseta o jogo**
    mutating func resetGame() {
        self.snake = [(5, 5)]
        self.food = (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10))
        self.direction = .right
        self.score = 0
        self.level = 1
        self.startTime = Date() // Reinicia o tempo do jogo
        self.starPowerUp = nil
        self.isInvincible = false
    }

    /// 📊 **Cria uma instância inicial do jogo**
    static func newGame() -> SnakeModel {
        return SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
            direction: .right,
            score: 0,
            level: 1,
            startTime: Date()
        )
    }
}
