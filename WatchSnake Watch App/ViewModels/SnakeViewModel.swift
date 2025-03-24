import SwiftUI
import Combine
import WatchKit
import UserNotifications

class SnakeViewModel: ObservableObject {
    @Published var model: SnakeModel
    @Published var isGameOver = false
    @Published var isPaused: Bool = false
    @Published var hasWon = false
    @Published var bomb: (x: Int, y: Int)?
    @Published var specialFood: (x: Int, y: Int)?
    @Published var gameModo: GameModo = .easy
    @Published var starPowerUp: (x: Int, y: Int)?
    @Published var isInvincible = false
    
    
    private var timer: AnyCancellable?
    private var bombaTimer: AnyCancellable?
    private var specialFoodTimer: AnyCancellable?
    private var powerUpTimer: AnyCancellable?
    private var currentInterval: TimeInterval = 0.8
    
    
    let gridSize = 15
    let maxLevel = 10
    let winningScore = 300
    
    // 🟡 Comida especial que some rápido
    
    init() {
        self.model = SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
            direction: .right,
            score: 0,
            level: 1,
            startTime: Date()
        )
        startGameLoop()
        // 🎯 Detecta quando o usuário vira o pulso e pausa o jogo
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWatchVisibilityChange),
            name: WKExtension.applicationDidEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWatchVisibilityChange),
            name: WKExtension.applicationWillEnterForegroundNotification,
            object: nil
        )
    }
    
    /// ⏸ **Pausa o jogo quando o usuário vira o braço**
    @objc private func handleWatchVisibilityChange(notification: Notification) {
        if notification.name == WKExtension.applicationDidEnterBackgroundNotification {
            pauseGame()
        } else if notification.name == WKExtension.applicationWillEnterForegroundNotification {
            resumeGame()
        }
        
    }
    
    /// ⏸ **Pausa o jogo**
    func pauseGame() {
        isPaused = true
        timer?.cancel()
    }
    
    /// ▶ **Retoma o jogo**
    func resumeGame() {
        if isPaused {
            isPaused = false
            adjustSpeed()
        }
    }
    
    @MainActor
    func setGameModo(_ modo: GameModo) {
        self.gameModo = modo
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
            level: 1,
            startTime: Date()
        )
        specialFood = nil // Reseta a comida especial
        
        timer?.cancel()
        adjustSpeed()
        scheduleSpecialFood() // 🔥 Ativa o sistema da comida especial
        cancelComeBackNotification() // Cancelar Notificação
        scheduleBombs()// 🔥 Ativa as bombas
        schedulePowerUp()
        
    }
    
    /// ⏳ **Inicia o Timer para movimentar a cobra**
    private func adjustSpeed() {
        timer?.cancel()
        
        let baseSpeed: TimeInterval = {
            switch gameModo {
            case .easy: return 0.7
            case .medium: return 0.55
            case .hard: return 0.35
            case .expert : return 0.25
            }
        }()
        
        let levelFactor: Double = max(0.05, baseSpeed - (Double(model.level) * 0.05))
        
        currentInterval = levelFactor
        
        timer = Timer.publish(every: currentInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveSnake()
            }
    }
    
    /// ✨ **Agenda a comida especial para aparecer e desaparecer**
    private func scheduleSpecialFood() {
        specialFoodTimer?.cancel()
        specialFoodTimer = Timer.publish(every: 8, on: .main, in: .common)
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
            saveHighScore()
            return
        }
        
        model.snake.insert(newHead, at: 0)
        
        if newHead == model.food {
            eatFood()
        } else if let special = specialFood, newHead == special {
            eatSpecialFood()
        } else if let star = starPowerUp, newHead == star {
            activateInvincibility()
        } else if let bombPosition = bomb, newHead == bombPosition {
            if !isInvincible { hitBomb() }
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
        increaseSpeed(by: -0.08)
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
    private func increaseSpeed(by amount: Double = 0.030) {
        timer?.cancel()
        currentInterval = max(0.08, currentInterval - amount)
        
        timer = Timer.publish(every: currentInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.moveSnake()
            }
    }
    
    /// 📳 **Ativa resposta tátil no toque (watchOS)**
    func triggerHapticFeedback(type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    
    
    // Função para aviar o usuário do aplicativo
    
    func requestNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Primeiro pedido de permissão
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("✅ Permissão de notificações ativada!")
                            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                        } else if let error = error {
                            print("❌ Erro ao pedir permissão: \(error.localizedDescription)")
                        }
                    }
                    
                case .denied:
                    print("⚠️ Notificações foram negadas. O usuário precisa ativar manualmente nas configurações.")
                    
                case .authorized, .provisional, .ephemeral:
                    print("🔔 Notificações já estão ativadas.")
                    
                @unknown default:
                    print("⚠️ Estado desconhecido de notificações.")
                }
            }
        }
    }
    
    // Função para enviar o Usuário do Aplicativo --- Part 2
    
    func scheduleComeBackNotification() {
        let messages = [
            "🐍 Volte para o jogo! Ainda tem mais te esperando!",
            "🏆 Você pode melhorar sua pontuação! Vamos jogar?",
            "🚀 Seu ranking pode estar em risco! Não deixe ninguém te ultrapassar!",
            "🔥 Você estava indo muito bem! Continue de onde parou!",
            "🎮 Hora de voltar ao jogo! Quem sabe você bate seu recorde!"
        ]
        let randomMessage = messages.randomElement() ?? "🐍 Volte para o jogo!" // Escolhe uma mensagem aleatória
        
        let content = UNMutableNotificationContent()
        content.title = randomMessage
        content.body = "O WatchSnake sente sua falta :( Continue subindo no ranking! :)"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 🔥 1 hora sem jogar
        
        let request = UNNotificationRequest(identifier: "come_back", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar a notificação: \(error.localizedDescription)")
            } else {
                print("📢 Notificação agendada!")
            }
        }

        // 🚀 Se o app estiver aberto, exibe um alerta na tela do Apple Watch
        DispatchQueue.main.async {
            if let controller = WKExtension.shared().rootInterfaceController {
                controller.presentAlert(
                    withTitle: "Volte ao jogo! 🐍",
                    message: randomMessage,
                    preferredStyle: .alert,
                    actions: [
                        WKAlertAction(title: "Jogar Agora", style: .default, handler: {
                            print("Jogador decidiu voltar ao jogo")
                        }),
                        WKAlertAction(title: "Fechar", style: .cancel, handler: {})
                    ]
                )
            }
        }
    }
    
    // Função para Cancelar Notificação
    
    func cancelComeBackNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["come_back"])
        print("🔕 Notificação cancelada!")
    }
    
    
    /// 💣 **Gera uma bomba em posição aleatória**
    private func spawnBomb() {
        guard bomb == nil else { return }
        
        bomb = (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
        
        print("💣 Bomba gerada em: \(bomb!)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            self.bomb = nil
            print("💥 Bomba removida!")
        }
    }
    private func scheduleBombs() {
        bombaTimer?.cancel()
        bombaTimer = Timer.publish(every: 10, on: .main , in: .common)
            .autoconnect()
            .sink {[weak self] _ in
                self?.spawnBomb()
            }
    }
    
    /// 💣 **Cobra atinge a bomba e perde um Pedaço**
    private func hitBomb() {
        bomb = nil // Remove a bomba após a colisão
        
        // 📳 Vibração no relógio
        triggerHapticFeedback(type: .failure)
        triggerHapticFeedback(type: .retry)
        
        if model.snake.count > 2 {
            model.snake.removeLast() // 🔥 Cobra perde um pedaço
        } else {
            isGameOver = true // Se for muito pequena, perde o jogo!
            timer?.cancel()
        }
    }
    
    private func activateInvincibility() {
        isInvincible = true
        starPowerUp = nil
        model.score += 10 // Bônus por pegar a estrela
        triggerHapticFeedback(type: .success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // 🕒 Dura 5s
            self.isInvincible = false
        }
    }
    
    private func schedulePowerUp() {
        powerUpTimer?.cancel()
        powerUpTimer = Timer.publish(every: 12, on: .main, in: .common) // Aparece a cada 12s
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnPowerUp()
            }
    }
    
    private func spawnPowerUp() {
        guard starPowerUp == nil else { return }
        starPowerUp = (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { // Some após 5 segundos
            self.starPowerUp = nil
        }
    }
    private func saveHighScore() {
        let playerName = UserDefaults.standard.string(forKey: "playerName") ?? "Jogador"
        let score = model.score
        let level = model.level
        let modo = gameModo
        

        DatabaseManager.shared.saveScore(playerName: playerName, score: score, level: level , modo: modo)
    }

}
