//
//  TripWidgetSmall.swift
//  TripWidget
//
//  Created by Ludvig Marcel Carlsen on 25/05/2023.
//

import Foundation
import WidgetKit
import SwiftUI


struct TripWidgetSmall : View {
    var entry: TripWidgetProvider.Entry
    
    var body: some View {
        switch entry.type {
        case .standard:
            SmallStandard(data: entry.widgetData)
        case .expired:
            SmallExpired(message: "Tap to refresh!", data: entry.widgetData)
        case .noTrips:
            SmallExpired(message: "No departures found", data: entry.widgetData)
        case .noData:
            EmptyView(message: "Tap to get started!")
        case .error:
            SmallExpired(message: entry.message!, data: entry.widgetData)
        }
    }
}

private struct SmallExpired : View {
    let message: String
    var data: TripWidgetData
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack() {
                VStack(spacing: 0) {
                    Image("dot").resizable().scaledToFit().frame(width: 8)
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1)
                    Image("pin").resizable().scaledToFit().frame(width: 8)
                }
                VStack( alignment: HorizontalAlignment.leading) {
                    Text(data.from).bold()
                    Spacer()
                    Text(data.to).opacity(0.7)
                }
            }
            .frame(height: 30)

            Spacer()
            Text(message)
            Spacer()
           
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}

private struct SmallStandard : View {
    var data: TripWidgetData
    
    var body: some View {
        let legs = data.trip!.legs
        let prefix = 3
        
        VStack(alignment: .center, spacing: 0) {
            HStack() {
                VStack(spacing: 0) {
                    Image("dot").resizable().scaledToFit().frame(width: 8)
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1)
                    Image("pin").resizable().scaledToFit().frame(width: 8)
                }
                VStack( alignment: HorizontalAlignment.leading) {
                    Text(legs[0].fromPlace.name).bold()
                    Spacer()
                    Text(data.to).opacity(0.7)
                }
            }
            .frame(height: 30)
            
            Spacer()
            Text(isoDateTohhmm(isoDate: legs[0].expectedStartTime)).font(.largeTitle).bold().padding(.bottom, -2)
            TimerText(startTime: legs[0].expectedStartTime, width: 60, opacity: 0.7, alignment: .center)
        
            Spacer()
           
            HStack(spacing: 2) {
                let firstLeg = legs[0]
                if (legs.count == 1) {
                    TransportModeCard(mode: firstLeg.mode, publicCode: firstLeg.line?.publicCode, destinationDisplay: firstLeg.fromEstimatedCall!.destinationDisplay.frontText)
                }
                
                else {
                    ForEach(legs.indices.prefix(prefix), id: \.self) { index in
                        TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                    }
                    if (prefix == legs.count - 1) {
                        let leg = legs[prefix]
                        TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                    } else if (prefix < legs.count) {
                        OverflowCard(count: legs.count - prefix)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(15)
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}
