extension BinaryFloatingPoint {
    var speed: String {
        String(format: "%@/s", formatData(Double(self)))
    }
}

extension BinaryInteger where Self: FixedWidthInteger {
    var throughput: String {
        formatData(Double(self))
    }
}

let Units = ["B", "kB", "MB", "GB", "TB"]
func formatData(_ data: Double) -> String {
    var unit = 0
    var data = data
    while data >= 1024 && unit < Units.count - 1 {
        data = data / 1024
        unit = unit + 1
    }
    if unit <= 1 {
        return String(format: "%d %@", Int(data), Units[unit])
    }
    return String(format: "%.2f %@", data, Units[unit])
}
