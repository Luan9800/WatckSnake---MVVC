import SwiftUI
import Foundation

@main
struct WatchSnake_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            SnakeHomeView(selectedMode: GameModo.easy)
        }
    }
}
