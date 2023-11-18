//
//  TripBoardWidget.swift
//  Runner
//
//  Created by Ludvig Marcel Carlsen on 11/11/2023.
//

import WidgetKit
import SwiftUI
import Intents
import Dispatch

struct TripBoardWidgetData {
    let trips: [TripPattern]
    let from: String
    let to: String
    let lastUpdated: Date
}

struct TripBoardWidgetEntry : TimelineEntry {
    let date: Date
    let widgetData: TripBoardWidgetData
    let type: EntryType
    let message: String?
    
    init(date: Date, widgetData: TripBoardWidgetData, type: EntryType, message: String? = nil) {
        self.date = date
        self.widgetData = widgetData
        self.type = type
        self.message = message
    }
}


struct TripBoardWidgetProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> TripBoardWidgetEntry {
        let response = Response.default.data
        let data = TripBoardWidgetData(trips: response.trip.tripPatterns, from: response.trip.fromPlace.name, to: response.trip.toPlace.name, lastUpdated: Date())
        return TripBoardWidgetEntry(date: Date(), widgetData: data, type: EntryType.standard)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TripBoardWidgetEntry) -> ()) {
        let response = Response.default.data
        let data = TripBoardWidgetData(trips: response.trip.tripPatterns, from: response.trip.fromPlace.name, to: response.trip.toPlace.name, lastUpdated: Date())
        let entry = TripBoardWidgetEntry(date: Date(), widgetData: data, type: EntryType.standard)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TripBoardWidgetEntry>) -> ()) {
        let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
        let flutterData: FlutterData? = try? JSONDecoder().decode(FlutterData.self, from: (sharedDefaults?
            .string(forKey: "trip")?.data(using: .utf8)) ?? Data())
        let now = Date()
        
        // No trip saved in memory
        if (flutterData == nil) {
            let data = TripBoardWidgetData(trips: [], from: "", to: "", lastUpdated: now)
            let entry = TripBoardWidgetEntry(date: now, widgetData: data, type: .noData)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
            return
        }
        
        // Get departures from saved trip
        NetworkManager.getTrip(data: flutterData!) { result in
            switch(result) {
            case .success(let response):
                var entries: [TripBoardWidgetEntry] = []
                var entryDate = Date()
                var trip = response.data.trip
                let tripCount = trip.tripPatterns.count
                
                if (tripCount == 0) {
                    let data = TripBoardWidgetData(trips: [], from: trip.fromPlace.name, to: trip.toPlace.name, lastUpdated: now)
                    let entry = TripBoardWidgetEntry(date: entryDate, widgetData: data, type: .noTrips)
                    let timeline = Timeline(entries: [entry], policy: .after(entryDate.addingTimeInterval(60 * 60 * 2)))
                    completion(timeline)
                    return
                }
                
                // Remove first foot leg if requested
                if (!flutterData!.settings.includeFirstWalk) {
                    removeFirstFootLegFromPatterns(patterns: &trip.tripPatterns)
                }
                
                // Create first entry
                let firstPatterns = Array(trip.tripPatterns.prefix(3))
                let firstData = TripBoardWidgetData(trips: firstPatterns, from: trip.fromPlace.name, to: trip.toPlace.name, lastUpdated: now)
                let firstEntry = TripBoardWidgetEntry(date: Date(), widgetData: firstData, type: .standard)
                entries.append(firstEntry)
                
                // Create remaining entries
                for i in 1..<(tripCount) {
                    let patterns = Array(trip.tripPatterns[i..<min(i+3, tripCount)])
                    
                    entryDate = ISO8601DateFormatter().date(from: trip.tripPatterns[i-1].legs[0].expectedStartTime)!
                    
                    let data = TripBoardWidgetData(trips: patterns, from: trip.fromPlace.name, to: trip.toPlace.name, lastUpdated: now)
                    let entry = TripBoardWidgetEntry(date: entryDate, widgetData: data, type: .standard)
                    entries.append(entry)
                }
                
                // Add "tap to refresh" entry on last trip departure
                entryDate = ISO8601DateFormatter().date(from: trip.tripPatterns[tripCount-1].legs[0].expectedStartTime)!
                let data = TripBoardWidgetData(trips: [], from: trip.fromPlace.name, to: trip.toPlace.name, lastUpdated: now)
                let entry = TripBoardWidgetEntry(date: entryDate, widgetData: data, type: .expired)
                entries.append(entry)
                
                // Request new timeline when third to last trip expires
                let expiryDate = ISO8601DateFormatter().date(from: trip.tripPatterns[max(tripCount-3, 0)].legs[0].expectedStartTime)!
                let timeline = Timeline(entries: entries, policy: .after(expiryDate))
                completion(timeline)
                    
            case .failure(let error):
                let message = handleNetworkError(error)
                let data = TripBoardWidgetData(trips: [], from: flutterData!.from.name, to: flutterData!.to.name, lastUpdated: now)
                
                let entry = TripBoardWidgetEntry(date: Date(), widgetData: data, type: .error, message: message)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct TripBoardWidget: Widget {
    let kind: String = "TripBoardWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TripBoardWidgetProvider()) {
            entry in TripBoardWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabledIfAvailable()
    }
}


struct TripBoardWidgetEntryView : View {
    var entry: TripBoardWidgetProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            TripBoardWidgetSmall(entry: entry)
        default:
            TripBoardWidgetMedium(entry: entry)
        }
    }
}


/*
func temp(trip: Trip, pattern: TripPattern, date: Date, minutesUntilDeparture: Int) -> [TripBoardWidgetEntry] {
    var entries: [TripWidgetEntry] = []
    
    for minute in (0...minutesUntilDeparture).reversed() {
        let data = TripWidgetData(trip: pattern, minutesUntilDeparture: minute, from: trip.fromPlace.name, to: trip.toPlace.name)
        let entry = TripWidgetEntry(date: date, widgetData: data, type: .standard)
        entries.append(entry)
    }
    
    return entries;
}
 */

