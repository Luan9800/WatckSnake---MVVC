import SwiftUI
import Combine
import WatchKit
import Foundation

struct SnakeGameView: View {
    @StateObject private var viewModel: SnakeViewModel
    @State private var showRanking = false
    @State private var animateColorFood = false
    @State private var flashBackground = false
    @State private var snakeBlockSize: CGFloat = 12
    let selectedMode: GameModo
    var isPreview: Bool = false

       init(selectedMode: GameModo, viewModel: SnakeViewModel? = nil, isPreview: Bool = false) {
           _viewModel = StateObject(wrappedValue: viewModel ?? SnakeViewModel(mode: selectedMode))
           self.selectedMode = selectedMode
           self.isPreview = isPreview
       }
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
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
                       #if DEBUG
                       if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
                           viewModel.startGameLoop()
                       }
                       #else
                       viewModel.startGame()
                       #endif
                   }
                   .onChange(of: viewModel.isInvincible) { _, _ in
                       withAnimation(.easeInOut(duration: 0.3)) {
                           snakeBlockSize = viewModel.isInvincible ? 18 : 13.5
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
                   // 👇 Coloque aqui, ainda DENTRO do NavigationStack
                   .navigationDestination(isPresented: $showRanking) {
                       HighScoresView(isPresented: $showRanking, selectedMode: selectedMode)
                   }
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
        
        VStack(spacing: 6) {
            Text("Pontuação: \(viewModel.model.score)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundColor(.white)
            
            Text("Nível: \(viewModel.model.level)")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.startGameLoop()
                    triggerHapticFeedback(type: .success)
                }) {
                    Text("🔄")
                        .font(.title2)
                        .bold()
                        .padding(6)
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    showRanking = true
                }) {
                    Text("🏆")
                        .font(.title2)
                        .bold()
                        .padding(6)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .buttonStyle(.plain)
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
                .frame(width: 13.5, height: 15.8)
                .animation(.easeInOut(duration: 0.3), value: snakeBlockSize)

                .overlay(
                    Group {
                        if viewModel.specialFood?.x == col && viewModel.specialFood?.y == row {
                            Circle()
                                .stroke(Color.yellow, lineWidth: 1.5)
                                .shadow(color: .yellow, radius: 2)
                        } else if viewModel.colorChangingFood?.x == col && viewModel.colorChangingFood?.y == row {
                            Circle()
                                .fill(Color.purple)
                                .scaleEffect(animateColorFood ? 1.2 : 0.9)
                                .opacity(0.6)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animateColorFood)
                        }
                    }
                )
        }
        .background(Color.black.opacity(0.5))
    }
}


private func isSnakeCell(row: Int, col: Int) -> Bool {
    viewModel.model.snake.contains(where: { $0.x == col && $0.y == row })
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
        return viewModel.snakeColor
    } else if let food = viewModel.model.food, food.x == col && food.y == row {
        return .red
    } else if let specialFood = viewModel.specialFood, specialFood.x == col && specialFood.y == row {
        return .yellow.opacity(0.8)
    } else if let bomb = viewModel.bomb, bomb.x == col && bomb.y == row {
        return .gray
    } else if viewModel.model.obstacles.contains(where: { $0.x == col && $0.y == row }) {
        return .white
    } else if let colorFood = viewModel.colorChangingFood, colorFood.x == col && colorFood.y == row {
        return .purple
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
