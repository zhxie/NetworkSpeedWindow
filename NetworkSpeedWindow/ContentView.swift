import Pipify
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let monitor = NetworkSpeedMonitor()
    
    @State var downloadSpeed: String = "0 B/s"
    @State var uploadSpeed: String = "0 B/s"
    @State var totalReceived: String = "0 B"
    @State var totalSent: String = "0 B"
    @State var isStarted = false
    
    @State var colorSchemeBinding: ColorScheme = .light
    @State var isPresented = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(LocalizedStringKey("network")) {
                    HStack {
                        Text(LocalizedStringKey("download_speed"))
                        Spacer()
                        Text(downloadSpeed)
                    }
                    HStack {
                        Text(LocalizedStringKey("upload_speed"))
                        Spacer()
                        Text(uploadSpeed)
                    }
                    HStack {
                        Text(LocalizedStringKey("total_received"))
                        Spacer()
                        Text(totalReceived)
                    }
                    HStack {
                        Text(LocalizedStringKey("total_sent"))
                        Spacer()
                        Text(totalSent)
                    }
                }
                
                Section {
                    Button(LocalizedStringKey(isPresented ? "close_picture_in_picture" : "open_picture_in_picture")) {
                        isPresented.toggle()
                    }
                    .pipify(isPresented: $isPresented) {
                        MonitorView(colorScheme: $colorSchemeBinding, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, totalReceived: $totalReceived, totalSent: $totalSent)
                            .frame(width: UIScreen.main.bounds.size.width, height: 30)
                            .pipControlsStyle(controlsStyle: 2)
                    }
                    .onAppear {
                        colorSchemeBinding = colorScheme
                    }
                    .onChange(of: colorScheme) {
                        colorSchemeBinding = colorScheme
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("network_speed_window"))
            .onAppear {
                if !isStarted {
                    monitor.startMonitoring { [self] downloadSpeed, uploadSpeed, totalBytesReceived, totalBytesSent in
                        self.downloadSpeed = String(format: "%@/s", formatData(downloadSpeed))
                        self.uploadSpeed = String(format: "%@/s", formatData(uploadSpeed))
                        self.totalReceived = formatData(Double(totalBytesReceived))
                        self.totalSent = formatData(Double(totalBytesSent))
                    }
                    isStarted = true
                }
            }
        }
    }
    
    func formatData(_ data: Double) -> String {
        if data >= 1024 * 1024 * 1024 * 1024 {
            // TB.
            let tb = data / 1024 / 1024 / 1024 / 1024
            return String(format: "%.1f TB", tb)
        }
        if data >= 1024 * 1024 * 1024 {
            // GB.
            let gb = data / 1024 / 1024 / 1024
            return String(format: "%.1f GB", gb)
        }
        if data >= 1024 * 1024 {
            // MB.
            let mb = data / 1024 / 1024
            return String(format: "%.1f MB", mb)
        }
        if data >= 1024 {
            // kB.
            let kb = data / 1024
            return String(format: "%d kB", Int(kb))
        }
        return String(format: "%d B", Int(data))
    }
}

#Preview {
    ContentView()
}
