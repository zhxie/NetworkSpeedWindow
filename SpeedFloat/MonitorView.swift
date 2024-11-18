import SwiftUI

struct MonitorView: View {
    // HACK: We have to use bindings for Pipify.
    @Binding var colorScheme: ColorScheme
    
    @Binding var downloadSpeed: String
    @Binding var uploadSpeed: String
    @Binding var totalBytesReceived: String
    @Binding var totalBytesSent: String
    
    var body: some View {
        HStack {
            Grid(horizontalSpacing: 8) {
                GridRow {
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(downloadSpeed)
                            .lineLimit(1)
                            .foregroundStyle(foreground)
                    }
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(uploadSpeed)
                            .lineLimit(1)
                            .foregroundStyle(foreground)
                    }
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(totalBytesReceived)
                            .lineLimit(1)
                            .foregroundStyle(foreground)
                    }
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .foregroundStyle(.tint)
                        Spacer()
                        Text(totalBytesSent)
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
    MonitorView(colorScheme: .constant(.light), downloadSpeed: .constant("999.9 TB/s"), uploadSpeed: .constant("999.9 TB/s"), totalBytesReceived: .constant("9999.9 TB"), totalBytesSent: .constant("9999.9 TB"))
}
