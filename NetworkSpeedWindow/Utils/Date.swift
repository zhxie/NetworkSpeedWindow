import Foundation

extension Date {
    var minute: Int {
        let calendar = Calendar.current
        return calendar.component(.minute, from: self)
    }
    
    var second: Int {
        let calendar = Calendar.current
        return calendar.component(.second, from: self)
    }
    
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
