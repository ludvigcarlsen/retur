//
//  SwapIntent.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 19/11/2023.
//

import AppIntents

@available(iOS 17.0, *)
struct SwapWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Swap trip"
    static var description = IntentDescription("Swap trip.")

    init() {}

    func perform() async throws -> some IntentResult {
        
        let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
        let flutterData: FlutterData? = try? JSONDecoder().decode(FlutterData.self, from: (sharedDefaults?
            .string(forKey: "trip")?.data(using: .utf8)) ?? Data())
        
        if (flutterData == nil) {
            return .result()
        }
        
        let newData = FlutterData(from: flutterData!.to, to: flutterData!.from, filter: flutterData!.filter, settings: flutterData!.settings)
        
        let test = try? JSONEncoder().encode(newData)
        
        if let test {
            let newDataString = String(data: test, encoding: .utf8)
            sharedDefaults!.set(newDataString, forKey: "trip")
            sharedDefaults!.synchronize()
        }
    
        return .result()
    }
}
