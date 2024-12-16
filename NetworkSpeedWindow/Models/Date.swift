import Foundation

extension Date {
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS"
        return formatter.string(from: self)
    }
}
