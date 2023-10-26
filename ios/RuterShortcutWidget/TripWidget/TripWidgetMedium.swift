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
    var entry: Provider.Entry
    
    var body: some View {
        switch entry.type {
        case .standard:
            MediumStandard(data: entry.widgetData)
        case .expired:
            MediumExpired(message: "Tap to refresh!", data: entry.widgetData)
        case .noTrips:
            MediumExpired(message: "No departures found", data: entry.widgetData)
        case .noData:
            EmptyView(message: "Tap to get started!")
        case .error:
            EmptyView(message: "Something went wrong")
        default:
            EmptyView(message: "Something went wrong")
        }
    }
}


private struct MediumStandard : View {
    var data: WidgetData
    
    var body: some View {
        let legs = data.trip!.legs
        
        ZStack() {
            ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
            
            VStack() {
                Spacer()
                HStack() {
                    VStack(alignment: HorizontalAlignment.trailing, spacing: 0) {
                        Text(isoDateTohhmm(isoDate: legs[0].expectedStartTime)).font(.largeTitle).bold().frame(height: 40)
                        Text("In \(ISO8601DateFormatter().date(from: legs[0].expectedStartTime)!, style: .timer)").bold().opacity(0.7).multilineTextAlignment(.trailing).frame(width: 60).padding(.top, -3)
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
                        Text(data.to).bold().font(.subheadline).frame(height: 40)
                    }
                }
                
                Spacer()
                HStack(spacing: 2) {
                    ForEach(legs.indices.prefix(10), id: \.self) { index in
                        if (index == 9) {
                            OverflowCard(count: legs.count - index)
                        } else {
                            TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                        }
                    }
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 5))
            
        }
        .foregroundColor(.white)
        .font(.system(size: 12))
    }
}

private struct MediumExpired : View {
    var message: String
    var data: WidgetData
    
    var body: some View {
        ZStack() {
            ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
            
            
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
            }
            .frame(height: 50)
            .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 5))
            
        }
        .foregroundColor(.white)
        .font(.system(size: 12))
    }
}
