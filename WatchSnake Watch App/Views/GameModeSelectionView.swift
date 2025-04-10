import SwiftUI
import WatchKit

struct GameModeSelectionView: View {
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = true
    @State private var showPurchaseAlert = false
    @State private var showHighScores = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.02) {
                  //  Spacer()

                    NavigationLink(destination: SnakeGameView(selectedMode: .easy)) {
                        Text("Fácil")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }

                    NavigationLink(destination: SnakeGameView(selectedMode: .medium)) {
                        Text(isPremiumUser ? "Médio" : "🔒 Médio")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPremiumUser ? Color.orange : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(!isPremiumUser)

                    NavigationLink(destination: SnakeGameView(selectedMode: .hard)) {
                        Text(isPremiumUser ? "Hard" : "🔒 Hard")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPremiumUser ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(!isPremiumUser)

                    NavigationLink(destination: SnakeGameView(selectedMode: .expert)) {
                        Text(isPremiumUser ? "Experiente" : "🔒 Experiente")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isPremiumUser ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(!isPremiumUser)

                    Spacer()
                }
                .padding(.horizontal, geometry.size.width * 0.05)
                .buttonStyle(.plain)
                .alert("Apenas para usuários premium", isPresented: $showPurchaseAlert) {
                    Button("OK", role: .cancel) {}
                    Button("Comprar Premium") {
                        isPremiumUser = true
                    }
                }
            }
            .sheet(isPresented: $showHighScores) {
                HighScoresView(isPresented: $showHighScores, selectedMode: .easy)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .automatic)
        }
    }
}

#Preview {
    GameModeSelectionView()
}
