import SwiftUI

struct MonitorView: View {
    // HACK: We have to use bindings for Pipify.
    @Binding var colorScheme: ColorScheme
    
    @Binding var downloadSpeed: Double
    @Binding var uploadSpeed: Double
    @Binding var totalReceived: UInt64
    @Binding var totalSent: UInt64
    
    var body: some View {
        HStack {
            Grid(horizontalSpacing: 8) {
                GridRow {
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
    MonitorView(colorScheme: .constant(.light), downloadSpeed: .constant(999), uploadSpeed: .constant(999_999_999_999), totalReceived: .constant(999_999), totalSent: .constant(9_999_999_999_999_999))
}
