//
//  ios_widget_flutter.swift
//  ios widget flutter
//
//  Created by Ludvig Marcel Carlsen on 09/05/2023.
//

import WidgetKit
import SwiftUI
import Intents
import Dispatch

struct WidgetEntry : TimelineEntry {
    let date: Date
    let widgetData: WidgetData
}




struct Provider: TimelineProvider {
    /*
     When WidgetKit displays your widget for the first time, it renders the widget’s view as a placeholder. A placeholder view displays a generic representation of your widget, giving the user a general idea of what the widget shows.
     */
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), widgetData: Response.default.data)
    }
    
    /*func getSnapshot This function should return an entry with dummy data. It is used to render the previews in the widget gallery.*/
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(), widgetData: Response.default.data)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
        let flutterData: FlutterData? = try? JSONDecoder().decode(FlutterData.self, from: (sharedDefaults?
            .string(forKey: "widgetData")?.data(using: .utf8)) ?? Data())
        
        if (flutterData == nil) {
            // TODO no trip has been added yet
        }
        
        // TODO check cache
        
        
        // fetch trips
        print("get trips")
        NetworkManager.getTrip(data: flutterData!) { result in
            switch(result) {
            case .success(let response):
                var entries: [WidgetEntry] = []
                var currentDate = Date()
                
                for trip in response.data.trip.tripPatterns {
                    entries.append(WidgetEntry(date: currentDate, widgetData: response.data))
                    // TODO what should happen if this fails
                    currentDate = ISO8601DateFormatter().date(from: trip.legs[0].expectedStartTime)!
                    //currentDate = Date().addingTimeInterval(60)
                }
                
                //let entry = WidgetEntry(date: nextUpdate, widgetData: response.data)
                let nextUpdate = ISO8601DateFormatter().date(from: entries[0].widgetData.trip.tripPatterns[0].expectedStartTime)!
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
                
            // TODO return different layout on error such as centered "Something went wrong"
            case .failure(let error):
                let entry = WidgetEntry(date: Date().addingTimeInterval(60), widgetData: Response.default.data)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct ios_widget_flutter: Widget {
    let kind: String = "ios_widget_flutter"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ReturWidget(entry: entry)
        }
        .supportedFamilies([.systemSmall])
    }
}

struct ReturWidget : View {
    let entry: WidgetEntry
    let trip: Trip
    let legs: [Leg]
    
    init(entry: WidgetEntry) {
        self.entry = entry
        self.trip = entry.widgetData.trip
        self.legs = getLegsExcludeFoot(legs: trip.tripPatterns[0].legs)
    }
    
    var body: some View {
        ZStack() {
            ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
            
            VStack() {
                Text(entry.widgetData.trip.toPlace.name).bold()
                Spacer()
                Text(isoDateTohhmm(isoDate: legs[0].expectedStartTime)).font(.largeTitle).bold()
                Spacer()
                HStack(spacing: 2) {
                    ForEach(legs.indices.prefix(4), id: \.self) { index in
                        if (index == 3) {
                            OverflowCard(remaining: legs.count - index)
                        } else {
                            TransportModeCard(mode: legs[index].mode, publicCode: legs[index].line?.publicCode)
                        }
                    }
                }
            
                Text("From \(entry.widgetData.trip.fromPlace.name)").opacity(0.5)
                
            }
            .padding(EdgeInsets.init(top: 10, leading: 2, bottom: 10, trailing: 2))
        }
        .foregroundColor(.white)
        .font(.system(size: 12))
        
        /*
         ZStack() {
             ContainerRelativeShape().fill(Color(red: 33/255, green: 32/255, blue: 37/255))
             HStack() {
                 VStack(alignment: HorizontalAlignment.leading) {
                     Text(data.to).font(.caption)
                     Text(isoDateTohhmm(isoDate: data.endTime)).font(.largeTitle).bold()

                     Spacer()
                     Text("In " + (minutesFromNow(to: data.startTime)) + " min")
                     Text(data.from).font(.caption).opacity(0.7)
                 }
                 Spacer()
             }
             .padding()
         }
         
         .foregroundColor(.white)
         */
    }
}

struct OverflowCard : View {
    var remaining: Int
    
    var body: some View {
        Text("+\(remaining)")
            .padding(3)
            .background(Color(red: 68/255, green: 79/255, blue: 100/255))
            .cornerRadius(5)
            .foregroundColor(Color(red: 104/255, green: 130/255, blue: 184/255))
            .font(.system(size: 12, weight: .bold)).padding(0)
    }
}

struct TransportModeCard : View {
    var mode: TransportMode
    var publicCode: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 1.5) {
            
            Image(mode.rawValue).resizable().scaledToFit().frame(width: 13)
            publicCode.map { Text($0).font(.system(size: 12, weight: .bold)).padding(0) }
        }
        .padding(3)
        .background(TransportMode.transportModeColors[mode])
        .cornerRadius(5)
    }
}

struct Previews_ios_widget_flutter_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}



func minutesFromNow(iso8601Date: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from: iso8601Date) else {
        return "Invalid Date"
    }
    let minutesFromNow = Int(date.timeIntervalSinceNow / 60)
    return String(minutesFromNow)
}


func isoDateTohhmm(isoDate: String) -> String {
    let date = ISO8601DateFormatter().date(from: isoDate)!
    return date.toHHMM()
}

extension Date {
    func toHHMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
}

func getLegsExcludeFoot(legs: [Leg]) -> [Leg] {
    return legs.filter { $0.mode != TransportMode.foot }
}
