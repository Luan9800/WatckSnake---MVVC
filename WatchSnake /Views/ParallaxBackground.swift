import SwiftUI

struct ParallaxBackground: View {
    var showImage: Bool = true

    var body: some View {
        GeometryReader { geometry in
            if showImage {
                Image("pixel_icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
        }
    }
}

struct ContentView: View {
    var showImage: Bool = true

    var body: some View {
        ZStack {
            ParallaxBackground(showImage: showImage)

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
    ContentView(showImage: false) // Desativa imagem no preview pra evitar travamentos
}
