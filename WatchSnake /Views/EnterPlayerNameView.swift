import SwiftUI
import WatchKit

struct EnterPlayerNameView: View {
    @State private var pulse = false
    @State private var isGlowing = false
    @State private var glowPulse = false
    @State private var isNavigating = false
    @State private var playerName: String = ""
    
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
                
                TextField(
                    playerName.isEmpty ? "Digite seu Nome:" : "",
                    text: $playerName,
                    onCommit: saveUserName
                )
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(glowPulse ? Color.red : Color.green, lineWidth: 4)
                        .shadow(color: (glowPulse ? Color.green : Color.red).opacity(0.8), radius: 5)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: glowPulse)
                )
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .onAppear {
                    glowPulse.toggle()
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        glowPulse.toggle()
                    }
                    autoFillUserNameIfPossible()
                }
                
                Spacer()
                
                Button(action: {
                    let trimmed = playerName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty && trimmed.count > 2 {
                        playerName = trimmed
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
                .scaleEffect(pulse ? 1.1 : 1.0)
                .buttonStyle(.plain)
                .padding(.bottom, 5)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                .onAppear {
                    pulse = true
                }
            }
            .frame(maxHeight: 80)
            .padding(.horizontal, 20)
            .ignoresSafeArea()
            .toolbar(.hidden, for: .automatic)
            .navigationDestination(isPresented: $isNavigating) {
                GameModeSelectionView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                
            }
        }
    }
    
    private func saveUserName() {
        UserDefaults.standard.set(playerName, forKey: "playerName")
    }
    
    private func autoFillUserNameIfPossible() {
        let savedName = UserDefaults.standard.string(forKey: "playerName") ?? ""
        guard savedName.isEmpty else {
            playerName = savedName
            return
        }
        
        let deviceName = WKInterfaceDevice.current().name
        if let name = extractName(from: deviceName) {
            playerName = name
            saveUserName()
        }
    }
    
    /// Exemplo: "Apple Watch de João" → "João"
    private func extractName(from deviceName: String) -> String? {
        if let range = deviceName.range(of: " de ") {
            let name = deviceName[range.upperBound...].trimmingCharacters(in: .whitespaces)
            return name.isEmpty ? nil : name
        }
        return nil
    }
}

#Preview {
    EnterPlayerNameView()
}
