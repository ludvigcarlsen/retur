//
//  FlutterData.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 12/05/2023.
//

import Foundation



struct FlutterData: Codable {
    let from, to: StopPlace
    let filter: Filter
    let settings: TripSettings
}

struct StopPlace: Codable {
    let id: String?
    let name: String
    let latitude, longitude: Double
}

struct Filter: Codable {
    let not: ExcludeModes
    let walkSpeed: Double
}

struct TripSettings: Codable {
    let isDynamicTrip: Bool
    let includeFirstWalk: Bool
}

struct ExcludeModes: Codable {
    let transportModes: Set<TransportMode>
}

extension FlutterData {
    static var `default`: FlutterData {
        let from = StopPlace(id: "NSR:StopPlace:58366", name: "Alna stasjon", latitude: 59.932402, longitude: 10.835344)
        let to = StopPlace(id: "NSR:StopPlace:385", name: "Jernbanetorget", latitude: 59.911701, longitude: 10.750412)
        let not = ExcludeModes(transportModes: Set())
        return FlutterData(from: from, to: to, filter: Filter(not: not, walkSpeed: 0.2), settings: TripSettings(isDynamicTrip: false, includeFirstWalk: false))
    }
}
