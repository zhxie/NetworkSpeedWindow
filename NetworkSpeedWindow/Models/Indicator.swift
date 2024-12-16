enum Indicator: String, CaseIterable, Identifiable {
    case throughput
    case interface
    case time
    
    var id: Self {
        self
    }
}
