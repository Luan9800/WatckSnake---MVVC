import SwiftUI

struct ParallaxBackground: View {
    @State private var offset: CGFloat = -50

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.black.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
        .offset(y: offset)
        .onAppear {
            withAnimation(Animation.linear(duration: 6).repeatForever(autoreverses: true)) {
                offset = 50
            }
        }
    }
}
