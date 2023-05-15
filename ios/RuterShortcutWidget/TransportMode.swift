//
//  TransportMode.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 12/05/2023.
//

import Foundation
import SwiftUI


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
    
    static var transportModeColors: [TransportMode: Color] = [
        .bus: Color(red: 231/255, green: 1/255, blue: 0),
        .rail: Color(red: 34/255, green: 94/255, blue: 225/255),
        .tram: Color(red: 13/255, green: 144/255, blue: 239/255),
        .metro: Color(red: 237/255, green: 112/255, blue: 8/255),
        .foot: Color(red: 82/255, green: 83/255, blue: 93/255),
        .air: Color(.gray),
        .water: Color(.purple)
    ]
}
