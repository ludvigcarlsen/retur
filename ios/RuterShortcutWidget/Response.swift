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
    var trip: Trip
}

// MARK: - Trip
struct Trip: Codable {
    var tripPatterns: [TripPattern]
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
    var legs: [Leg]
    
}

// MARK: - Leg
struct Leg: Codable {
    let mode: TransportMode
    let distance: Double
    let expectedStartTime: String
    let fromPlace: Place
    let line: Line?
    let nextLegs: [NextLeg]?
    let fromEstimatedCall: FromEstimatedCall?
    
}

// MARK: - Line
struct Line: Codable {
    let id: String, publicCode: String?
}

struct FromEstimatedCall: Codable {
    let destinationDisplay: DestinationDisplay
}

struct DestinationDisplay: Codable {
    let frontText: String
}

struct NextLeg: Codable {
    let expectedStartTime: String
}


extension Response {
    static var `default`: Response {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let leg1StartTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(400))
        let leg1NextLegStartTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(1000))
        let leg1NextLeg = NextLeg(expectedStartTime: leg1NextLegStartTime)
        
        let leg2StartTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(500))
        let leg2NextLegStartTime = ISO8601DateFormatter().string(from: Date().addingTimeInterval(900))
        let leg2NextLeg = NextLeg(expectedStartTime: leg2NextLegStartTime)
        
        let fromEstimatedCall = FromEstimatedCall(destinationDisplay: DestinationDisplay(frontText: "Tjuvholmen"))
        
        
        let leg1 = Leg(mode: TransportMode.bus, distance: 100, expectedStartTime: leg1StartTime, fromPlace: Place(name: "Carl Berners plass"), line: Line(id: "1", publicCode: "21"), nextLegs: [leg1NextLeg], fromEstimatedCall: fromEstimatedCall)
        let leg2 = Leg(mode: TransportMode.metro, distance: 100, expectedStartTime: leg2StartTime, fromPlace: Place(name: "Carl Berners plass"), line: Line(id: "2", publicCode: "5"), nextLegs: [leg2NextLeg], fromEstimatedCall: fromEstimatedCall)
        let leg3 = Leg(mode: TransportMode.air, distance: 100, expectedStartTime: "2023-05-12T13:50:41+02:00", fromPlace: Place(name: "Carl Berners plass"), line: Line(id: "3", publicCode: nil), nextLegs: [leg2NextLeg], fromEstimatedCall: fromEstimatedCall)
        let leg4 = Leg(mode: TransportMode.tram, distance: 100, expectedStartTime: "2023-05-12T13:55:41+02:00", fromPlace: Place(name: "Carl Berners plass"), line: Line(id: "3", publicCode: "17"), nextLegs: [leg2NextLeg], fromEstimatedCall: fromEstimatedCall)
        let leg5 = Leg(mode: TransportMode.water, distance: 100, expectedStartTime: "2023-05-12T14:01:41+02:00", fromPlace: Place(name: "Carl Berners plass"), line: Line(id: "4", publicCode: "2"), nextLegs: [leg2NextLeg], fromEstimatedCall: fromEstimatedCall)
        
        let pattern1 = TripPattern(expectedStartTime: "2023-05-12T13:44:41+02:00", expectedEndTime: "2023-05-12T14:30:50+02:00", legs: [leg1, leg2])
        let pattern2 = TripPattern(expectedStartTime: "2023-05-12T13:44:41+02:00", expectedEndTime: "2023-05-12T14:30:50+02:00", legs: [leg3, leg4])
        let pattern3 = TripPattern(expectedStartTime: "2023-05-12T13:44:41+02:00", expectedEndTime: "2023-05-12T14:30:50+02:00", legs: [leg5])
        
        let trip = Trip(tripPatterns: [pattern1, pattern2, pattern3], fromPlace: Place(name: "Carl Berners plass"), toPlace: Place(name: "Tjuvholmen"))
        return Response(data: ResponseData(trip: trip))
    }
}
