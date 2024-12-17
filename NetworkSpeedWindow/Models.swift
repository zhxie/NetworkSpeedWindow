enum Indicator: String, CaseIterable, Identifiable {
    case throughput
    case interface
    case time
    
    var id: Self {
        self
    }
}

enum SoundEffect: String, CaseIterable, Identifiable {
    case none
    case everySecond = "every_second"
    case everyMinute = "every_minute"
    
    var id: Self {
        self
    }
}

struct Metrics {
    var downloadSpeed: Double = 0
    var uploadSpeed: Double = 0
    var totalReceived: UInt64 = 0
    var totalSent: UInt64 = 0
    var ethernet: UInt64 = 0
    var cellular: UInt64 = 0
}
