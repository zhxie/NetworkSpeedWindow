import WidgetKit
import SwiftUI

@main
struct NetworkSpeedWindowWidgetBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 18.0, *) {
            OpenNetworkSpeedWindowControlWidget()
        }
    }
}
