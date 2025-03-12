import SwiftUI

struct SnakeHomeView: View {
    var selectedMode: GameMode
    @State private var isActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isActive {
                    GameModeSelectionView()
                } else {
                    Image("snake_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 280)
                        .opacity(0.9)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isActive = true
                                }
                            }
                        }
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    SnakeHomeView(selectedMode: GameMode.easy)
}
