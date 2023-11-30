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


struct TripWidgetData {
    let id: Int?
    let trip: TripPattern?
    let from: String
    let to: String
    
    init(id: Int? = nil, trip: TripPattern?, from: String, to: String) {
        self.id = id
        self.trip = trip
        self.from = from
        self.to = to
    }
}

struct TripWidgetEntry : TimelineEntry {
    let date: Date
    let widgetData: TripWidgetData
    let type: EntryType
    let message: String?
    
    init(date: Date, widgetData: TripWidgetData, type: EntryType, message: String? = nil) {
        self.date = date
        self.widgetData = widgetData
        self.type = type
        self.message = message
    }
}

struct TripWidgetProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> TripWidgetEntry {
        let response = Response.default.data
        let trip = response.trip
        let data = TripWidgetData(trip: trip.tripPatterns[0], from: trip.fromPlace.name, to: trip.toPlace.name)
        return TripWidgetEntry(date: Date(), widgetData: data, type: .standard)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TripWidgetEntry) -> ()) {
        let response = Response.default.data
        let trip = response.trip
        let data = TripWidgetData(trip: trip.tripPatterns[0], from: trip.fromPlace.name, to: trip.toPlace.name)
        let entry = TripWidgetEntry(date: Date(), widgetData: data, type: .standard)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TripWidgetEntry>) -> ()) {
        let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
        let flutterData: FlutterData? = try? JSONDecoder().decode(FlutterData.self, from: (sharedDefaults?
            .string(forKey: "trip")?.data(using: .utf8)) ?? Data())
        
        // No trip saved in memory
        if (flutterData == nil) {
            let data = TripWidgetData(trip: nil, from: "", to: "")
            let entry = TripWidgetEntry(date: Date(), widgetData: data, type: .noData)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
            return
        }
        
        // Get trip departures
        CacheManager.getCachedTripOrFetch(data: flutterData!) { result in
            switch(result) {
            case .success(let response):
                var entries: [TripWidgetEntry] = []
                var entryDate = Date()
                var trip = response.data.trip
                let tripCount = trip.tripPatterns.count
                
                if (tripCount == 0) {
                    let data = TripWidgetData(trip: nil, from: trip.fromPlace.name, to: trip.toPlace.name)
                    let entry = TripWidgetEntry(date: entryDate, widgetData: data, type: .noTrips)
                    let timeline = Timeline(entries: [entry], policy: .after(entryDate.addingTimeInterval(60 * 60 * 2)))
                    completion(timeline)
                    return
                }
                
                // Remove first foot leg if requested
                if (!flutterData!.settings.includeFirstWalk) {
                    removeFirstFootLegFromPatterns(patterns: &trip.tripPatterns)
                }
                
                // Create first entry
                let firstData = TripWidgetData(id: 0, trip: trip.tripPatterns[0], from: trip.fromPlace.name, to: trip.toPlace.name)
                let firstEntry = TripWidgetEntry(date: Date(), widgetData: firstData, type: .standard)
                entries.append(firstEntry)
            

                for i in (1 ..< tripCount) {
                    let patterns = trip.tripPatterns
                    entryDate = ISO8601DateFormatter().date(from: patterns[i-1].legs[0].expectedStartTime)!
                    let data = TripWidgetData(id: i, trip: patterns[i], from: trip.fromPlace.name, to: trip.toPlace.name)
                    let entry = TripWidgetEntry(date: entryDate, widgetData: data, type: .standard)
                    entries.append(entry)
                }
                
                // Add "tap to refresh" entry on last trip departure
                entryDate = ISO8601DateFormatter().date(from: trip.tripPatterns[tripCount-1].legs[0].expectedStartTime)!
                let data = TripWidgetData(trip: nil, from: trip.fromPlace.name, to: trip.toPlace.name)
                let entry = TripWidgetEntry(date: entryDate, widgetData: data, type: .expired)
                entries.append(entry)
                
                // Request new timeline on last trip departure
                let timeline = Timeline(entries: entries, policy: .after(entryDate))
                completion(timeline)
                
            case .failure(let error):
                let data = TripWidgetData(trip: nil, from: flutterData!.from.name, to: flutterData!.to.name)
                let message = handleNetworkError(error)
                
                let entry = TripWidgetEntry(date: Date(), widgetData: data, type: .error, message: message)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct TripWidget: Widget {
    let kind: String = "TripWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TripWidgetProvider()) {
            entry in TripWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabledIfAvailable()
    }
}

struct TripWidgetEntryView : View {
    var entry: TripWidgetProvider.Entry
    
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

extension TripWidgetEntry {
    static var previewEntry1: TripWidgetEntry {
        let trip = Response.default.data.trip
        return TripWidgetEntry(date: Date(), widgetData: TripWidgetData(id: 1, trip: trip.tripPatterns[0], from: trip.fromPlace.name, to: trip.toPlace.name), type: .standard)
    }
    
    static var previewEntry2: TripWidgetEntry {
        let trip = Response.default.data.trip
        return TripWidgetEntry(date: Date(), widgetData: TripWidgetData(id: 2, trip: trip.tripPatterns[1], from: trip.fromPlace.name, to: trip.toPlace.name), type: .standard)
    }
    
    static var previewEntryExpired: TripWidgetEntry {
        let trip = Response.default.data.trip
        return TripWidgetEntry(date: Date(), widgetData: TripWidgetData(trip: nil, from: trip.fromPlace.name, to: trip.toPlace.name), type: .expired)
    }
    
    static var previewEntryNoData: TripWidgetEntry {
        return TripWidgetEntry(date: Date(), widgetData: TripWidgetData(trip: nil, from: "", to: ""), type: .noData)
    }
}



