//
//  ios_widget_flutterBundle.swift
//  ios widget flutter
//
//  Created by Ludvig Marcel Carlsen on 09/05/2023.
//

import WidgetKit
import SwiftUI

@main
struct ios_widget_flutterBundle: WidgetBundle {
    var body: some Widget {
        ios_widget_flutter()
    }
}


struct ios_widget_flutter_Previews: PreviewProvider {
    static var previews: some View {
        ReturWidget(entry: Provider.Entry(date: Date(), widgetData: Response.default.data))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct Previews_ios_widget_flutterBundle_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
