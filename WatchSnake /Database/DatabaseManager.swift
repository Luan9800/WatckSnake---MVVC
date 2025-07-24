import Foundation

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    // MARK: - Chaves para UserDefaults
    private let key = "highScores"
    private let lastScoreKey = "lastScore"
    
    // MARK: - Inicialização
    private init() {
        if UserDefaults.standard.data(forKey: key) == nil {
            resetDatabase()
        }
    }
    
    // MARK: - Salvar nova pontuação
    func saveScore(playerName: String, score: Int, level: Int, modo: GameModo) {
        var scores = getTopScores()
        
        let newScore = HighScore(
            playerName: playerName,
            score: score,
            level: level,
            modo: modo.rawValue,
            date: Date()
        )
        
        scores.append(newScore)
        
        // Limita a 3 melhores pontuações por jogador
        let topScoresForPlayer = scores
            .filter { $0.playerName == playerName }
            .sorted { $0.score > $1.score }
            .prefix(3)
        
        let finalScores = scores
            .filter { $0.playerName != playerName } + topScoresForPlayer
        
        if let encoded = try? JSONEncoder().encode(finalScores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        // ✅ Checagem de "Vitória" por Modo
        let winningScore: Int = {
            switch modo {
            case .easy: return 250
            case .medium: return 500
            case .hard: return 700
            case .expert: return 950
            }
        }()
        
        if score >= winningScore {
            DispatchQueue.main.async {
                print("🎉 Parabéns \(playerName)! Você zerou o nível \(modo.rawValue) com \(score) pontos! 🎉")
                
                UserDefaults.standard.set(true, forKey:"modo_\(modo.rawValue)_zerado")
            }
        }
    }
    
    // MARK: - Obter pontuações
    func getTopScores() -> [HighScore] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        
        do {
            let decoded = try JSONDecoder().decode([HighScore].self, from: data)
            return decoded.sorted { $0.score > $1.score }
        } catch {
            print("❌ Erro ao decodificar os scores: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Resetar Banco
    func deleteScores(for modo: GameModo) {
        let allScores = getTopScores()
        let filtered = allScores.filter { $0.modo != modo.rawValue }
        
        if let encoded = try? JSONEncoder().encode(filtered) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func resetDatabase() {
        print("🔄 Resetando banco de dados UserDefaults...")
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: lastScoreKey)
    }
    
    // 🔁 Resetar um Modo Específico
    func resetMode(_ modo: GameModo) {
        UserDefaults.standard.removeObject(forKey: "modo_\(modo.rawValue)_zerado")
        let filtered = getTopScores().filter { $0.modo != modo.rawValue }
        
        if let encoded = try? JSONEncoder().encode(filtered) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        print("🔁 Modo \(modo.rawValue) resetado com sucesso.")
    }
    
    // 🔄 Resetar Todos os Modos
    func resetAllModes(){
        for modo in GameModo.allCases {
            resetMode(modo)
        }
        print("🔄 Todos os modos e pontuações foram resetados.")
    }
}
