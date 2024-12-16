import SwiftUI

struct MonitorView: View {
    @Binding var secondaryIndicator: Indicator
    // HACK: We have to use bindings for Pipify.
    @Binding var colorScheme: ColorScheme
    
    @Binding var downloadSpeed: Double
    @Binding var uploadSpeed: Double
    @Binding var totalReceived: UInt64
    @Binding var totalSent: UInt64
    @Binding var ethernet: UInt64
    @Binding var cellular: UInt64
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
                            Text(downloadSpeed.speed)
                                .lineLimit(1)
                                .foregroundStyle(foreground)
                        }
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundStyle(.tint)
                            Spacer()
                            Text(uploadSpeed.speed)
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
                                Text(totalReceived.throughput)
                                    .lineLimit(1)
                                    .foregroundStyle(foreground)
                            }
                            HStack {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(totalSent.throughput)
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
                                Text(ethernet.throughput)
                                    .lineLimit(1)
                                    .foregroundStyle(foreground)
                            }
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .foregroundStyle(.tint)
                                Spacer()
                                Text(cellular.throughput)
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
    MonitorView(secondaryIndicator: .constant(.throughput), colorScheme: .constant(.light), downloadSpeed: .constant(999), uploadSpeed: .constant(999_999_999_999), totalReceived: .constant(999_999), totalSent: .constant(999_999_999_999_999), ethernet: .constant(999_999_999), cellular: .constant(999_999_999_999_999_999), time: .constant(.now))
}
