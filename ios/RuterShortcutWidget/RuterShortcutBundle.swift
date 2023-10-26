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
    }
}

struct TripWidget_Previews: PreviewProvider {
   
    static var previews: some View {
        let response = Response.default.data
        let data = WidgetData(trip: response.trip.tripPatterns[0], from: response.trip.fromPlace.name, to: response.trip.toPlace.name)
        
        Group {
            
            // Small
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .standard))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .expired))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .noTrips))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .noData))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .error))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Medium
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .standard))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .expired))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .noTrips))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .noData))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data, type: .error))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

