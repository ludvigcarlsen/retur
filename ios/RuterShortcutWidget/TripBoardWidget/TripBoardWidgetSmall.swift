//
//  TripWidgetSmall.swift
//  TripWidget
//
//  Created by Ludvig Marcel Carlsen on 25/05/2023.
//

import Foundation
import WidgetKit
import SwiftUI


struct TripBoardWidgetSmall : View {
    var entry: TripBoardWidgetProvider.Entry
    
    var body: some View {
        switch entry.type {
        case .standard:
            TripBoardSmallStandard(data: entry.widgetData)
        case .expired:
            TripBoardSmallExpired(message: "Tap to refresh!", data: entry.widgetData)
        case .noTrips:
            TripBoardSmallExpired(message: "No departures found", data: entry.widgetData)
        case .error:
            TripBoardSmallExpired(message: "Failed to get departures", data: entry.widgetData)
        case .noData:
            EmptyView(message: "Tap to get started!")
        
        default:
            EmptyView(message: "Something went wrong :(")
        }
    }
}

private struct TripBoardSmallExpired : View {
    let message: String
    var data: TripBoardWidgetData
    
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

private struct TripBoardSmallStandard : View {
    var data: TripBoardWidgetData
    
    var body: some View {
        let trips = data.trips
        
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
            .padding(.bottom, 10)
            
            Spacer()
            
            VStack(alignment: .leading) {
                let firstLegs = trips[0].legs
                let prefix = firstLegs[0].mode == .foot ? 2 : 1
                HStack(spacing: 2) {
                    ForEach(firstLegs.indices.prefix(prefix), id: \.self) { index in
                        let leg = firstLegs[index]
                        TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                    }
                    if (firstLegs.count == 1 && firstLegs[0].fromEstimatedCall != nil) {
                        Text(" \(firstLegs[prefix-1].fromEstimatedCall!.destinationDisplay.frontText)").lineLimit(1)
                    } else if (prefix < firstLegs.count) {
                        OverflowCard(count: firstLegs.count - prefix)
                    }
                    
                    Spacer()
                    
                    // Timers are bugged for ios 16.0, use hhmm instead
                    if (UIDevice.current.systemVersion == "16.0") {
                        Text(isoDateTohhmm(isoDate: firstLegs[0].expectedStartTime)).bold()
                    } else {
                        TimerText(startTime: firstLegs[0].expectedStartTime, width: 40, opacity: 1, alignment: .trailing)
                    }
                }
                
                ForEach(trips.indices.dropFirst().prefix(2), id: \.self) { i in
                    let trip = trips[i]
                    let legs = trip.legs
                    let prefix = legs[0].mode == .foot ? 2 : 1
                    
                    HStack(spacing: 2) {
                        ForEach(legs.indices.prefix(prefix), id: \.self) { index in
                            TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                        }
                        
                        if (legs.count == 1 && legs[0].fromEstimatedCall != nil) {
                            Text(" \(legs[prefix-1].fromEstimatedCall!.destinationDisplay.frontText)").lineLimit(1)
                        } else if (prefix < legs.count) {
                            OverflowCard(count: legs.count - prefix)
                        }
                        
                        Spacer()
                        
                        Text(isoDateTohhmm(isoDate: legs[0].expectedStartTime)).opacity(0.7)
                    }
                }
                
                Spacer()
                
                if (trips.count < 3) {
                    Text("Updated \(data.lastUpdated.toHHMM())").opacity(0.7)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 10, trailing: 15))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}

