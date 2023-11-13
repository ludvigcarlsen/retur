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
            TripBoardMediumExpired(message: "Tap to refresh!", data: entry.widgetData)
        case .noTrips:
            TripBoardMediumExpired(message: "No departures found", data: entry.widgetData)
        case .error:
            TripBoardMediumExpired(message: "Failed to get departures", data: entry.widgetData)
        case .noData:
            EmptyView(message: "Tap to get started!")
        default:
            EmptyView(message: "Something went wrong :(")
        }
    }
}


private struct TripBoardMediumStandard : View {
    var data: TripBoardWidgetData
    
    
    var body: some View {
        
        let trips = data.trips
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
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
                
                VStack(alignment: .leading) {
                    let firstLegs = trips[0].legs
                    let prefix = firstLegs[0].mode == .foot ? 2 : 1
                    
                    HStack(spacing: 2) {
                        ForEach(firstLegs.indices.prefix(prefix), id: \.self) { index in
                            let leg = firstLegs[index]
                            TransportModeCard(mode: leg.mode, publicCode: leg.line?.publicCode)
                        }
                        
                        if (firstLegs[prefix-1].fromEstimatedCall != nil) {
                            Text(" \(firstLegs[prefix-1].fromEstimatedCall!.destinationDisplay.frontText)")
                        }
                        
                        if (prefix < firstLegs.count) {
                            Text(" +\(firstLegs.count - prefix)").opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/).font(.system(size: 10))
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
                        let firstLeg = legs[0]
                        let prefix = firstLeg.mode == .foot ? 2 : 1
                        
                        HStack(spacing: 2) {
                            ForEach(legs.indices.prefix(prefix), id: \.self) { index in
                                TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                            }
                            
                            if (legs[prefix-1].fromEstimatedCall != nil) {
                                Text(" \(legs[prefix-1].fromEstimatedCall!.destinationDisplay.frontText)")
                            }
                            
                            if (prefix < legs.count) {
                                Text(" +\(legs.count - prefix)").opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/).font(.system(size: 10))
                            }
                            
                            Spacer()
                            
                            if let nextLegs = firstLeg.nextLegs {
                                Text("\(isoDateTohhmm(isoDate: firstLeg.expectedStartTime)),").bold()
                                Text(isoDateTohhmm(isoDate: nextLegs[0].expectedStartTime))
                                    .opacity(0.8)
    
                            } else {
                                Text(isoDateTohhmm(isoDate: firstLeg.expectedStartTime)).opacity(0.8)
                            }
                        }
                    }
                    Spacer()
                 
                    Text("Updated \(data.lastUpdated.toHHMM())").opacity(0.7)
                }
            }
        }
        
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
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
            HStack() {
                VStack(alignment: HorizontalAlignment.trailing, spacing: 0) {
                    Text(message)
                }
                VStack(spacing: 0) {
                    Image("dot").resizable().scaledToFit().frame(width: 8)
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1)
                    Image("pin").resizable().scaledToFit().frame(width: 8)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
                
                VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                    Text(data.from).font(.subheadline).bold().frame(height: 20)
                    Spacer()
                    Text(data.to).bold().font(.subheadline).frame(height: 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 5))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}

