//
//  FlutterData.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 12/05/2023.
//

import Foundation



struct FlutterData: Codable {
    let from, to: StopPlace
    let filter: Set<TransportMode>
}

struct StopPlace: Codable {
    let id: String
    let name: String
    let latitude, longitude: Double
}

extension FlutterData {
    static var `default`: FlutterData {
        let from = StopPlace(id: "NSR:StopPlace:58366", name: "Alna stasjon", latitude: 59.932402, longitude: 10.835344)
        let to = StopPlace(id: "NSR:StopPlace:385", name: "Jernbanetorget", latitude: 59.911701, longitude: 10.750412)
        let filter: Set<TransportMode> = Set<TransportMode>()
        return FlutterData(from: from, to: to, filter: filter)
    }
}
