//
//  RefreshIntent.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 18/11/2023.
//

import AppIntents

@available(iOS 17.0, *)
struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh widget"
    static var description = IntentDescription("Refresh widget.")

    init() {}
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
