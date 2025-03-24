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
        let newScore = HighScore(playerName: playerName, score: score, level: level, modo: modo.rawValue , date: Date())
        
        scores.append(newScore)
        
        // Filtra os 3 melhores do jogador e mantém no banco
        let filteredScores = scores.filter { $0.playerName == playerName }
            .sorted { $0.score > $1.score }
        let topScores = Array(filteredScores.prefix(3))
        
        let finalScores = scores.filter { $0.playerName != playerName } + topScores

        if let encoded = try? JSONEncoder().encode(finalScores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func getTopScores() -> [HighScore] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([HighScore].self, from: savedData) {
            return decoded.sorted { $0.score > $1.score }
        }
        return []
    }
    
    func resetDatabase() {
           print("🔄 Resetando banco de dados...")
           UserDefaults.standard.removeObject(forKey: key)
           UserDefaults.standard.removeObject(forKey: lastScoreKey)
       }
}
