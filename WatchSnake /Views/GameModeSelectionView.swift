import SwiftUI
import WatchKit

struct GameModeSelectionView: View {
    @AppStorage("isPremiumUser") private var isPremiumUser: Bool = true
    @State private var showPurchaseAlert = false
    @State private var showHighScores = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 5) {
                    // Botão Fácil
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
                    
                    // Botão Médio
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
                    
                    // Botão Difícil
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
                    
                    // Botão Experiente
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
                    
                    // Botão Configurações
                    NavigationLink(destination: SettingsView()) {
                        Text("Configurações")
                            .font(.title3)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrowshape.turn.up.backward.circle")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            Text("Voltar")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)
            }
        }
        .buttonStyle(.plain)
        .alert("Apenas para usuários premium", isPresented: $showPurchaseAlert) {
            Button("OK", role: .cancel) {}
            Button("Comprar Premium") {
                isPremiumUser = true
            }
        }
        .sheet(isPresented: $showHighScores) {
            HighScoresView(isPresented: $showHighScores, selectedMode: .easy)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .automatic)
    }
}

#Preview {
    GameModeSelectionView()
}
