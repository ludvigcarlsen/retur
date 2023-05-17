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
            TripWidgetEntryView(entry: TripWidgetEntry(date: Date(), widgetData: data))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                
        }
    }
}

