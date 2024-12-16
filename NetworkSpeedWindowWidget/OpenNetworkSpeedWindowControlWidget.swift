import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct OpenNetworkSpeedWindowIntent: AppIntent {
    static var title: LocalizedStringResource = "open_network_speed_window"
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let url = URL(string: "nswindow://pip")!
        // HACK: custom URL schemes are not supported yet in OpenURLIntent. See https://stackoverflow.com/a/78757134.
        EnvironmentValues().openURL(url)
        return .result(opensIntent: OpenURLIntent(url))
    }
}

@available(iOS 18.0, *)
struct OpenNetworkSpeedWindowControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "name.sketch.NetworkSpeedWindow.OpenNetworkSpeedWindowControlWidget"
        ) {
            ControlWidgetButton(action: OpenNetworkSpeedWindowIntent()) {
                Image("network.badge.gauge.with.needle.fill")
            }
        }
        .displayName("open_network_speed_window")
        .description("open_network_speed_window_description")
    }
}
