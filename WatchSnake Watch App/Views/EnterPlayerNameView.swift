import SwiftUI

struct EnterPlayerNameView: View {
    @State private var isNavigating = false
    @State private var isGlowing = false
    @State private var playerName: String = UserDefaults.standard.string(forKey: "playerName") ?? "Jogador"

    var body: some View {
        NavigationStack {
            VStack(spacing: 4) {
                Spacer()
                
                HStack {
                    Text("Snaker")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.green)
                        .padding(.top, 10)
                    
                    Text("Name")
                        .foregroundColor(.red)
                        .font(.title3)
                        .bold()
                        .padding(.top, 10)
                }
                
                TextField("Digite seu nome", text: $playerName, onCommit: saveUserName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.4)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isGlowing ? Color.red : Color.green, lineWidth: isGlowing ? 5 : 3)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isGlowing)
                    )
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
                    .onAppear {
                        isGlowing.toggle()
                    }
                
                Spacer()
                
                Button(action: {
                    if !playerName.isEmpty {
                        saveUserName()
                        isNavigating = true
                    }
                }) {
                    Text("🐍")
                        .font(.title)
                        .frame(width: 45, height: 45)
                        .foregroundColor(.red)
                }
                .disabled(playerName.isEmpty)
                .buttonStyle(.plain)
                .padding(.bottom, 5)
            }
            .frame(maxHeight: 80)
            .padding(.horizontal, 20)
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isNavigating) {
                GameModeSelectionView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
            }
        }
    }
    
    func saveUserName() {
        UserDefaults.standard.set(playerName, forKey: "playerName")
    }
}

#Preview {
    EnterPlayerNameView()
}
