import Pipify
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let monitor = NetworkSpeedMonitor()
    @State var timer: Timer? = nil
    
    @State var selectedSecondaryIndicator: Indicator = .throughput
    
    @State var downloadSpeed: Double = 0
    @State var uploadSpeed: Double = 0
    @State var totalReceived: UInt64 = 0
    @State var totalSent: UInt64 = 0
    @State var ethernet: UInt64 = 0
    @State var cellular: UInt64 = 0
    @State var isStarted = false
    
    @State var time = Date()
    
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
                        Text(downloadSpeed.speed)
                    }
                    HStack {
                        Text(LocalizedStringKey("upload_speed"))
                        Spacer()
                        Text(uploadSpeed.speed)
                    }
                    HStack {
                        Text(LocalizedStringKey("total_received"))
                        Spacer()
                        Text(totalReceived.throughput)
                    }
                    HStack {
                        Text(LocalizedStringKey("total_sent"))
                        Spacer()
                        Text(totalSent.throughput)
                    }
                }
                
                Section(LocalizedStringKey("interface")) {
                    HStack {
                        Text(LocalizedStringKey("wi_fi_ethernet"))
                        Spacer()
                        Text(ethernet.throughput)
                    }
                    HStack {
                        Text(LocalizedStringKey("cellular"))
                        Spacer()
                        Text(cellular.throughput)
                    }
                }
                
                Section {
                    HStack {
                        Picker("secondary_indicator", selection: $selectedSecondaryIndicator) {
                            ForEach(Indicator.allCases) { indicator in
                                Text(LocalizedStringKey(indicator.rawValue))
                                    .tag(indicator)
                            }
                        }
                    }
                    Button(LocalizedStringKey(isPiPPresented ? "close_picture_in_picture" : "open_picture_in_picture")) {
                        isPiPPresented.toggle()
                    }
                    .pipify(isPresented: $isPiPPresented) {
                        MonitorView(secondaryIndicator: $selectedSecondaryIndicator, colorScheme: $colorSchemeBinding, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed, totalReceived: $totalReceived, totalSent: $totalSent, ethernet: $ethernet, cellular: $cellular, time: $time)
                            .frame(width: UIScreen.main.bounds.size.width, height: 30)
                            .pipControlsStyle(controlsStyle: 2)
                    }
                    Button(LocalizedStringKey("reset")) {
                        monitor.reset()
                        downloadSpeed = 0
                        uploadSpeed = 0
                        totalReceived = 0
                        totalSent = 0
                        ethernet = 0
                        cellular = 0
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
                        self.downloadSpeed = downloadSpeed
                        self.uploadSpeed = uploadSpeed
                        self.totalReceived = totalReceived
                        self.totalSent = totalSent
                        self.ethernet = ethernet
                        self.cellular = cellular
                    }
                    isStarted = true
                }
            }
            .onChange(of: colorScheme) { colorScheme in
                colorSchemeBinding = colorScheme
            }
            .onChange(of: selectedSecondaryIndicator) { secondaryIndicator in
                timer?.invalidate()
                timer = nil
                if secondaryIndicator == .time {
                    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                        time = Date()
                    }
                }
            }
            .onOpenURL { url in
                if url.host() == "pip" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isPiPPresented = true
                    }
                }
            }
            .sheet(isPresented: $isInfoPresented) {
                AboutView()
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
