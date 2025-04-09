import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/luancarlos/Downloads/Swift Projetos/Watch Snake /WatchSnake Watch App/Views/GameModeSelectionView.swift", line: 1)
import SwiftUI

struct GameModeSelectionView: View {
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = true
    @State private var showPurchaseAlert = false
    @State private var showHighScores = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * __designTimeFloat("#10898_0", fallback: 0.015)) {
                    Spacer()

                    NavigationLink(destination: SnakeGameView(selectedMode: .easy)) {
                        Text(__designTimeString("#10898_1", fallback: "Fácil"))
                            .onTapGesture {
                                print(__designTimeString("#10898_2", fallback: "botão facil tocado"))
                            }
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(__designTimeInteger("#10898_3", fallback: 15))
                    }

                    NavigationLink(destination: SnakeGameView(selectedMode: .medium)) {
                        Text(isPremiumUser ? __designTimeString("#10898_4", fallback: "Médio") : __designTimeString("#10898_5", fallback: "🔒 Médio"))
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPremiumUser ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(__designTimeInteger("#10898_6", fallback: 15))
                    }
                    .disabled(!isPremiumUser)

                    NavigationLink(destination: SnakeGameView(selectedMode: .hard)) {
                        Text(isPremiumUser ? __designTimeString("#10898_7", fallback: "Hard") : __designTimeString("#10898_8", fallback: "🔒 Hard"))
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPremiumUser ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(__designTimeInteger("#10898_9", fallback: 15))
                    }
                    .disabled(!isPremiumUser)

                    NavigationLink(destination: SnakeGameView(selectedMode: .expert)) {
                        Text(isPremiumUser ? __designTimeString("#10898_10", fallback: "Experiente") : __designTimeString("#10898_11", fallback: "🔒 Experiente"))
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPremiumUser ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(__designTimeInteger("#10898_12", fallback: 15))
                    }
                    .disabled(!isPremiumUser)

                    Spacer()
                }
                .padding(.horizontal, geometry.size.width * __designTimeFloat("#10898_13", fallback: 0.05))
                .buttonStyle(.plain)
                .alert(__designTimeString("#10898_14", fallback: "Apenas para usuários premium"), isPresented: $showPurchaseAlert) {
                    Button(__designTimeString("#10898_15", fallback: "OK"), role: .cancel) {}
                    Button(__designTimeString("#10898_16", fallback: "Comprar Premium")) {
                        isPremiumUser = __designTimeBoolean("#10898_17", fallback: true)
                    }
                }
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView(isPresented: $showHighScores, selectedMode: .easy)
            }
            .navigationBarBackButtonHidden(__designTimeBoolean("#10898_18", fallback: true))
            .toolbar(.hidden, for: .automatic)
        }
    }
}

#Preview {
    GameModeSelectionView()
}
