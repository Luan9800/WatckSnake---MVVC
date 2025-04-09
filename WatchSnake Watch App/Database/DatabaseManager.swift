import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let key = "highScores"
    private let lastScoreKey = "lastScore"
    
    private init() {
        if UserDefaults.standard.data(forKey: key) == nil {
            resetDatabase()
        }
    }
    
    func saveScore(playerName: String, score: Int, level: Int, modo: GameModo) {
        var scores = getTopScores()
        let newScore = HighScore(playerName: playerName, score: score, level: level, modo: modo.rawValue, date: Date())
        
        // ✅ Adiciona o novo score antes de filtrar
        scores.append(newScore)
        
        let winningScore: Int = {
            switch modo {
            case .easy: return 150
            case .medium: return 500
            case .hard: return 700
            case .expert: return 1000
            }
        }()
        
        // ✅ Mantém os 3 melhores scores do jogador
        let topScoresForPlayer = scores
            .filter { $0.playerName == playerName }
            .sorted { $0.score > $1.score }
            .prefix(3)
        
        
        let finalScores = scores.filter { $0.playerName != playerName } + topScoresForPlayer
        
        if let encoded = try? JSONEncoder().encode(finalScores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        if score >= winningScore {
            DispatchQueue.main.async {
                print("🎉 Parabéns \(playerName)! Você zerou o nível \(modo.rawValue) com \(score) pontos! 🎉")
            }
        }
    }
    
    func getTopScores() -> [HighScore] {
        guard let savedData = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([HighScore].self, from: savedData)
                .sorted { $0.score > $1.score }
        } catch {
            print("❌ Erro ao decodificar os scores: \(error.localizedDescription)")
            return []
        }
    }
    
    func resetDatabase() {
        print("🔄 Resetando Banco de Dados UserDefault...")
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: lastScoreKey)
    }
}
