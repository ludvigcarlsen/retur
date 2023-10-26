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
        
        // No trip saved in memory
        if (flutterData == nil) {
            let data = WidgetData(trip: nil, from: "", to: "")
            let entry = TripWidgetEntry(date: Date(), widgetData: data, type: .noData)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
            return
        }
        
        
        // Get departures from saved trip
        NetworkManager.getTrip(data: flutterData!) { result in
            switch(result) {
            case .success(let response):
                var entries: [TripWidgetEntry] = []
                var currentDate = Date()
                var trip = response.data.trip
                let tripCount = trip.tripPatterns.count
                
                if (tripCount == 0) {
                    let data = WidgetData(trip: nil, from: trip.fromPlace.name, to: trip.toPlace.name)
                    let entry = TripWidgetEntry(date: currentDate, widgetData: data, type: .noTrips)
                    let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(60 * 60 * 2)))
                    completion(timeline)
                    return
                }
                
                // Remove first foot leg if requested
                if (!flutterData!.settings.includeFirstWalk) {
                    removeFirstFootLegFromPatterns(patterns: &trip.tripPatterns)
                }
                
                // Create first entry
                let firstData = WidgetData(trip: trip.tripPatterns[0], from: trip.fromPlace.name, to: trip.toPlace.name)
                let firstEntry = TripWidgetEntry(date: Date(), widgetData: firstData, type: .standard)
                entries.append(firstEntry)
                
                for i in (1 ..< tripCount) {
                    let pattern = trip.tripPatterns[i]
                    let data = WidgetData(trip: pattern, from: trip.fromPlace.name, to: trip.toPlace.name)
                    let entry = TripWidgetEntry(date: currentDate, widgetData: data, type: .standard)
                    currentDate = ISO8601DateFormatter().date(from: trip.tripPatterns[i-1].legs[0].expectedStartTime)!
                    entries.append(entry)
                }
                
                // Add "tap to refresh" entry on last trip departure
                let updateAt = ISO8601DateFormatter().date(from: trip.tripPatterns[tripCount-1].legs[0].expectedStartTime)!
                let data = WidgetData(trip: nil, from: trip.fromPlace.name, to: trip.toPlace.name)
                let entry = TripWidgetEntry(date: updateAt, widgetData: data, type: .expired)
                entries.append(entry)
                
                // Request new timeline on last trip departure
                let timeline = Timeline(entries: entries, policy: .after(updateAt))
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
        .contentMarginsDisabledIfAvailable()
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

struct EmptyView : View {
    let message: String
    
    var body: some View {
        ZStack() {
            ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
            VStack() {
                Spacer()
                Text(message)
                Spacer()
            }
            .padding(EdgeInsets.init(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .foregroundColor(.white)
        .font(.system(size: 12))
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

func removeFirstFootLeg(legs: inout [Leg]) {
    if let firstLeg = legs.first, firstLeg.mode == TransportMode.foot {
        legs.removeFirst()
    }
}

func removeFirstFootLegFromPatterns(patterns: inout [TripPattern]) {
    for i in patterns.indices {
        removeFirstFootLeg(legs: &patterns[i].legs)
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
