//
//  Root.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 10/05/2023.
//

import Foundation

// MARK: - Root
struct Response: Codable {
    let data: ResponseData
}

// MARK: - DataClass
struct ResponseData: Codable {
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
    let expectedEndTime: String
    let legs: [Leg]
}

// MARK: - Leg
struct Leg: Codable {
    let mode: TransportMode
    let distance: Double
    let expectedStartTime: String
    let line: Line?
}

// MARK: - Line
struct Line: Codable {
    let id: String, publicCode: String?
}


extension Response {
    static var `default`: Response {
        let leg1 = Leg(mode: TransportMode.bus, distance: 100, expectedStartTime: "2023-05-12T13:44:41+02:00", line: Line(id: "1", publicCode: "21"))
        let leg2 = Leg(mode: TransportMode.metro, distance: 100, expectedStartTime: "2023-05-12T13:46:41+02:00", line: Line(id: "2", publicCode: "5"))
        let leg3 = Leg(mode: TransportMode.air, distance: 100, expectedStartTime: "2023-05-12T13:50:41+02:00", line: Line(id: "3", publicCode: nil))
        let leg4 = Leg(mode: TransportMode.tram, distance: 100, expectedStartTime: "2023-05-12T13:55:41+02:00", line: Line(id: "3", publicCode: "17"))
        let leg5 = Leg(mode: TransportMode.water, distance: 100, expectedStartTime: "2023-05-12T14:01:41+02:00", line: Line(id: "4", publicCode: "2"))
        
        
        let pattern1 = TripPattern(expectedStartTime: "2023-05-12T13:44:41+02:00", expectedEndTime: "2023-05-12T14:30:50+02:00", legs: [leg1, leg2])
        let pattern2 = TripPattern(expectedStartTime: "2023-05-12T13:44:41+02:00", expectedEndTime: "2023-05-12T14:30:50+02:00", legs: [leg3, leg4])
        let pattern3 = TripPattern(expectedStartTime: "2023-05-12T13:44:41+02:00", expectedEndTime: "2023-05-12T14:30:50+02:00", legs: [leg5])
        
        let trip = Trip(tripPatterns: [pattern1, pattern2, pattern3], fromPlace: Place(name: "Carl Berners plass"), toPlace: Place(name: "Tjuvholmen"))
        return Response(data: ResponseData(trip: trip))
    }
}