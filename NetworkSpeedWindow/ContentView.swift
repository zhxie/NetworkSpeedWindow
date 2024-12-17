import Pipify
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var colorSchemeBinding: ColorScheme = .light
    
    let monitor = NetworkSpeedMonitor()
    @State var metrics = Metrics()
    @State var laps: [(Date, Metrics)] = []
    @State var isStarted = false
    
    @State var timer: Timer? = nil
    @State var time = Date()
    
    @State var selectedSecondaryIndicator: Indicator = .throughput
    @State var isPiPPresented = false
    @State var isInfoPresented = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(LocalizedStringKey("network")) {
                    HStack {
                        Text(LocalizedStringKey("download_speed"))
                        Spacer()
                        Text(metrics.downloadSpeed.speed)
                    }
                    HStack {
                        Text(LocalizedStringKey("upload_speed"))
                        Spacer()
                        Text(metrics.uploadSpeed.speed)
                    }
                    HStack {
                        Text(LocalizedStringKey("total_received"))
                        Spacer()
                        Text(metrics.totalReceived.throughput)
                    }
                    HStack {
                        Text(LocalizedStringKey("total_sent"))
                        Spacer()
                        Text(metrics.totalSent.throughput)
                    }
                }
                
                Section(LocalizedStringKey("interface")) {
                    HStack {
                        Text(LocalizedStringKey("wi_fi_ethernet"))
                        Spacer()
                        Text(metrics.ethernet.throughput)
                    }
                    HStack {
                        Text(LocalizedStringKey("cellular"))
                        Spacer()
                        Text(metrics.cellular.throughput)
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
                        MonitorView(secondaryIndicator: $selectedSecondaryIndicator, colorScheme: $colorSchemeBinding, metrics: $metrics, time: $time)
                            .frame(width: UIScreen.main.bounds.size.width, height: 30)
                            .pipControlsStyle(controlsStyle: 2)
                    }
                    Button(LocalizedStringKey("lap")) {
                        withAnimation {
                            laps.insert((Date.now, metrics), at: 0)
                        }
                    }
                    Button(LocalizedStringKey("reset"), role: .destructive) {
                        monitor.reset()
                        metrics = Metrics()
                        // HACK: avoid animation penetrated to texts above.
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            withAnimation {
                                laps.removeAll()
                            }
                        }
                    }
                }
                
                if !laps.isEmpty {
                    Section(LocalizedStringKey("laps")) {
                        List(laps, id: \.0) { lap in
                            LapView(time: lap.0, metrics: lap.1)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            laps.removeAll { (date, _) in
                                                date == lap.0
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "trash.fill")
                                    }
                                }
                        }
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
                    monitor.startMonitoring { [self] metrics in
                        self.metrics = metrics
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
