import Foundation
import Network
import SystemConfiguration

class NetworkSpeedMonitor {
    var previousEthernetReceived: UInt32 = 0
    var previousEthernetSent: UInt32 = 0
    var previousCellularReceived: UInt32 = 0
    var previousCellularSent: UInt32 = 0
    var totalEthernetReceived: UInt64 = 0
    var totalEthernetSent: UInt64 = 0
    var totalCellularReceived: UInt64 = 0
    var totalCellularSent: UInt64 = 0
    var timer: Timer?

    func startMonitoring(interval: TimeInterval = 1.0, update: @escaping (_ metrics: Metrics) -> Void) {
        reset()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            let data = self.getData()
            let ethernetReceived = data.ethernetReceived &- self.previousEthernetReceived
            let ethernetSent = data.ethernetSent &- self.previousEthernetSent
            let cellularReceived = data.cellularReceived &- self.previousCellularReceived
            let cellularSent = data.cellularSent &- self.previousCellularSent
            
            let downloadSpeed = Double(ethernetReceived + cellularReceived) / interval
            let uploadSpeed = Double(ethernetSent + cellularSent) / interval
            totalEthernetReceived = totalEthernetReceived + UInt64(ethernetReceived)
            totalEthernetSent = totalEthernetSent + UInt64(ethernetSent)
            totalCellularReceived = totalCellularReceived + UInt64(cellularReceived)
            totalCellularSent = totalCellularSent + UInt64(cellularSent)

            previousEthernetReceived = data.ethernetReceived
            previousEthernetSent = data.ethernetSent
            previousCellularReceived = data.cellularReceived
            previousCellularSent = data.cellularSent
            
#if targetEnvironment(simulator)
            // Used for screenshots only.
            update(Metrics(downloadSpeed: 126 * 1024, uploadSpeed: 91 * 1024, totalReceived: UInt64(77.52 * 1024 * 1024), totalSent: UInt64(86.66 * 1024 * 1024), ethernet: UInt64(158.08 * 1024 * 1024), cellular: UInt64(6.1 * 1024 * 1024)))
#else
            update(Metrics(downloadSpeed: downloadSpeed, uploadSpeed: uploadSpeed, totalReceived: totalEthernetReceived + totalCellularReceived, totalSent: totalEthernetSent + totalCellularSent, ethernet: totalEthernetReceived + totalEthernetSent, cellular: totalCellularReceived + totalCellularSent))
#endif
        }
    }
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        
        previousEthernetReceived = 0
        previousEthernetSent = 0
        previousCellularReceived = 0
        previousCellularSent = 0
        totalEthernetReceived = 0
        totalEthernetSent = 0
        totalCellularReceived = 0
        totalCellularSent = 0
    }
    
    func reset() {
        let data = getData()
        previousEthernetReceived = data.ethernetReceived
        previousEthernetSent = data.ethernetSent
        previousCellularReceived = data.cellularReceived
        previousCellularSent = data.cellularSent
        
        totalEthernetReceived = 0
        totalEthernetSent = 0
        totalCellularReceived = 0
        totalCellularSent = 0
    }

    func getData() -> (ethernetReceived: UInt32, ethernetSent: UInt32, cellularReceived: UInt32, cellularSent: UInt32) {
        var ifaddrsPointer: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrsPointer) == 0, let firstAddress = ifaddrsPointer else {
            return (0, 0, 0, 0)
        }

        var ethernetReceived: UInt32 = 0
        var ethernetSent: UInt32 = 0
        var cellularReceived: UInt32 = 0
        var cellularSent: UInt32 = 0

        for ifaddr in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ifaddr.pointee.ifa_flags)
            let isUp = (flags & (IFF_UP | IFF_RUNNING)) != 0
            let isLoopback = (flags & IFF_LOOPBACK) != 0

            if isUp, !isLoopback, let data = ifaddr.pointee.ifa_data?.assumingMemoryBound(to: if_data.self) {
                guard let name = String(cString: ifaddr.pointee.ifa_name, encoding: .utf8) else {
                    continue
                }
                
                if name.hasPrefix("en") {
                    ethernetReceived &+= data.pointee.ifi_ibytes
                    ethernetSent &+= data.pointee.ifi_obytes
                } else if name.hasPrefix("pdp_ip") {
                    cellularReceived &+= data.pointee.ifi_ibytes
                    cellularSent &+= data.pointee.ifi_obytes
                }
            }
        }

        freeifaddrs(ifaddrsPointer)
        return (ethernetReceived, ethernetSent, cellularReceived, cellularSent)
    }
}
