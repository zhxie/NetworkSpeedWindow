import SwiftUI

struct LapView: View {
    let time: Date
    let metrics: Metrics
    
    var body: some View {
        VStack {
            HStack {
                Text(time.datetimeFormatted)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            Grid(horizontalSpacing: 8) {
                GridRow {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(metrics.totalReceived.throughput)
                            .lineLimit(1)
                    }
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(metrics.totalSent.throughput)
                            .lineLimit(1)
                    }
                }
                GridRow {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(metrics.ethernet.throughput)
                            .lineLimit(1)
                    }
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(metrics.cellular.throughput)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

#Preview {
    LapView(time: Date.now, metrics: Metrics(downloadSpeed: 999, uploadSpeed: 999_999_999_999, totalReceived: 999_999, totalSent: 999_999_999_999_999, ethernet: 999_999_999, cellular: 999_999_999_999_999_999))
}
