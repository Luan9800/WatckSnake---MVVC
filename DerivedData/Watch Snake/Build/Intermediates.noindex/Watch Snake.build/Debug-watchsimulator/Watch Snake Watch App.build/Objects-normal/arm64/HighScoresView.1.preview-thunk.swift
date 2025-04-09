import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/luancarlos/Downloads/Swift Projetos/Watch Snake /WatchSnake Watch App/Views/HighScoresView.swift", line: 1)
import SwiftUI

struct HighScoresView: View {
    @Binding var isPresented: Bool
    @State private var scores: [HighScore] = []
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var selectedMode: GameModo
    
    var body: some View {
        VStack(spacing: __designTimeInteger("#11041_0", fallback: 10)) {
            ZStack {
                Text(__designTimeString("#11041_1", fallback: "Pontuação 🏆"))
                    .font(.title3)
                    .bold()
                    .baselineOffset(__designTimeInteger("#11041_2", fallback: 2))
                
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: __designTimeString("#11041_3", fallback: "rectangle.portrait.and.arrow.right"))
                            .imageScale(.small)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, __designTimeInteger("#11041_4", fallback: 10))
            
            if isLoading {
                Text(__designTimeString("#11041_5", fallback: "Carregando Pontuações.."))
                    .foregroundColor(.gray)
                    .padding()
            } else if scores.isEmpty {
                Text(__designTimeString("#11041_6", fallback: "Nenhuma pontuação registrada :("))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(scores, id: \.id) { score in
                    HStack {
                        VStack(alignment: .leading, spacing: __designTimeInteger("#11041_7", fallback: 4)) {
                            Text(score.playerName)
                                .fontWeight(.bold)
                                .font(.headline)
                            
                            HStack {
                                Text(__designTimeString("#11041_8", fallback: "Modo: "))
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
                            
                            Text(__designTimeString("#11041_9", fallback: "pontos"))
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }
                    .padding(.vertical, __designTimeInteger("#11041_10", fallback: 8))
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            Task {
                scores = []
                isLoading = __designTimeBoolean("#11041_11", fallback: true)
                
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                scores = DatabaseManager.shared.getTopScores()
                isLoading = __designTimeBoolean("#11041_12", fallback: false)
                
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                
                if isPresented {
                    isPresented = __designTimeBoolean("#11041_13", fallback: false)
                } else {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(__designTimeBoolean("#11041_14", fallback: true))
        .toolbar(.hidden)
    }
}

#Preview {
    NavigationStack {
        HighScoresView(isPresented: .constant(__designTimeBoolean("#11041_15", fallback: true)), selectedMode: .easy)
    }
}
