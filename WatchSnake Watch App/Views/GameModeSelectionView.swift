import SwiftUI

struct GameModeSelectionView: View {
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = false
    @State private var showPurchaseAlert = false
    @State private var selectedMode: GameMode? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 5) {
                Text("Modo do Jogo")
                    .font(.title3)
                    .bold()
                    .padding()

                // 🔹 Botão Easy (Liberado para todos)
                Button(action: {
                    selectedMode = .easy
                }) {
                    Text("Easy")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // 🔸 Botão Médio (Somente Premium)
                Button(action: {
                    if isPremiumUser {
                        selectedMode = .medium
                    } else {
                        showPurchaseAlert = true
                    }
                }) {
                    Text(isPremiumUser ? "Médio" : "🔒 Médio")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isPremiumUser ? Color.orange : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // 🔺 Botão Hard (Somente Premium)
                Button(action: {
                    if isPremiumUser {
                        selectedMode = .hard
                    } else {
                        showPurchaseAlert = true
                    }
                }) {
                    Text(isPremiumUser ? "Hard" : "🔒 Hard")
                        .font(.title3)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isPremiumUser ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .buttonStyle(.plain)
            .padding(.horizontal , 5)
            
            // 🚨 Alerta para usuários não premium
            .alert("Apenas para usuários premium", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) {}
                Button("Comprar Premium") {
                    isPremiumUser = true
                }
            }
            
            // 🔄 Navegação para SnakeGameView
            .navigationDestination(item: $selectedMode) { mode in
                SnakeGameView(selectedMode: mode)
            }
        }
    }
}
struct GameModeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GameModeSelectionView()
    }
}
