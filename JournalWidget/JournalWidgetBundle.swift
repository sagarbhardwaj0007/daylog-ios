import WidgetKit
import SwiftUI

@main
struct DaylogWidgetBundle: WidgetBundle {
    var body: some Widget {
        DaylogSmallWidget()
        DaylogMediumWidget()
    }
}
