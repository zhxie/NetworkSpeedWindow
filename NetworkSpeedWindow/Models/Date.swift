import Foundation

extension Date {
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SS"
        return formatter.string(from: self)
    }
    
    var datetimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/DD HH:mm:ss"
        return formatter.string(from: self)
    }
}
