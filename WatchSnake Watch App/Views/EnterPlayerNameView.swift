import SwiftUI

struct EnterPlayerNameView: View {
    @State private var isNavigating = false
    @State private var playerName: String =
    UserDefaults.standard.string(forKey: "playerName") ?? ""
   
  var body: some View {
        NavigationStack {
            VStack(spacing: 4) {
                Spacer()
                
                HStack(){
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
              
                
                TextField("Digite seu nome", text: $playerName)
                    .textFieldStyle(.plain)
                    .padding()
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .padding(.horizontal,2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 5)
                        
                    )
                  //  .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
                
                Spacer()
                
                Button(action: {
                    if !playerName.isEmpty {
                        UserDefaults.standard.set(playerName, forKey: "playerName")
                        isNavigating = true
                    }
                }) {
                    Text("🐍")
                        .font(.title)
                        .frame(width: 45, height: 45)
                        .foregroundColor(.red)
                    
                }
                .disabled(playerName.isEmpty)
                .padding(.bottom, 5)
            }
            .frame(maxHeight: 80)
            .padding(.horizontal, 20)
            .ignoresSafeArea()
            .onAppear {
                playerName = ""
                
            }
            .navigationDestination(isPresented: $isNavigating) {
                GameModeSelectionView()
            }
        }
    }
}

#Preview {
    EnterPlayerNameView()
}
