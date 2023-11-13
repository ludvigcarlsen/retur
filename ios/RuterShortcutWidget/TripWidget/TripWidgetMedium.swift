//
//  TripWidgetMedium.swift
//  TripWidget
//
//  Created by Ludvig Marcel Carlsen on 25/05/2023.
//

import Foundation
import WidgetKit
import SwiftUI

struct TripWidgetMedium : View {
    var entry: TripWidgetProvider.Entry
    
    var body: some View {
        switch entry.type {
        case .standard:
            MediumStandard(data: entry.widgetData)
        case .expired:
            MediumExpired(message: "Tap to refresh!", data: entry.widgetData)
        case .noTrips:
            MediumExpired(message: "No departures found", data: entry.widgetData)
        case .error:
            MediumExpired(message: "Failed to get departures", data: entry.widgetData)
        case .noData:
            EmptyView(message: "Tap to get started!")
        default:
            EmptyView(message: "Something went wrong :(")
        }
    }
}


private struct MediumStandard : View {
    var data: TripWidgetData
    
    
    var body: some View {
        let trip = data.trip!
        let legs = trip.legs
        
        VStack() {
            Spacer()
            HStack() {
                VStack(alignment: HorizontalAlignment.trailing, spacing: 0) {
                    Text(isoDateTohhmm(isoDate: legs[0].expectedStartTime)).font(.largeTitle).bold().frame(height: 40)
                    TimerText(startTime: legs[0].expectedStartTime, width: 60, opacity: 0.7, alignment: .trailing)
                
                    Spacer()
                    Text(isoDateTohhmm(isoDate: data.trip!.expectedEndTime)).font(.subheadline).bold().frame(height: 40)
                }
                VStack(spacing: 0) {
                    Spacer()
                    Image("dot").resizable().scaledToFit().frame(width: 8)
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1)
                    Image("pin").resizable().scaledToFit().frame(width: 8)
                    Spacer()
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 10)
                
                VStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                    Text(legs[0].fromPlace.name).font(.subheadline).bold().frame(height: 40)
                    Spacer()
                    Text(data.to).font(.subheadline).bold().frame(height: 40)
                }
            }
            .padding(.bottom, 10)
            
            
            Spacer()
            HStack(spacing: 2) {
                if (legs.count == 1 && legs[0].fromEstimatedCall != nil) {
                    TransportModeCard(mode: legs[0].mode, publicCode: legs[0].line?.publicCode)
                    Text(legs[0].fromEstimatedCall!.destinationDisplay.frontText).lineLimit(1).padding(.leading, 2)
                    
                }
                
                else {
                    ForEach(legs.indices.prefix(8), id: \.self) { index in
                        if (index == 7) {
                            OverflowCard(count: legs.count - index)
                        } else {
                            TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                        }
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 10, leading: 5, bottom: 15, trailing: 5))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
      
}

private struct MediumExpired : View {
    var message: String
    var data: TripWidgetData
    
    var body: some View {
        VStack() {
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
            .frame(maxHeight: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 5))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}
