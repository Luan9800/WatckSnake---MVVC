import SwiftUI
import Combine
import WatchKit

class SnakeViewModel: ObservableObject {
    @Published var model: SnakeModel
    @Published var isGameOver = false
    @Published var hasWon = false
    @Published var gameMode: GameMode = .easy
    
    private var timer: AnyCancellable?
    let gridSize = 10
    let maxLevel = 10
    let winningScore = 300

    @Published var specialFood: (x: Int, y: Int)? // 🟡 Comida especial que some rápido
    private var specialFoodTimer: AnyCancellable?

    init() {
        self.model = SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
            direction: .right,
            score: 0,
            level: 1
        )
        startGameLoop()
    }

    @MainActor
    func setGameMode(_ mode: GameMode) {
        self.gameMode = mode
        startGameLoop()
    }

    /// 🔄 **Inicia ou reinicia o jogo**
    func startGameLoop() {
        isGameOver = false
        hasWon = false
        model = SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize)),
            direction: .right,
            score: 0,
            level: 1
        )
        specialFood = nil // Reseta a comida especial
        
        timer?.cancel()
        startTimer()
        scheduleSpecialFood() // 🔥 Ativa o sistema da comida especial
    }

    /// ⏳ **Inicia o Timer para movimentar a cobra**
    private func startTimer() {
        let interval: TimeInterval = {
            switch gameMode {
            case .easy: return 0.7 // 🟢 Aumentei um pouco a velocidade
            case .medium: return 0.45
            case .hard: return 0.25
            }
        }()

        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveSnake()
            }
    }

    /// ✨ **Agenda a comida especial para aparecer e desaparecer**
    private func scheduleSpecialFood() {
        specialFoodTimer?.cancel()
        specialFoodTimer = Timer.publish(every: 6, on: .main, in: .common) // 🕒 Agora aparece a cada 6s
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnSpecialFood()
            }
    }

    /// ✨ **Cria comida especial que desaparece em 1 segundo**
    private func spawnSpecialFood() {
        guard specialFood == nil else { return } // Se já tem uma, não cria outra

        specialFood = (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { // ⏳ Agora dura 1s
            self.specialFood = nil
        }
    }

    /// 🐍 **Movimenta a cobra e verifica colisões**
    private func moveSnake() {
        guard !isGameOver, !hasWon else { return }
        guard let head = model.snake.first else { return }

        let newHead: (x: Int, y: Int)

        switch model.direction {
        case .up: newHead = (x: head.0, y: head.1 - 1)
        case .down: newHead = (x: head.0, y: head.1 + 1)
        case .left: newHead = (x: head.0 - 1, y: head.1)
        case .right: newHead = (x: head.0 + 1, y: head.1)
        }

        if detectCollision(newHead) {
            isGameOver = true
            timer?.cancel()
            return
        }

        model.snake.insert(newHead, at: 0)

        if newHead == model.food {
            eatFood()
        } else if let special = specialFood, newHead == special {
            eatSpecialFood() // ✨ Comida especial!
        } else {
            model.snake.removeLast()
        }
    }

    /// ⚠ **Verifica colisão**
    private func detectCollision(_ newHead: (x: Int, y: Int)) -> Bool {
        return newHead.x < 0 || newHead.y < 0 ||
               newHead.x >= gridSize || newHead.y >= gridSize ||
               model.snake.contains(where: { $0 == newHead })
    }

    /// 🍏 **Cobra come comida normal**
    private func eatFood() {
        model.food = (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
        model.score += 10

        if model.score >= winningScore || model.level >= maxLevel {
            hasWon = true
            timer?.cancel()
            return
        }

        if model.score % 50 == 0 && model.level < maxLevel {
            model.level += 1
            increaseSpeed()
        }
    }

    /// ✨ **Cobra come comida especial e cresce 2 quadrados**
    private func eatSpecialFood() {
        model.score += 20
        specialFood = nil
        
        if let lastSegment = model.snake.last {
            model.snake.append(lastSegment)
            model.snake.append(lastSegment) // 🟡 Cresce 2x mais do que o normal
        }

        // 🚀 Aumenta levemente a velocidade da cobra após comer comida especial
        increaseSpeed(by: 0.03)
    }
    
    func changeDirection(to newDirection: Direction) {
        let currentDirection = model.direction

        if (currentDirection == .left && newDirection != .right) ||
           (currentDirection == .right && newDirection != .left) ||
           (currentDirection == .up && newDirection != .down) ||
           (currentDirection == .down && newDirection != .up) {
            model.direction = newDirection
        }
    }

    /// ⚡ **Aumenta a velocidade do jogo conforme o nível sobe**
    private func increaseSpeed(by amount: Double = 0.015) {
        timer?.cancel()
        let newInterval = max(0.1, 0.8 - (Double(model.level) * amount))

        timer = Timer.publish(every: newInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveSnake()
            }
    }

    /// 📳 **Ativa resposta tátil no toque (watchOS)**
    func triggerHapticFeedback(type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}
