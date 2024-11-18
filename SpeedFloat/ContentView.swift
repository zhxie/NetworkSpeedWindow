import Pipify
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let monitor = NetworkSpeedMonitor()
    
    @State var downloadSpeed: String = "0 B/s"
    @State var uploadSpeed: String = "0 B/s"
    @State var totalBytesReceived: String = "0 B"
    @State var totalBytesSent: String = "0 B"
    @State var isStarted = false
    
    @State var colorSchemeBinding: ColorScheme = .light
    @State var isPresented = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Network") {
                    HStack {
                        Text("Download Speed")
                        Spacer()
                        Text(downloadSpeed)
                    }
                    HStack {
                        Text("Upload Speed")
                        Spacer()
                        Text(uploadSpeed)
                    }
                    HStack {
                        Text("Total Bytes Received")
                        Spacer()
                        Text(totalBytesReceived)
                    }
                    HStack {
                        Text("Total Bytes Sent")
                        Spacer()
                        Text(totalBytesSent)
                    }
                }
                
                Section {
                    Button(isPresented ? "Close Picture-in-Picture" : "Open Picture-in-Picture") {
                        isPresented.toggle()
                    }
                    .onChange(of: colorScheme) {
                            colorSchemeBinding = colorScheme
                    }
                    .pipify(isPresented: $isPresented) {
                        MonitorView(colorScheme: $colorSchemeBinding, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, totalBytesReceived: $totalBytesReceived, totalBytesSent: $totalBytesSent)
                            .frame(width: UIScreen.main.bounds.size.width, height: 30)
                            .pipControlsStyle(controlsStyle: 1)
                    }
                }
            }
            .navigationTitle("SpeedFloat")
            .onAppear {
                if !isStarted {
                    monitor.startMonitoring { [self] downloadSpeed, uploadSpeed, totalBytesReceived, totalBytesSent in
                        self.downloadSpeed = String(format: "%@/s", formatData(downloadSpeed))
                        self.uploadSpeed = String(format: "%@/s", formatData(uploadSpeed))
                        self.totalBytesReceived = formatData(Double(totalBytesReceived))
                        self.totalBytesSent = formatData(Double(totalBytesSent))
                    }
                    isStarted = true
                }
            }
        }
    }
    
    func formatData(_ data: Double) -> String {
        if (data >= 1024 * 1024 * 1024 * 1024) {
            // TB.
            return String(format: "%.1f TB", data / 1024 / 1024 / 1024 / 1024)
        }
        if (data >= 1024 * 1024 * 1024) {
            // GB.
            return String(format: "%.1f GB", data / 1024 / 1024 / 1024)
        }
        if (data >= 1024 * 1024) {
            // MB.
            return String(format: "%.1f MB", data / 1024 / 1024)
        }
        if (data >= 1024) {
            // kB.
            return String(format: "%.1f kB", data / 1024)
        }
        return String(format: "%d B", data)
    }
}

#Preview {
    ContentView()
}
