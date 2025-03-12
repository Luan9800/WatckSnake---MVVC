import Foundation
import SwiftUI

class ScoreManager {
    private let key = "highScores"

    /// 🔥 **Salva uma nova pontuação**
    func saveScore(playerName: String, score: Int) {
        var scores = getScores()
        scores.append(ScoreEntry(playerName: playerName, score: score, date: Date()))
        
        // 🏆 Ordena do maior para o menor
        scores.sort { $0.score > $1.score }
        
        // 🔥 Mantém apenas os 5 melhores
        if scores.count > 5 { scores.removeLast() }

        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    /// 📊 **Obtém o ranking dos melhores jogadores**
    func getScores() -> [ScoreEntry] {
        guard let savedData = UserDefaults.standard.data(forKey: key),
              let decodedScores = try? JSONDecoder().decode([ScoreEntry].self, from: savedData) else {
            return []
        }
        return decodedScores
    }

    /// 🔄 **Reseta o ranking**
    func resetScores() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
