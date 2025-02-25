import SwiftUI
import Combine
import WatchKit

struct SnakeGameView: View {
    @StateObject private var viewModel = SnakeViewModel()
    var selectedMode: GameMode

    var body: some View {
        ZStack {
            parallaxBackground() // Adiciona o fundo com efeito parallax

            VStack {
                if viewModel.isGameOver {
                    gameOverView()
                } else if viewModel.hasWon {
                    victoryView()
                } else {
                    gameGridView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 10)
        }
        .onAppear {
            Task {
                 viewModel.setGameMode(selectedMode) // ✅ Correção: usando `await`
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let horizontalAmount = gesture.translation.width
                    let verticalAmount = gesture.translation.height

                    if abs(horizontalAmount) > abs(verticalAmount) {
                        viewModel.changeDirection(to: horizontalAmount > 0 ? .right : .left)
                    } else {
                        viewModel.changeDirection(to: verticalAmount > 0 ? .down : .up)
                    }
                    triggerHapticFeedback(type: .directionUp)
                }
        )
    }

    private func parallaxBackground() -> some View {
        GeometryReader { geometry in
            Image("parallaxBackground") // Substitua pelo nome da sua imagem de fundo
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width * 1.2, height: geometry.size.height * 1.2)
                .offset(x: -geometry.size.width * 0.1, y: -geometry.size.height * 0.1)
                .blur(radius: 5) // Pequeno desfoque para um efeito mais imersivo
                .edgesIgnoringSafeArea(.all)
        }
    }

    private func gameOverView() -> some View {
        VStack {
            Text("\u{1F480} Perdeu")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .opacity(0.8)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.isGameOver)

            gameInfoView()
        }
    }

    private func victoryView() -> some View {
        VStack {
            Text("\u{1F3C6} Vitória!! \u{1F3C6}")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.yellow)
                .opacity(0.8)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.hasWon)

            gameInfoView()
        }
    }

    private func gameInfoView() -> some View {
        VStack(spacing: 8) {
            Text("Pontuação: \(viewModel.model.score)")
                .font(.title3)
                .bold()
                .padding()
                .foregroundColor(.white)

            Text("Nível: \(viewModel.model.level)")
                .font(.title3)
                .bold()
                .padding(.bottom, 10)
                .foregroundColor(.white)

            Button(action: {
                viewModel.startGameLoop()
                triggerHapticFeedback(type: .success)
            }) {
                Text("Reiniciar")
                    .font(.title3)
                    .bold()
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.red)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, -8)
        }
    }

    private func gameGridView() -> some View {
        VStack {
            GridStack(rows: viewModel.gridSize, columns: viewModel.gridSize) { row, col in
                Rectangle()
                    .foregroundColor(getCellColor(row: row, col: col))
                    .frame(width: 15, height: 15)
                    .overlay(
                        viewModel.specialFood?.x == col && viewModel.specialFood?.y == row ?
                            Circle()
                                .stroke(Color.yellow, lineWidth: 2)
                                .shadow(color: .yellow, radius: 5) // ✨ Efeito de brilho!
                            : nil
                    )
            }
            .background(Color.black.opacity(0.5))
        }
    }

    private func getCellColor(row: Int, col: Int) -> Color {
        if viewModel.model.snake.contains(where: { $0.x == col && $0.y == row }) {
            return .green
        } else if viewModel.model.food.x == col && viewModel.model.food.y == row {
            return .red
        } else if viewModel.specialFood?.x == col && viewModel.specialFood?.y == row {
            return .yellow.opacity(0.8) // ✨ Comida especial brilhante
        } else {
            return .black
        }
    }

    private func triggerHapticFeedback(type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
}

#Preview {
    SnakeGameView(selectedMode: .easy)
}
