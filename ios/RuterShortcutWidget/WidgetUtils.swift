import WidgetKit
import SwiftUI


struct OverflowCard : View {
    var count: Int
    
    var body: some View {
        Text("+\(count)")
            .padding(5)
            .background(Color(red: 68/255, green: 79/255, blue: 100/255))
            .cornerRadius(5)
            .foregroundColor(Color(red: 81/255, green: 154/255, blue: 255/255))
            .font(.system(size: 8, weight: .bold))
    }
}

struct EmptyView : View {
    let message: String
    
    var body: some View {
        VStack() {
            Spacer()
            Text(message)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets.init(top: 15, leading: 5, bottom: 15, trailing: 5))
        .foregroundColor(.white)
        .font(.system(size: 12))
        .widgetBackground(Color.widgetBackground)
    }
}

struct TransportModeCard : View {
    var mode: TransportMode
    var publicCode: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 1.5) {
            
            Image(mode.rawValue).resizable().scaledToFit().frame(width: 13)
            publicCode.map { Text($0).font(.system(size: 12, weight: .bold)).padding(0).lineLimit(1) }
        }
        .padding(3)
        .background(TransportMode.transportModeColors[mode])
        .cornerRadius(5)
    }
}

struct TimerText : View {
    let startTime: String
    let width: CGFloat?
    let opacity: CGFloat
    let alignment: TextAlignment
    
    var body: some View {
        if (UIDevice.current.systemVersion == "16.0") {
            Text("")
        } else {
            Text("\(ISO8601DateFormatter().date(from: startTime)!, style: .timer)")
                .bold()
                .multilineTextAlignment(alignment)
                .padding(.top, -3).frame(width: width)
                .opacity(opacity)
        }
    }
}


func minutesFromNow(iso8601Date: String) -> Int {
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from: iso8601Date) else {
        return 0 // TODO return nil?
    }
    return Int(date.timeIntervalSinceNow / 60)
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

func removeFirstFootLeg(legs: inout [Leg]) {
    if let firstLeg = legs.first, firstLeg.mode == TransportMode.foot {
        legs.removeFirst()
    }
}

func removeFirstFootLegFromPatterns(patterns: inout [TripPattern]) {
    for i in patterns.indices {
        removeFirstFootLeg(legs: &patterns[i].legs)
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

extension View {
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            //return background(color)
            return containerBackground(color, for: .widget)
        } else {
            return background(color)
        }
    }
}

extension Color {
    static let widgetBackground = Color(red: 33/255, green: 32/255, blue: 37/255)
}



