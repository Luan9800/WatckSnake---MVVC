import SwiftUI

struct HighScoresView: View {
    @Binding var isPresented: Bool
    @State private var scores: [HighScore] = []
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var selectedMode: GameModo
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Pontuação 🏆")
                    .font(.title3)
                    .bold()
                    .baselineOffset(2)
                
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .imageScale(.small)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
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
            Task {
                scores = []
                isLoading = true
                
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                scores = DatabaseManager.shared.getTopScores()
                isLoading = false
                
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                
                if isPresented {
                    isPresented = false
                } else {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
    }
}

#Preview {
    NavigationStack {
        HighScoresView(isPresented: .constant(true), selectedMode: .easy)
    }
}
