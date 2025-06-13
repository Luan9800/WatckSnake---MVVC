//
//  Watch_App.swift
//  Watch App
//
//  Created by Luan Carlos on 07/05/25.
//

import AppIntents

struct Watch_App: AppIntent {
    static var title: LocalizedStringResource { "Watch App" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
