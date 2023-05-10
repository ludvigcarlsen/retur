//
//  Root.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 10/05/2023.
//

import Foundation

// MARK: - Root
struct Response: Codable {
    let data: Data
}

// MARK: - DataClass
struct Data: Codable {
    let trip: Trip
}

// MARK: - Trip
struct Trip: Codable {
    let tripPatterns: [TripPattern]
    let fromPlace, toPlace: Place
}

// MARK: - Place
struct Place: Codable {
    let name: String
}

// MARK: - TripPattern
struct TripPattern: Codable {
    let expectedStartTime: String
    let legs: [Leg]
    let expectedEndTime: String
}

// MARK: - Leg
struct Leg: Codable {
    let mode: TransportMode
    let distance: Double
    let line: Line?
}

// MARK: - Line
struct Line: Codable {
    let id, publicCode: String
}

enum TransportMode: String, Codable {
    case foot = "foot"
    case rail = "rail"
    case bus = "bus"
    case coach = "coach"
    case tram = "tram"
    case metro = "metro"
    case water = "water"
    case air = "air"
    case lift = "lift"
}


extension Response {
    static var `default`: Response {
        let line = Line(id: "1", publicCode: "21")
        let leg = Leg(mode: TransportMode.bus, distance: 100, line: line)
        let pattern = TripPattern(expectedStartTime: "", legs: [leg], expectedEndTime: "")
        let trip = Trip(tripPatterns: [pattern], fromPlace: Place(name: "Carl Berners plass"), toPlace: Place(name: "Tjuvholmen"))
        return Response(data: Data(trip: trip))
    }
}
