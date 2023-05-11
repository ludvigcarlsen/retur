//
//  ios_widget_flutter.swift
//  ios widget flutter
//
//  Created by Ludvig Marcel Carlsen on 09/05/2023.
//

import WidgetKit
import SwiftUI
import Intents

struct FlutterEntry : TimelineEntry {
    let date: Date
    let widgetData: Data
}

struct Provider: TimelineProvider {
    /*
     When WidgetKit displays your widget for the first time, it renders the widget’s view as a placeholder. A placeholder view displays a generic representation of your widget, giving the user a general idea of what the widget shows.
     */
    func placeholder(in context: Context) -> FlutterEntry {
        FlutterEntry(date: Date(), widgetData: Response.default.data)
    }
    
    /*func getSnapshot This function should return an entry with dummy data. It is used to render the previews in the widget gallery.*/
    func getSnapshot(in context: Context, completion: @escaping (FlutterEntry) -> ()) {
        let entry = FlutterEntry(date: Date(), widgetData: Response.default.data)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlutterEntry>) -> ()) {
        let nextUpdate = Date()
        
        NetworkManager.getTrip { result in
            switch(result) {
            case .success(let response):
                let entry = FlutterEntry(date: nextUpdate, widgetData: response.data)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
                
            // TODO return different layout on error such as centered "Something went wrong"
            case .failure(let error):
                let entry = FlutterEntry(date: nextUpdate, widgetData: Response.default.data)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}


/* let sharedDefaults = UserDefaults.init(suiteName: "group.returwidget")
 let flutterData = try? JSONDecoder().decode(WidgetData.self, from: (sharedDefaults?
     .string(forKey: "widgetData")?.data(using: .utf8)) ?? Data())
 
 let entryDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
 let entry = FlutterEntry(date: entryDate, widgetData: flutterData)
 let timeline = Timeline(entries: [entry], policy: .atEnd)
 completion(timeline)
 */

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
    let entry: FlutterEntry
    
    // TODO handle data is nil (or subfields)
    var body: some View {
        Text(entry.widgetData.trip.toPlace.name)
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

struct LocationRow : View {
    var date: String
    var locationName: String
    
    var body: some View {
        HStack() {
            Text(isoDateTohhmm(isoDate: date)).bold().frame(width: 50, alignment: .leading)
            Text(locationName)
        }
        
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
