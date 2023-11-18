//
//  ios_widget_flutterBundle.swift
//  ios widget flutter
//
//  Created by Ludvig Marcel Carlsen on 09/05/2023.
//

import WidgetKit
import SwiftUI

@main
struct RuterShortcutBundle: WidgetBundle {
    var body: some Widget {
        TripWidget()
        TripBoardWidget()
    }
}

struct TripWidget_Previews: PreviewProvider {
   
    static var previews: some View {
        let response = Response.default.data
        let tripWidgetData = TripWidgetData(trip: response.trip.tripPatterns[0], from: response.trip.fromPlace.name, to: response.trip.toPlace.name)
        
        let tripBoardWidgetData = TripBoardWidgetData(trips: response.trip.tripPatterns, from: response.trip.fromPlace.name, to: response.trip.toPlace.name, lastUpdated: Date())
        
        Group {
            
            // TripWidget Small
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .standard))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .expired))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .noTrips))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .noData))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .error))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // TripWidget Medium
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .standard))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .expired))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .noTrips))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .noData))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: tripWidgetData, type: .error))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            // TripBoardWidget Small
            TripBoardWidgetSmall(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .standard))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripBoardWidgetSmall(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .expired))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripBoardWidgetSmall(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .noTrips))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripBoardWidgetSmall(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .noData))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripBoardWidgetSmall(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .error))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // TripBoardWidget Medium
            TripBoardWidgetMedium(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .standard))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripBoardWidgetMedium(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .expired))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripBoardWidgetMedium(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .noTrips))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripBoardWidgetMedium(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .noData))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripBoardWidgetMedium(entry: TripBoardWidgetEntry(date: Date(), widgetData: tripBoardWidgetData, type: .error))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

