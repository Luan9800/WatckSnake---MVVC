import Foundation
import WatchKit
import SwiftUI

// MARK: - Direção da Cobra
enum Direction {
    case up, down, left, right
}

// MARK: - Modos de Jogo
enum GameModo: String, CaseIterable {
    case easy = "Fácil"
    case medium = "Médio"
    case hard = "Difícil"
    case expert = "Experiente"

    /// Cor associada ao modo
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .expert: return .purple
        }
    }

    /// Velocidade base usada para ajustar timers
    var baseSpeed: TimeInterval {
        switch self {
        case .easy: return 0.65
        case .medium: return 0.45
        case .hard: return 0.35
        case .expert: return 0.25
        }
    }
}

// MARK: - Tamanho da Tela do Apple Watch
struct ScreenSize {
    static let width = WKInterfaceDevice.current().screenBounds.width
    static let height = WKInterfaceDevice.current().screenBounds.height
}

// MARK: - Estrutura de Pontuação (Ranking)
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

// MARK: - Modelo do Jogo Snake
struct SnakeModel {
    // Estado do jogo
    var snake: [(x: Int, y: Int)]
    var food: (x: Int, y: Int)?
    var foods: [(x: Int, y: Int)] = []

    // Elementos especiais
    var specialFood: (x: Int, y: Int)?
    var colorChangingFood: (x: Int, y: Int)?
    var starPowerUp: (x: Int, y: Int)?
    var foodslow: (x: Int, y: Int)?

    // Propriedades do jogador
    var direction: Direction
    var score: Int
    var level: Int
    var isInvincible: Bool = false

    // Obstáculos e tempo
    var obstacles: [(x: Int, y: Int)] = []
    var startTime: Date

    // Tempo decorrido desde o início
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    // MARK: - Resetar o jogo
    mutating func resetGame() {
        self = SnakeModel.newGame()
    }

    // MARK: - Criar nova instância do jogo
    static func newGame() -> SnakeModel {
        return SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
            foods: [
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10))
            ],
            specialFood: nil,
            colorChangingFood: nil,
            starPowerUp: nil,
            foodslow: nil,
            direction: .right,
            score: 0,
            level: 1,
            isInvincible: false,
            obstacles: [],
            startTime: Date()
        )
    }
}
