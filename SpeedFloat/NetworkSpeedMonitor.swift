import Foundation
import Network
import SystemConfiguration

class NetworkSpeedMonitor {
    var previousBytesReceived: Int = 0
    var previousBytesSent: Int = 0
    var totalBytesReceived: Int = 0
    var totalBytesSent: Int = 0
    var timer: Timer?

    func startMonitoring(interval: TimeInterval = 1.0, update: @escaping (_ downloadSpeed: Double, _ uploadSpeed: Double, _ totalBytesReceived: Int, _ totalBytesSent: Int) -> Void) {
        let networkData = getNetworkData()
        previousBytesReceived = networkData.bytesReceived
        previousBytesSent = networkData.bytesSent
        
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            let networkData = self.getNetworkData()
            let bytesReceived = networkData.bytesReceived - self.previousBytesReceived
            let bytesSent = networkData.bytesSent - self.previousBytesSent
            let downloadSpeed = Double(bytesReceived) / interval
            let uploadSpeed = Double(bytesSent) / interval
            self.totalBytesReceived = self.totalBytesReceived + bytesReceived
            self.totalBytesSent = self.totalBytesSent + bytesSent

            self.previousBytesReceived = networkData.bytesReceived
            self.previousBytesSent = networkData.bytesSent
            
            update(downloadSpeed, uploadSpeed, self.totalBytesReceived, self.totalBytesSent)
        }
    }
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        
        previousBytesReceived = 0
        previousBytesSent = 0
        totalBytesReceived = 0
        totalBytesSent = 0
    }

    func getNetworkData() -> (bytesReceived: Int, bytesSent: Int) {
        var ifaddrsPointer: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrsPointer) == 0, let firstAddress = ifaddrsPointer else {
            return (0, 0)
        }

        var bytesReceived = 0
        var bytesSent = 0

        for ifaddr in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ifaddr.pointee.ifa_flags)
            let isUp = (flags & (IFF_UP | IFF_RUNNING)) != 0
            let isLoopback = (flags & IFF_LOOPBACK) != 0

            if isUp, !isLoopback, let data = ifaddr.pointee.ifa_data?.assumingMemoryBound(to: if_data.self) {
                bytesReceived += Int(data.pointee.ifi_ibytes)
                bytesSent += Int(data.pointee.ifi_obytes)
            }
        }

        freeifaddrs(ifaddrsPointer)
        return (bytesReceived, bytesSent)
    }
}
