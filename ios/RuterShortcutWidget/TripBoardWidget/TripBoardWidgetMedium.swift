//
//  TripWidgetMedium.swift
//  TripWidget
//
//  Created by Ludvig Marcel Carlsen on 25/05/2023.
//

import Foundation
import WidgetKit
import SwiftUI

struct TripBoardWidgetMedium : View {
    var entry: TripBoardWidgetProvider.Entry
    
    var body: some View {
        switch entry.type {
        case .standard:
            TripBoardMediumStandard(data: entry.widgetData)
        case .expired:
            TripBoardMediumExpired(message: "Tap to refresh", data: entry.widgetData)
        case .noTrips:
            TripBoardMediumExpired(message: "No departures found", data: entry.widgetData)
        case .noData:
            EmptyView(message: "Tap to get started!")
        case .error:
            TripBoardMediumExpired(message: entry.message!, data: entry.widgetData)
        }
    }
}


private struct TripBoardMediumStandard : View {
    var data: TripBoardWidgetData
    
    
    var body: some View {
        
        let trips = data.trips
        let prefix = 2
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                swapWrapperView() {
                    HStack(spacing: 0) {
                        Text(data.from.description).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).lineLimit(1).fixedSize().padding(.trailing, 10).font(.system(size: 13))
                        Image("dot").resizable().scaledToFit().frame(width: 8)
                        
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 1)
                                .padding(0)
                        }
                          
                        Image("pin").resizable().scaledToFit().frame(width: 8)
                        Text(data.to.description).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).lineLimit(1).fixedSize().padding(.leading, 10).font(.system(size: 13))
                    }
                    .padding(.bottom, 10)
                }
                .invalidateIfAvailable()
                
                VStack(alignment: .center) {
                    let firstLegs = trips[0].legs
                    
                    HStack(spacing: 2) {
                        ForEach(firstLegs.indices.prefix(2), id: \.self) { index in
                            let leg = firstLegs[index]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode, destinationDisplay: leg.fromEstimatedCall?.destinationDisplay.frontText)
                        }
                        ForEach(firstLegs.indices.dropFirst(2).prefix(prefix-2), id: \.self) { index in
                            let leg = firstLegs[index]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                        }
                        
                        if (prefix == firstLegs.count - 1) {
                            let leg = firstLegs[prefix]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                        }
                        
                        else if (prefix < firstLegs.count) {
                            OverflowCard(count: firstLegs.count - prefix)
                        }
                        
                        Spacer()
                        
                        refreshWrapperView() {
                            
                            // Timers are bugged for ios 16.0, use hhmm instead
                            if (UIDevice.current.systemVersion == "16.0") {
                                Text(isoDateTohhmm(isoDate: firstLegs[0].expectedStartTime)).bold()
                            } else {
                                // Timers are also not clickable for some reason, temporary workaround
                                ZStack() {
                                    TimerText(startTime: firstLegs[0].expectedStartTime, width: 47, opacity: 1, alignment: .trailing)
                                    Color.clear.frame(width: 47, height: 18)
                                }
                            }
                        }
                    }
                    .id(data.id)
                    .transitionifAvailable()
                    
                    ForEach(trips.indices.dropFirst().prefix(2), id: \.self) { i in
                        let trip = trips[i]
                        let legs = trip.legs
                        let firstLeg = legs[0]
                        
                        HStack(spacing: 2) {
                            ForEach(legs.indices.prefix(2), id: \.self) { index in
                                let leg = legs[index]
                                TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode, destinationDisplay: leg.fromEstimatedCall?.destinationDisplay.frontText)
                            }
                            ForEach(legs.indices.dropFirst(2).prefix(prefix-2), id: \.self) { index in
                                let leg = legs[index]
                                TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                            }
                            
                            if (prefix == legs.count - 1) {
                                let leg = legs[prefix]
                                TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                            }
                            
                            else if (prefix < legs.count) {
                                OverflowCard(count: legs.count - prefix)
                            }
                            
                            Spacer()
                            
                            if let nextLegs = firstLeg.nextLegs {
                                Text("\(isoDateTohhmm(isoDate: firstLeg.expectedStartTime)),").bold().fixedSize()
                                Text(isoDateTohhmm(isoDate: nextLegs[0].expectedStartTime)).fixedSize()
                                    .opacity(0.8)
    
                            } else {
                                Text(isoDateTohhmm(isoDate: firstLeg.expectedStartTime)).opacity(0.8).fixedSize()
                            }
                        }
                        .id(data.id)
                        .transitionifAvailable()
                    }
                    
                    Spacer()
                    
                    if (trips.count < 3) {
                        refreshButton() {
                            Text("Updated \(data.lastUpdated.toHHMM())").font(.system(size: 10))
                        }
                    } else {
                        Text("Updated \(data.lastUpdated.toHHMM())").font(.system(size: 10)).opacity(0.7)
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

private struct TripBoardMediumExpired : View {
    var message: String
    var data: TripBoardWidgetData
    
    var body: some View {
        VStack(alignment: .leading) {
            
            VStack() {
                swapWrapperView() {
                    HStack(spacing: 0) {
                        Text(data.from.description).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).lineLimit(1).fixedSize().padding(.trailing, 10).font(.system(size: 13))
                        Image("dot").resizable().scaledToFit().frame(width: 8)
                        
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 1)
                                .padding(0)
                        }
                          
                        Image("pin").resizable().scaledToFit().frame(width: 8)
                        Text(data.to.description).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).lineLimit(1).fixedSize().padding(.leading, 10).font(.system(size: 13))
                    }
                    .padding(.bottom, 10)
                }
                .invalidateIfAvailable()
                Spacer()
                refreshButton() {
                    Text(message)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}

@available(iOS 17.0, *)
#Preview(as: WidgetFamily.systemMedium) {
    TripBoardWidget()
} timeline: {
    TripBoardWidgetEntry.previewEntry1
    TripBoardWidgetEntry.previewEntry2
    TripBoardWidgetEntry.previewEntryExpired
    TripBoardWidgetEntry.previewEntryNoData
}

