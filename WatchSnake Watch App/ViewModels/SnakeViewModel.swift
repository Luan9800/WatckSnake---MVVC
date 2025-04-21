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
    @Published var isInvincible: Bool = false
    @Published var colorChangingFood: (x: Int, y: Int)? = nil
    @Published var snakeColor: Color = .green
    
    private var timer: AnyCancellable?
    private var bombaTimer: AnyCancellable?
    private var colorFoodSpawner: AnyCancellable?
    private var specialFoodTimer: AnyCancellable?
    private var powerUpTimer: AnyCancellable?
    private var monsterTimer: AnyCancellable?
    private var invincibilityTimer: AnyCancellable?
    private var currentInterval: TimeInterval = 0.8
    private var cancellables = Set<AnyCancellable>()
    private var eatColorChangingFood : AnyCancellable?
    private var rainbowTimer: AnyCancellable?
    
    
    let gridSize = 15
    let maxLevel = 10
    let winningScore = 300
    
    // 🟡 Comida especial que some rápido
    init(mode: GameModo) {
        self.gameModo = mode
        self.model = SnakeModel(
            snake: [(5, 5)],
            food: nil,
            foods: [
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10))
            ],
            direction: .right,
            score: 0,
            level: 1,
            startTime: Date()
        )
        
        timer?.cancel()
        
        startGameLoop()
        
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
            scheduleComeBackNotification()
        } else if notification.name == WKExtension.applicationWillEnterForegroundNotification {
            resumeGame()
            cancelComeBackNotification()
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
    
    /// 🔄 **Inicia ou reinicia o jogo**
    func startGameLoop() {
        isGameOver = false
        hasWon = false
        model = SnakeModel(
            snake: [(5, 5)],
            food: (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize)),
            foods: [
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10)),
                (x: Int.random(in: 0..<10), y: Int.random(in: 0..<10))
            ],
            direction: .right,
            score: 0,
            level: 1,
            startTime: Date()
        )
        specialFood = nil
        
        timer?.cancel()
        
          adjustSpeed()
          scheduleSpecialFood()
          cancelComeBackNotification()
          scheduleBombs()
          startColorFoodSpawningLoop()
          schedulePowerUp()
          spawnColorChangingFood()
        
    }
    
    /// ⏳ **Inicia o Timer para movimentar a cobra**
    private func adjustSpeed() {
        timer?.cancel()
        
        let baseSpeed: TimeInterval = {
            switch gameModo {
            case .easy: return 0.65
            case .medium: return 0.45
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
        
        
        // Configura o timer para gerar comida especial a cada 10 segundos
        specialFoodTimer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnSpecialFood()
            }
    }
    
    /// ✨ **Cria comida especial que desaparece e reaparece antes de sumir**
    private func spawnSpecialFood() {
        guard specialFood == nil else { return }
        
        let foodPosition = (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
        specialFood = foodPosition
        
        // Comida especial "pisca" rapidamente antes de sumir
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { [weak self] in
            self?.specialFood = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            self?.specialFood = foodPosition
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { [weak self] in
            self?.specialFood = nil
        }
    }
    
    private func moveSnake() {
        guard !isGameOver, !hasWon else { return }
        guard let head = model.snake.first else { return }
        
        var newHead: (x: Int, y: Int)
        switch model.direction {
        case .up: newHead = (x: head.0, y: head.1 - 1)
        case .down: newHead = (x: head.0, y: head.1 + 1)
        case .left: newHead = (x: head.0 - 1, y: head.1)
        case .right: newHead = (x: head.0 + 1, y: head.1)
        }
        
        // 🌌 Wrap-around se estiver invencível
        if model.isInvincible {
            newHead.x = (newHead.x + gridSize) % gridSize
            newHead.y = (newHead.y + gridSize) % gridSize
        }
        
        // 🚧 Verifica colisão geral
        if detectCollision(newHead) {
            isGameOver = true
            timer?.cancel()
            saveHighScore()
            return
        }
        
        model.snake.insert(newHead, at: 0) // Adiciona a nova cabeça
        
        // 🍎 Comer comida normal
        if let food = model.food, newHead == food {
            eatFood()
            return
        }
        
        // 🍬 Comer comida especial
        if let special = specialFood, newHead == special {
            eatSpecialFood()
            return
        }
        
        // ⭐️ Pegar estrela da invencibilidade
        if let star = starPowerUp, newHead == star {
            activateInvincibility()
            return
        }
        
        // 💣 Colisão com bomba (se não for invencível)
        if let bombPosition = bomb, newHead == bombPosition {
            print("Bomba está em: \(bombPosition.x), \(bombPosition.y)")
            if !isInvincible {
                hitBomb()
            }
            return
        }
        
       // 🌈 Comida de cor
          if let colorFood = colorChangingFood, newHead == colorFood {
          handleColorChangingEffect()
          return
        }
        
        if !isGameOver {
            model.snake.removeLast()
        }
    }
    
    
    // Função de Criação dos Obstaculos
    private func spawnObstacles() {
        guard gameModo != .easy else { return }
        
        let maxObstacles = 3
        let obstacleCount = min(model.level, maxObstacles)
        
        model.obstacles = []
        
        for _ in 0..<obstacleCount {
            var newObstacle: (x: Int, y: Int)?
            var attempts = 0
            
            repeat {
                let candidate = (x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
                attempts += 1
                
                let foodPosition = model.food
                
                if !model.snake.contains(where: { $0 == candidate }) &&
                    (foodPosition == nil || foodPosition! != candidate) &&
                    !model.obstacles.contains(where: { $0 == candidate }) {
                    newObstacle = candidate
                }
                
                if attempts > 50 {
                    print("⚠️ Não foi possível gerar um novo obstáculo!")
                    break
                }
            } while newObstacle == nil
            
            if let newObstacle = newObstacle {
                model.obstacles.append(newObstacle)
            }
        }
        
        cancellables = cancellables.filter { $0 !== specialFoodTimer }
        
        Just(())
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.model.obstacles.removeAll()
            }
            .store(in: &cancellables)
    }
    
    
    /// ⚠ **Verifica Colisão**
    private func detectCollision(_ newHead: (x: Int, y: Int)) -> Bool {
        if model.isInvincible {
            return false
        }
        
        let collided = newHead.x < 0 || newHead.y < 0 ||
        newHead.x >= gridSize || newHead.y >= gridSize ||
        model.snake.contains(where: { $0 == newHead })
        
        if collided {
            print("🚨 Colisão detectada! Posição: \(newHead.x), \(newHead.y)")
        }
        
        return collided
    }
    
    /// 🍏 **Cobra come Comida Normal**
    private func eatFood() {
        guard !hasWon else { return }
        
        model.score += 10
        
        var newFood: (x: Int, y: Int)?
        
        // 🔹 Criar lista de posições disponíveis
        var availablePositions: [(x: Int, y: Int)] = []
        
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                let pos = (x, y)
                if !model.snake.contains(where: { $0 == pos }) &&
                    !model.obstacles.contains(where: { $0 == pos }) {
                    availablePositions.append(pos)
                }
            }
        }
        
        // 🔹 Tenta escolher uma posição aleatória válida
        if let randomPosition = availablePositions.randomElement() {
            newFood = randomPosition
            print("🍏 Nova comida gerada em: \(newFood!.x), \(newFood!.y)")
        } else {
            print("⚠️ Nenhum espaço disponível para gerar comida!")
            newFood = (x: gridSize / 2, y: gridSize / 2) // Fallback
        }
        
        model.food = newFood
        
        // ✅ Verifica se o jogador venceu
        if model.score >= winningScore || model.level >= maxLevel {
            hasWon = true
            timer?.cancel()
            return
        }
        
        // ✅ Aumenta o nível e adiciona obstáculos se necessário
        if model.score % 50 == 0 && model.level < maxLevel {
            model.level += 1
            if gameModo != .easy {
                spawnObstacles()
            }
            increaseSpeed() // Certifique-se de que a velocidade nunca diminua!
        }
    }
    
    /// ✨ **Cobra come Comida Especial e Cresce 2 Quadrados**
    private func eatSpecialFood() {
        model.score += 20
        specialFood = nil
        
        if let lastSegment = model.snake.last {
            let newSegment = lastSegment
            model.snake.append(newSegment)
            model.snake.append(newSegment)
        }
        
        // ⚡️ Aumenta temporariamente a velocidade
        let speedBoost: Double = 0.3
        increaseSpeed(by: speedBoost)
        
        // Restaura a velocidade normal após 5 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let self = self else { return }
            self.increaseSpeed(by: -speedBoost)
            
            // Gera uma nova comida especial depois de um tempo
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
                self?.spawnSpecialFood()
            }
        }
    }
    //   --------------------------------- Food Color --------------------------------------- //
 
    private func startColorFoodSpawningLoop() {
        let spawnInterval: TimeInterval = 25 // a cada 25 segundos
        
        colorFoodSpawner = Timer.publish(every: spawnInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.spawnColorChangingFood()
            }
    }
    
    private func spawnColorChangingFood() {
        var availablePositions: [(x: Int, y: Int)] = []
        
        for x in 0..<gridSize {
            for y in 0..<(gridSize / 2) {
                let pos = (x, y)
                if !model.snake.contains(where: { $0 == pos }) &&
                    !model.obstacles.contains(where: { $0 == pos }) {
                    availablePositions.append(pos)
                }
            }
        }
        
        guard let position = availablePositions.randomElement() else {
            print("⚠️ Nenhuma posição livre para comida de cor!")
            return
        }
        
        colorChangingFood = position
        print("🌈 Comida de cor spawnada em: \(position.x), \(position.y)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if let currentFood = self?.colorChangingFood, currentFood == position {
                self?.colorChangingFood = nil
            }
        }
    }
    
    private func handleColorChangingEffect() {
        model.score += 10
        colorChangingFood = nil
        
        model.isInvincible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.model.isInvincible = false
        }
        
       let originalColor = snakeColor
        
        // 🌈 Efeito Arco-íris
        let rainbowColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink , .black]
        var colorIndex = 0
        let interval = 0.3
        let duration: TimeInterval = 5.0
        let totalChanges = Int(duration / interval)
        var changeCount = 0
        
        rainbowTimer?.cancel() // evita múltiplos timers
        rainbowTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.snakeColor = rainbowColors[colorIndex % rainbowColors.count]
                colorIndex += 1
                changeCount += 1
                
                if changeCount >= totalChanges {
                    self.snakeColor = originalColor
                    self.rainbowTimer?.cancel()
                    self.rainbowTimer = nil
                }
            }
        
        // Cresce 1 segmento
        if let last = model.snake.last {
            model.snake.append(last)
        }
    } 
    
    // ----------------------------------- Food Color Fim --------------------------------------- //
    
    
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
    
    
    // Função para aviar o usuário do aplicativo ----------------------------------------------------------//
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
        let randomMessage = messages.randomElement() ?? "🐍 Volte para o jogo!"
        
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
        
        // Se o app estiver aberto, exibe um alerta na tela do Apple Watch
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
    
   
    
    func cancelComeBackNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["come_back"])
        print("🔕 Notificação cancelada!")
    }
 
    // ----------------------- Função para Cancelar Notificação ---------------------------------------- //
    
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
    
    // --------------------------/// 💣 **Cobra atinge a bomba e perde um Pedaço** ------------------------------------------------------------//
    private func hitBomb() {
        bomb = nil // Remove a bomba após a colisão
        
        // 📳 Vibração no relógio
        triggerHapticFeedback(type: .failure)
        triggerHapticFeedback(type: .retry)
        
        if model.snake.count > 2 {
            model.snake.removeLast()
        } else {
            isGameOver = true
            timer?.cancel()
        }
    }
    
    private func activateInvincibility() {
        isInvincible = true
        starPowerUp = nil
        model.score += 10 
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
    
    //  ------------------------------------------- Banco de Dados UserDefalt --------------------------------------------
    
    private func saveHighScore() {
        let playerName = UserDefaults.standard.string(forKey: "playerName") ?? "Jogador"
        let score = model.score
        let level = model.level
        let modo = gameModo
        
        
        DatabaseManager.shared.saveScore(playerName: playerName, score: score, level: level , modo: modo)
    }
}

