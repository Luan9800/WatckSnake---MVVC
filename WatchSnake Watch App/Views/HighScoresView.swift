import SwiftUI

struct HighScoresView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var scoreManager = ScoreManager()
    
    var body: some View {
        VStack {
            Text("🏆 Ranking Global")
                .font(.title)
                .bold()
                .padding()
            
            List(scoreManager.scores) { score in
                HStack {
                    Text(score.playerName ?? "Jogador Desconhecido")
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(score.score) pontos")
                        .foregroundColor(.blue)
                }
            }
            
            Button("Voltar") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .onAppear {
            scoreManager.fetchScores()
        }
    }
}

#Preview {
    HighScoresView()
}
