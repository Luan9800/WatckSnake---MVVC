import SwiftUI

struct HighScoresView: View {
    @State private var scores: [HighScore] = DatabaseManager.shared.getTopScores()
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Text("Pontuação 🏆")
                .font(.title3)
                .bold()
                .padding(.top, -20)

            if isLoading {
                Text("Carregando Pontuações..")
                    .foregroundColor(.gray)
                    .padding()
            } else if scores.isEmpty {
                Text("Nenhuma pontuação registrada :(")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(scores, id: \.id) { score in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(score.playerName)
                                .fontWeight(.bold)
                                .font(.headline)

                            HStack {
                                Text("Modo: ")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text(score.modo)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(GameModo(rawValue: score.modo)?.color ?? .white)
                            }
                        }
                        Spacer()
                        // 🔥 Aqui corrigimos o alinhamento da pontuação
                        VStack {
                            Text("\(score.score)")
                                .foregroundColor(.green)
                                .font(.headline)
                                .bold()

                            Text("pontos")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            scores = []
            isLoading = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let loadedScores = DatabaseManager.shared.getTopScores()
                print("📊 Dados carregados:", loadedScores)

                scores = loadedScores
                isLoading = false
            }
        }
    }
}

#Preview {
    HighScoresView()
}
