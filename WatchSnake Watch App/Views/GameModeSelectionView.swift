import SwiftUI

struct GameModeSelectionView: View {
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = true
    @State private var showPurchaseAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 5) {
                Spacer()
                
                // Botão para modo fácil
                NavigationLink(destination: SnakeGameView(selectedMode: .easy)) {
                    Text("Fácil")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // Botão para modo médio (requer premium)
                NavigationLink(destination: SnakeGameView(selectedMode: .medium)) {
                    Text(isPremiumUser ? "Médio" : "🔒 Médio")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isPremiumUser ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isPremiumUser)

                // Botão para modo difícil (requer premium)
                NavigationLink(destination: SnakeGameView(selectedMode: .hard)) {
                    Text(isPremiumUser ? "Hard" : "🔒 Hard")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isPremiumUser ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isPremiumUser)

                // Botão para modo experiente (requer premium)
                NavigationLink(destination: SnakeGameView(selectedMode: .expert)) {
                    Text(isPremiumUser ? "Experiente" : "🔒 Experiente")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isPremiumUser ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isPremiumUser)
            }
            .padding()
            .buttonStyle(.plain)
            .padding(.horizontal, 14)

            // Alerta para usuários não premium
            .alert("Apenas para usuários premium", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) {}
                Button("Comprar Premium") {
                    isPremiumUser = true
                }
            }
        }
    }
}

#Preview {
    GameModeSelectionView()
}
