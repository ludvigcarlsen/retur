//
//  IntentWrapper.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 20/11/2023.
//

import Foundation
import AppIntents
import SwiftUI

struct IntentWrapper : View {
    let content: some View
    
    @ViewBuilder
    func refreshView() -> some View {
        if #available(iOS 17.0, *) {
            Button(intent: RefreshWidgetIntent()) {
                content
            }
        } else {
            content
        }
    }
}
