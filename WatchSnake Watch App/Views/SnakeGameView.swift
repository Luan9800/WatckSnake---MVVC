import SwiftUI
import Combine
import CloudKit
import WatchKit
import Foundation

struct SnakeGameView: View {
    @StateObject private var viewModel = SnakeViewModel()
    @State private var showRanking = false
    var selectedMode: GameModo
    
    var body: some View {
        NavigationStack {
            ZStack {
                ParallaxBackground()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isPaused {
                        pausedView()
                    } else if viewModel.isGameOver {
                        gameOverView()
                    } else if viewModel.hasWon {
                        victoryView()
                    } else {
                        gameGridView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 5)
                .buttonStyle(PlainButtonStyle())
            }
            .onAppear {
                Task {
                    viewModel.setGameModo(selectedMode)
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
            .navigationDestination(isPresented: $showRanking) {
                HighScoresView()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .automatic)
        }
    }
    
    private func gameOverView() -> some View {
        VStack(spacing: 12) {
            Text("☠️ Perdeu")
                .font(.title2)
                .bold()
                .foregroundColor(.red)
                .opacity(0.9)
                .padding(.top, 8)

            gameInfoView()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.7))
                .shadow(radius: 5)
        )
        .padding(.horizontal, 10)
    }
    
    private func victoryView() -> some View {
        VStack {
            Text("🏆 Vitória!")
                .font(.title2)
                .bold()
                .opacity(0.8)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.hasWon)
            
            gameInfoView()
        }
    }
    
    private func gameInfoView() -> some View {
        VStack(spacing: 10) {
            Text("Pontuação: \(viewModel.model.score)")
                .font(.body)
                .bold()
                .foregroundColor(.white)

            Text("Nível: \(viewModel.model.level)")
                .font(.body)
                .bold()
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.startGameLoop()
                    triggerHapticFeedback(type: .success)
                }) {
                    Text("🔄")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .foregroundColor(.black)
                        .clipShape(Circle())
                }

                Button(action: {
                    showRanking = true
                }) {
                    Text("🏆")
                        .font(.title2)
                        .bold()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .foregroundColor(.black)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.6))
                    .shadow(radius: 5)
        )
        .padding(.horizontal, 10)
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
                                .stroke(Color.yellow, lineWidth: 1.5)
                                .shadow(color: .yellow, radius: 2)
                        : nil
                    )
            }
            .background(Color.black.opacity(0.5))
        }
    }

    private func pausedView() -> some View {
        VStack {
            Text("⏸ Pausado")
                .font(.title3)
                .bold()
                .foregroundColor(.yellow)

            Button(action: {
                viewModel.resumeGame()
            }) {
                Text("▶️")
                    .font(.title3)
                    .bold()
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
    }

    private func getCellColor(row: Int, col: Int) -> Color {
        if viewModel.model.snake.contains(where: { $0.x == col && $0.y == row }) {
            return .green
        } else if viewModel.model.food.x == col && viewModel.model.food.y == row {
            return .red
        } else if viewModel.specialFood?.x == col && viewModel.specialFood?.y == row {
            return .yellow.opacity(0.8)
        } else if viewModel.bomb?.x == col && viewModel.bomb?.y == row {
            return .gray
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
        VStack(spacing: 1) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 1) {
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
