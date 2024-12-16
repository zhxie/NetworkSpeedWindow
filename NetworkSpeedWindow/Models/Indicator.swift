enum Indicator: String, CaseIterable, Identifiable {
    case throughput
    case interface
    
    var id: Self {
        self
    }
}
