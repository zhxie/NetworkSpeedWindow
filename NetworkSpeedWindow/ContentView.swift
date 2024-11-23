import Pipify
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let monitor = NetworkSpeedMonitor()
    
    @State var downloadSpeed: String = "0 B/s"
    @State var uploadSpeed: String = "0 B/s"
    @State var totalReceived: String = "0 B"
    @State var totalSent: String = "0 B"
    @State var ethernet: String = "0 B"
    @State var cellular: String = "0 B"
    @State var isStarted = false
    
    @State var colorSchemeBinding: ColorScheme = .light
    @State var isPiPPresented = false
    
    @State var isInfoPresented = false
    
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
                
                Section(LocalizedStringKey("interface")) {
                    HStack {
                        Text(LocalizedStringKey("wi_fi_ethernet"))
                        Spacer()
                        Text(ethernet)
                    }
                    HStack {
                        Text(LocalizedStringKey("cellular"))
                        Spacer()
                        Text(cellular)
                    }
                }
                
                Section {
                    Button(LocalizedStringKey(isPiPPresented ? "close_picture_in_picture" : "open_picture_in_picture")) {
                        isPiPPresented.toggle()
                    }
                    .pipify(isPresented: $isPiPPresented) {
                        MonitorView(colorScheme: $colorSchemeBinding, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, totalReceived: $totalReceived, totalSent: $totalSent)
                            .frame(width: UIScreen.main.bounds.size.width, height: 30)
                            .pipControlsStyle(controlsStyle: 2)
                    }
                    Button(LocalizedStringKey("reset")) {
                        monitor.reset()
                        downloadSpeed = String(format: "%@/s", formatData(0))
                        uploadSpeed = String(format: "%@/s", formatData(0))
                        totalReceived = formatData(0)
                        totalSent = formatData(0)
                        ethernet = formatData(0)
                        cellular = formatData(0)
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("network_speed_window"))
            .toolbar {
                Button {
                    isInfoPresented.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
            }
            .onAppear {
                colorSchemeBinding = colorScheme
                if !isStarted {
                    monitor.startMonitoring { [self] downloadSpeed, uploadSpeed, totalReceived, totalSent, ethernet, cellular in
                        self.downloadSpeed = String(format: "%@/s", formatData(downloadSpeed))
                        self.uploadSpeed = String(format: "%@/s", formatData(uploadSpeed))
                        self.totalReceived = formatData(Double(totalReceived))
                        self.totalSent = formatData(Double(totalSent))
                        self.ethernet = formatData(Double(ethernet))
                        self.cellular = formatData(Double(cellular))
                    }
                    isStarted = true
                }
            }
            .onChange(of: colorScheme) { colorScheme in
                colorSchemeBinding = colorScheme
            }
            .sheet(isPresented: $isInfoPresented) {
                AboutView()
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
