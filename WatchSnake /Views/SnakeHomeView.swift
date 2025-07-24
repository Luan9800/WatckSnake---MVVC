import SwiftUI
import WatchKit

struct SnakeHomeView: View {
    @State private var isActive = false
    var selectedMode: GameModo
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                if isActive {
                    GameTutorialView(isShowingTutorial: $isActive)
                } else {
                    Image("snake_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 270, height: 270)
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
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .automatic)
        }
    }
}

#Preview {
    SnakeHomeView(selectedMode: GameModo.easy)
}
