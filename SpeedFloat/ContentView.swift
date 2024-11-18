import Pipify
import SwiftUI

struct ContentView: View {
    let monitor = NetworkSpeedMonitor()
    
    @State var downloadSpeed: Double = 0
    @State var uploadSpeed: Double = 0
    @State var totalBytesReceived: Int = 0
    @State var totalBytesSent: Int = 0
    @State var isStarted = false
    
    @State var isPresented = false
    
    var body: some View {
        HStack {
            Grid(horizontalSpacing: 8) {
                GridRow {
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(downloadSpeedString)
                    }
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(uploadSpeedString)
                    }
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(totalBytesReceivedString)
                    }
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(totalBytesSentString)
                    }
                }
                .font(.footnote)
            }
        }
        .padding()
        .pipify(isPresented: $isPresented)
        
        Button {
            if isStarted {
                stopMonitoring()
                isStarted = false
                isPresented = false
            } else {
                startMonitoring()
                isStarted = true
                isPresented = true
            }
        } label: {
            Image(systemName: isStarted ? "stop.circle" : "play.circle")
            Text(isStarted ? "Stop" : "Start")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    var downloadSpeedString: String {
        return String(format: "%@/s", formatData(downloadSpeed))
    }
    var uploadSpeedString: String {
        return String(format: "%@/s", formatData(uploadSpeed))
    }
    var totalBytesReceivedString: String {
        return formatData(Double(totalBytesReceived))
    }
    var totalBytesSentString: String {
        return formatData(Double(totalBytesSent))
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
    
    func startMonitoring() {
        monitor.startMonitoring { [self] downloadSpeed, uploadSpeed, totalBytesReceived, totalBytesSent in
            self.downloadSpeed = downloadSpeed
            self.uploadSpeed = uploadSpeed
            self.totalBytesReceived = totalBytesReceived
            self.totalBytesSent = totalBytesSent
        }
    }
    func stopMonitoring() {
        monitor.stopMonitoring()
        
        downloadSpeed = 0
        uploadSpeed = 0
        totalBytesReceived = 0
        totalBytesSent = 0
    }
}

#Preview {
    ContentView()
}
