import Foundation
import SwiftUI

enum Direction {
    case up, down ,left ,right
}

enum GameMode: String{
    case easy = "Fácil"
    case medium = "Médio"
    case hard = "Difícil"
}

struct SnakeModel {
    
    var snake:[(x: Int, y: Int)]
    var food:(x: Int, y: Int)
    var direction: Direction
    var score: Int
    var level : Int
}
