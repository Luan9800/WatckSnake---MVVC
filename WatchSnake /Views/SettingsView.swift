import SwiftUI

struct SettingsView: View {
    @State private var animateSnake = false
    @State private var showingConfirmation = false
    @State private var selectedMode: GameModo? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                HStack(spacing: 8) {
                    Text("Configuração")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .red.opacity(0.5), radius: 2, x: 1, y: 1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text("🐍")
                        .font(.title3)
                        .scaleEffect(animateSnake ? 1.1 : 1.0)
                        .rotationEffect(.degrees(animateSnake ? 5 : -5))
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateSnake)
                }
                .onAppear {
                    animateSnake = true
                }
                
                Spacer()
                
                ForEach(GameModo.allCases, id: \.self) { modo in
                    Button(action: {
                        selectedMode = modo
                        showingConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Resetar \(modo.rawValue)")
                                .font(.subheadline)
                                .bold()
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .background(modo.color)
                        .cornerRadius(12)
                    }
                }
                
                Button(action: {
                    selectedMode = nil
                    showingConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Text("Resetar Tudo")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        Spacer()
                    }
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.top, 5)
                
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
            }
            .buttonStyle(.plain)
            .padding()
            .alert("Tem certeza?", isPresented: $showingConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Resetar", role: .destructive) {
                    if let modo = selectedMode {
                        DatabaseManager.shared.resetMode(modo)
                    } else {
                        DatabaseManager.shared.resetAllModes()
                    }
                }
            } message: {
                Text("Essa Ação Apagará o Progresso e as Pontuações do Modo Selecionado.")
            }
            
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SettingsView()
}
