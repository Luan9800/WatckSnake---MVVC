import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/luancarlos/Downloads/Swift Projetos/Watch Snake /WatchSnake Watch App/Views/ParallaxBackground.swift", line: 1)
import SwiftUI

struct ParallaxBackground: View {
    var showImage: Bool = true

    var body: some View {
        GeometryReader { geometry in
            if showImage {
                Image(__designTimeString("#11163_0", fallback: "pixel_icon"))
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
                Text(__designTimeString("#11163_1", fallback: "Conteúdo do App"))
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView(showImage: __designTimeBoolean("#11163_2", fallback: false)) // Desativa imagem no preview pra evitar travamentos
}
