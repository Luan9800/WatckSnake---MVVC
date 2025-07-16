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
        
        // ✅ Checagem de "vitória" por modo
        let winningScore: Int = {
            switch modo {
            case .easy: return 150
            case .medium: return 500
            case .hard: return 700
            case .expert: return 1000
            }
        }()
        
        if score >= winningScore {
            DispatchQueue.main.async {
                print("🎉 Parabéns \(playerName)! Você zerou o nível \(modo.rawValue) com \(score) pontos! 🎉")
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
    
    // MARK: - Resetar banco
    func resetDatabase() {
        print("🔄 Resetando banco de dados UserDefaults...")
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: lastScoreKey)
    }
}
