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
        case .noData:
            EmptyView(message: "Tap to get started!")
        case .error:
            TripBoardSmallExpired(message: entry.message!, data: entry.widgetData)
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
            
            VStack(alignment: .center) {
                let firstLegs = trips[0].legs
                let prefix = 2
                HStack(spacing: 2) {
                    
                    if (firstLegs.count == 1) {
                        let leg = firstLegs[0]
                        TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode, destinationDisplay: leg.fromEstimatedCall?.destinationDisplay.frontText)
                    } else {
                        ForEach(firstLegs.indices.prefix(prefix), id: \.self) { index in
                            let leg = firstLegs[index]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                        }
                        if (prefix == firstLegs.count - 1) {
                            let leg = firstLegs[prefix]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode, destinationDisplay: leg.fromEstimatedCall?.destinationDisplay.frontText)
                        } else if (prefix < firstLegs.count) {
                            OverflowCard(count: firstLegs.count - prefix)
                        }
                    }
                    
                    Spacer()
                    
                    // Timers are bugged for ios 16.0, use hhmm instead
                    if (UIDevice.current.systemVersion == "16.0") {
                        Text(isoDateTohhmm(isoDate: firstLegs[0].expectedStartTime)).bold()
                    } else {
                        TimerText(startTime: firstLegs[0].expectedStartTime, width: 47, opacity: 1, alignment: .trailing)
                    }
                }
                
                ForEach(trips.indices.dropFirst().prefix(prefix), id: \.self) { i in
                    let trip = trips[i]
                    let legs = trip.legs
                    
                    HStack(spacing: 2) {
                        if (legs.count == 1) {
                            let leg = legs[0]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode, destinationDisplay: leg.fromEstimatedCall?.destinationDisplay.frontText)
                        } else {
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
                    
                        Spacer()
                        
                        Text(isoDateTohhmm(isoDate: legs[0].expectedStartTime)).opacity(0.7)
                    }
                }
                
                Spacer()
                
                if (trips.count < 3) {
                    Text("Updated \(data.lastUpdated.toHHMM())").font(.system(size: 10)).opacity(0.7)
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

