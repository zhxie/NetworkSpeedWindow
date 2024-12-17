import SwiftUI

struct MonitorView: View {
    @Binding var secondaryIndicator: Indicator
    // HACK: We have to use bindings for Pipify.
    @Binding var colorScheme: ColorScheme
    
    @Binding var metrics: Metrics
    @Binding var time: Date
    
    var body: some View {
        HStack {
            Grid(horizontalSpacing: 8) {
                GridRow {
                    HStack {
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundStyle(.tint)
                            Spacer()
                            Text(metrics.downloadSpeed.speed)
                                .lineLimit(1)
                                .foregroundStyle(foreground)
                        }
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundStyle(.tint)
                            Spacer()
                            Text(metrics.uploadSpeed.speed)
                                .lineLimit(1)
                                .foregroundStyle(foreground)
                        }
                    }
                    switch secondaryIndicator {
                    case .throughput:
                        HStack {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(metrics.totalReceived.throughput)
                                    .lineLimit(1)
                                    .foregroundStyle(foreground)
                            }
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(metrics.totalSent.throughput)
                                    .lineLimit(1)
                                    .foregroundStyle(foreground)
                            }
                        }
                    case .interface:
                        HStack {
                            HStack {
                                Image(systemName: "wifi")
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(metrics.ethernet.throughput)
                                    .lineLimit(1)
                                    .foregroundStyle(foreground)
                            }
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(metrics.cellular.throughput)
                                    .lineLimit(1)
                                    .foregroundStyle(foreground)
                            }
                        }
                    case .time:
                        HStack {
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundStyle(.tint)
                            Text(time.timeFormatted)
                                .monospaced()
                                .lineLimit(1)
                                .foregroundStyle(foreground)
                        }
                    }
                }
                .font(.caption2)
            }
        }
        .padding(8)
        .background(background)
    }
    
    var foreground: Color {
        colorScheme == .light ? .black : .white
    }
    var background: Color {
        colorScheme == .light ? .white : .black
    }
}

#Preview {
    MonitorView(secondaryIndicator: .constant(.throughput), colorScheme: .constant(.light), metrics: .constant(Metrics(downloadSpeed: 999, uploadSpeed: 999_999_999_999, totalReceived: 999_999, totalSent: 999_999_999_999_999, ethernet: 999_999_999, cellular: 999_999_999_999_999_999)), time: .constant(.now))
}
