import func SwiftUI.__designTimeFloat
import func SwiftUI.__designTimeString
import func SwiftUI.__designTimeInteger
import func SwiftUI.__designTimeBoolean

#sourceLocation(file: "/Users/luancarlos/Downloads/Swift Projetos/Watch Snake /WatchSnake Watch App/Views/SnakeGameView.swift", line: 1)
import SwiftUI
import Combine
import CloudKit
import WatchKit
import Foundation

struct SnakeGameView: View {
    @StateObject private var viewModel =
    SnakeViewModel()
    @State private var showRanking = false
    @State private var animateColorFood = false
    var isPreview: Bool = false
    @State private var snakeBlockSize: CGFloat = 12
    var selectedMode: GameModo
    
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
                .padding(.bottom, __designTimeInteger("#11285_0", fallback: 5))
                .buttonStyle(PlainButtonStyle())
            }
            .onAppear {
                DispatchQueue.main.async {
                    viewModel.setGameModo(selectedMode)
                }
            }
            onChange(of: viewModel.isInvincible) { newValue, _ in
                withAnimation(.easeInOut(duration: __designTimeFloat("#11285_1", fallback: 0.3))) {
                    snakeBlockSize = newValue ? __designTimeInteger("#11285_2", fallback: 18) : __designTimeFloat("#11285_3", fallback: 13.5)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let horizontalAmount = gesture.translation.width
                    let verticalAmount = gesture.translation.height
                    
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        viewModel.changeDirection(to: horizontalAmount > __designTimeInteger("#11285_4", fallback: 0) ? .right : .left)
                    } else {
                        viewModel.changeDirection(to: verticalAmount > __designTimeInteger("#11285_5", fallback: 0) ? .down : .up)
                    }
                    triggerHapticFeedback(type: .directionUp)
                }
        )
        .navigationDestination(isPresented: $showRanking) {
            HighScoresView(isPresented:$showRanking, selectedMode: selectedMode)
        }
        .navigationBarHidden(__designTimeBoolean("#11285_6", fallback: true))
        .toolbar(.hidden, for: .automatic)
    }
    
private func gameOverView() -> some View {
    VStack(spacing: __designTimeInteger("#11285_7", fallback: 12)) {
        Text(__designTimeString("#11285_8", fallback: "☠️ Perdeu"))
            .font(.title2)
            .bold()
            .foregroundColor(.red)
            .opacity(__designTimeFloat("#11285_9", fallback: 0.9))
            .padding(.top, __designTimeInteger("#11285_10", fallback: 8))
        
        gameInfoView()
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(
        RoundedRectangle(cornerRadius: __designTimeInteger("#11285_11", fallback: 15))
            .fill(Color.black.opacity(__designTimeFloat("#11285_12", fallback: 0.7)))
            .shadow(radius: __designTimeInteger("#11285_13", fallback: 5))
    )
    .padding(.horizontal, __designTimeInteger("#11285_14", fallback: 10))
}

private func victoryView() -> some View {
    VStack {
        Text(__designTimeString("#11285_15", fallback: "🏆 Vitória!"))
            .font(.title2)
            .bold()
            .opacity(__designTimeFloat("#11285_16", fallback: 0.8))
            .animation(.easeInOut(duration: __designTimeFloat("#11285_17", fallback: 0.8)).repeatForever(autoreverses: __designTimeBoolean("#11285_18", fallback: true)), value: viewModel.hasWon)
        
        gameInfoView()
    }
}

private func gameInfoView() -> some View {
    VStack(spacing: __designTimeInteger("#11285_19", fallback: 5)) {
        Text("Pontuação: \(viewModel.model.score)")
            .font(.body)
            .bold()
            .foregroundColor(.white)
        
        Text("Nível: \(viewModel.model.level)")
            .font(.body)
            .bold()
            .foregroundColor(.white)
        
        HStack(spacing: __designTimeInteger("#11285_20", fallback: 12)) {
            Button(action: {
                viewModel.startGameLoop()
                triggerHapticFeedback(type: .success)
            }) {
                Text(__designTimeString("#11285_21", fallback: "🔄"))
                    .font(.title2)
                    .bold()
                    .padding(.vertical, __designTimeInteger("#11285_22", fallback: 5))
                    .padding(.horizontal, __designTimeInteger("#11285_23", fallback: 5))
                    .foregroundColor(.black)
                    .clipShape(Circle())
            }
            
            Button(action: {
                showRanking = __designTimeBoolean("#11285_24", fallback: true)
            }) {
                Text(__designTimeString("#11285_25", fallback: "🏆"))
                    .font(.title2)
                    .bold()
                    .padding(.vertical, __designTimeInteger("#11285_26", fallback: 5))
                    .padding(.horizontal, __designTimeInteger("#11285_27", fallback: 5))
                    .foregroundColor(.black)
                    .clipShape(Circle())
            }
        }
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: __designTimeInteger("#11285_28", fallback: 15))
            .fill(Color.black.opacity(__designTimeFloat("#11285_29", fallback: 0.6)))
            .shadow(radius: __designTimeInteger("#11285_30", fallback: 5))
    )
    .padding(.horizontal, __designTimeInteger("#11285_31", fallback: 10))
}

private func gameGridView() -> some View {
    VStack {
        GridStack(rows: viewModel.gridSize, columns: viewModel.gridSize) { row, col in
            Rectangle()
                .foregroundColor(getCellColor(row: row, col: col))
                .frame(width: __designTimeFloat("#11285_32", fallback: 13.5), height: __designTimeFloat("#11285_33", fallback: 15.8))
                .animation(.easeInOut(duration: __designTimeFloat("#11285_34", fallback: 0.3)), value: snakeBlockSize)
            //.frame(width: 12, height: 12)
                .overlay(
                    Group {
                        if viewModel.specialFood?.x == col && viewModel.specialFood?.y == row {
                            Circle()
                                .stroke(Color.yellow, lineWidth: __designTimeFloat("#11285_35", fallback: 1.5))
                                .shadow(color: .yellow, radius: __designTimeInteger("#11285_36", fallback: 2))
                        } else if viewModel.colorChangingFood?.x == col && viewModel.colorChangingFood?.y == row {
                            Circle()
                                .fill(Color.purple)
                                .scaleEffect(animateColorFood ? __designTimeFloat("#11285_37", fallback: 1.2) : __designTimeFloat("#11285_38", fallback: 0.9))
                                .opacity(__designTimeFloat("#11285_39", fallback: 0.6))
                                .animation(.easeInOut(duration: __designTimeFloat("#11285_40", fallback: 0.5)).repeatForever(autoreverses: __designTimeBoolean("#11285_41", fallback: true)), value: animateColorFood)
                        }
                    }
                )
        }
        .background(Color.black.opacity(__designTimeFloat("#11285_42", fallback: 0.5)))
    }
}


private func isSnakeCell(row: Int, col: Int) -> Bool {
    viewModel.model.snake.contains(where: { $0.x == col && $0.y == row })
}

private func pausedView() -> some View {
    VStack {
        Text(__designTimeString("#11285_43", fallback: "⏸ Pausado"))
            .font(.title3)
            .bold()
            .foregroundColor(.yellow)
        
        Button(action: {
            viewModel.resumeGame()
        }) {
            Text(__designTimeString("#11285_44", fallback: "▶️"))
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
        return .yellow.opacity(__designTimeFloat("#11285_45", fallback: 0.8))
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
        VStack(spacing: __designTimeInteger("#11285_46", fallback: 1)) {
            ForEach(__designTimeInteger("#11285_47", fallback: 0)..<rows, id: \.self) { row in
                HStack(spacing: __designTimeInteger("#11285_48", fallback: 1)) {
                    ForEach(__designTimeInteger("#11285_49", fallback: 0)..<columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
}

struct SnakeGameView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeGameView(selectedMode: .easy)
    }
}
