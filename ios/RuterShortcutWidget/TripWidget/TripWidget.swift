//
//  ios_widget_flutter.swift
//  ios widget flutter
//
//  Created by Ludvig Marcel Carlsen on 09/05/2023.
//

import WidgetKit
import SwiftUI
import Intents
import Dispatch


struct WidgetData {
    let trip: TripPattern?
    let from: String
    let to: String
}

struct TripWidgetEntry : TimelineEntry {
    let date: Date
    let widgetData: WidgetData
    let type: EntryType
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> TripWidgetEntry {
        let response = Response.default.data
        let data = WidgetData(trip: response.trip.tripPatterns[0], from: response.trip.fromPlace.name, to: response.trip.toPlace.name)
        return TripWidgetEntry(date: Date(), widgetData: data, type: EntryType.standard)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TripWidgetEntry) -> ()) {
        let response = Response.default.data
        let data = WidgetData(trip: response.trip.tripPatterns[0], from: response.trip.fromPlace.name, to: response.trip.toPlace.name)
        let entry = TripWidgetEntry(date: Date(), widgetData: data, type: EntryType.standard)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TripWidgetEntry>) -> ()) {
        let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
        let flutterData: FlutterData? = try? JSONDecoder().decode(FlutterData.self, from: (sharedDefaults?
            .string(forKey: "trip")?.data(using: .utf8)) ?? Data())
        
        if (flutterData == nil) {
            // TODO no trip has been added yet, display "tap to get started" view
        }
        

        NetworkManager.getTrip(data: flutterData!) { result in
            switch(result) {
            case .success(let response):
                var entries: [TripWidgetEntry] = []
                var currentDate = Date()
                let trip = response.data.trip
                
                for i in (0 ..< trip.tripPatterns.count) {
                    let pattern = trip.tripPatterns[i]
                    let data = WidgetData(trip: pattern, from: trip.fromPlace.name, to: trip.toPlace.name)
                    let entry = TripWidgetEntry(date: currentDate, widgetData: data, type: .standard)
                    currentDate = ISO8601DateFormatter().date(from: pattern.legs[0].expectedStartTime)!
                    entries.append(entry)
                }

                let data = WidgetData(trip: nil, from: trip.fromPlace.name, to: trip.toPlace.name)
                let entry = TripWidgetEntry(date: currentDate, widgetData: data, type: .expired)
                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .after(currentDate))
                completion(timeline)
                    
            case .failure(let error):
                let response = Response.default.data
                let data = WidgetData(trip: response.trip.tripPatterns[0], from: response.trip.fromPlace.name, to: response.trip.toPlace.name)
                let entry = TripWidgetEntry(date: Date(), widgetData: data, type: .error)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct TripWidget: Widget {
    let kind: String = "TripWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) {
            entry in TripWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TripWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            TripWidgetSmall(entry: entry)
        default:
            TripWidgetMedium(entry: entry)
        }
    }
}

struct OverflowCard : View {
    var count: Int
    
    var body: some View {
        Text("+\(count)")
            .padding(3)
            .background(Color(red: 68/255, green: 79/255, blue: 100/255))
            .cornerRadius(5)
            .foregroundColor(Color(red: 104/255, green: 130/255, blue: 184/255))
            .font(.system(size: 12, weight: .bold)).padding(0)
    }
}

struct TransportModeCard : View {
    var mode: TransportMode
    var publicCode: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 1.5) {
            
            Image(mode.rawValue).resizable().scaledToFit().frame(width: 13)
            publicCode.map { Text($0).font(.system(size: 12, weight: .bold)).padding(0) }
        }
        .padding(3)
        .background(TransportMode.transportModeColors[mode])
        .cornerRadius(5)
    }
}


func minutesFromNow(iso8601Date: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from: iso8601Date) else {
        return "Invalid Date"
    }
    let minutesFromNow = Int(date.timeIntervalSinceNow / 60)
    return String(minutesFromNow)
}


func isoDateTohhmm(isoDate: String) -> String {
    let date = ISO8601DateFormatter().date(from: isoDate)!
    return date.toHHMM()
}


extension Date {
    func toHHMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}


func getLegsExcludeFoot(legs: [Leg]) -> [Leg] {
 return legs.filter { $0.mode != TransportMode.foot }
}
 
