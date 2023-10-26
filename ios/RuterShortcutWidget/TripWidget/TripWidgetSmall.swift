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
    var entry: Provider.Entry
    
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
            EmptyView(message: "Something went wrong")
        default:
            EmptyView(message: "Something went wrong")
        }
    }
}

private struct SmallExpired : View {
    let message: String
    var data: WidgetData
    
    var body: some View {
        ZStack() {
            ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
            
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
            .padding(EdgeInsets.init(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .foregroundColor(.white)
        .font(.system(size: 12))
    }
}

private struct SmallStandard : View {
    var data: WidgetData
    
    var body: some View {
        let legs = data.trip!.legs
        
        ZStack() {
            ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
            
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
                Text("In \(ISO8601DateFormatter().date(from: legs[0].expectedStartTime)!, style: .timer)").bold().opacity(0.7).multilineTextAlignment(.center)
                
                Spacer()
               
                HStack(spacing: 2) {
                    ForEach(legs.indices.prefix(4), id: \.self) { index in
                        if (index == 3) {
                            OverflowCard(count: legs.count - index)
                        } else {
                            TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                        }
                    }
                }
               
                
            }
            .padding(EdgeInsets.init(top: 15, leading: 5, bottom: 15, trailing: 5))
        }
        .foregroundColor(.white)
        .font(.system(size: 12))
    }
}
