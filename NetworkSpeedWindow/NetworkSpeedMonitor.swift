import Foundation
import Network
import SystemConfiguration

class NetworkSpeedMonitor {
    var previousReceived: Int = 0
    var previousSent: Int = 0
    var totalReceived: Int = 0
    var totalSent: Int = 0
    var timer: Timer?

    func startMonitoring(interval: TimeInterval = 1.0, update: @escaping (_ downloadSpeed: Double, _ uploadSpeed: Double, _ totalBytesReceived: Int, _ totalBytesSent: Int) -> Void) {
        let networkData = getNetworkData()
        previousReceived = networkData.received
        previousSent = networkData.sent
        
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            let networkData = self.getNetworkData()
            let received = networkData.received - self.previousReceived
            let sent = networkData.sent - self.previousSent
            let downloadSpeed = Double(received) / interval
            let uploadSpeed = Double(sent) / interval
            self.totalReceived = self.totalReceived + received
            self.totalSent = self.totalSent + sent

            self.previousReceived = networkData.received
            self.previousSent = networkData.sent
            
            update(downloadSpeed, uploadSpeed, self.totalReceived, self.totalSent)
        }
    }
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        
        previousReceived = 0
        previousSent = 0
        totalReceived = 0
        totalSent = 0
    }

    func getNetworkData() -> (received: Int, sent: Int) {
        var ifaddrsPointer: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrsPointer) == 0, let firstAddress = ifaddrsPointer else {
            return (0, 0)
        }

        var received = 0
        var sent = 0

        for ifaddr in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ifaddr.pointee.ifa_flags)
            let isUp = (flags & (IFF_UP | IFF_RUNNING)) != 0
            let isLoopback = (flags & IFF_LOOPBACK) != 0

            if isUp, !isLoopback, let data = ifaddr.pointee.ifa_data?.assumingMemoryBound(to: if_data.self) {
                received += Int(data.pointee.ifi_ibytes)
                sent += Int(data.pointee.ifi_obytes)
            }
        }

        freeifaddrs(ifaddrsPointer)
        return (received, sent)
    }
}
