//
//  Watch_Snake.swift
//  Watch Snake
//
//  Created by Luan Carlos on 07/05/25.
//

import AppIntents

struct Watch_Snake: AppIntent {
    static var title: LocalizedStringResource { "Watch Snake" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
