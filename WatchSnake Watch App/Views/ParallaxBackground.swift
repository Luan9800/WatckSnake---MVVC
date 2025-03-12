import SwiftUI

struct ParallaxBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Image("pixel_icon")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .ignoresSafeArea()
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            ParallaxBackground()
            
            VStack {
                Text("Conteúdo do App")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
