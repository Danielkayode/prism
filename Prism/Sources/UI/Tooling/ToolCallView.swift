import SwiftUI

public struct ToolCallView: View {
    let event: ToolEvent
    
    public init(event: ToolEvent) {
        self.event = event
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Capsule()
                .fill(statusColor)
                .frame(width: 4)
            Image(systemName: iconName)
                .foregroundColor(statusColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(event.tool)
                    .font(.headline)
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let summary = event.resultSummary, !summary.isEmpty {
                    Text(summary)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                if let error = event.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            Spacer()
            if event.status == .running {
                ProgressView()
                    .tint(PrismTheme.accent)
            }
        }
        .glassCard()
    }
    
    private var iconName: String {
        switch event.status {
        case .running: return "circle.dotted"
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        case .blocked: return "nosign"
        }
    }
    
    private var statusColor: Color {
        switch event.status {
        case .running: return .gray
        case .success: return .green
        case .error: return .orange
        case .blocked: return .red
        }
    }
    
    private var statusMessage: String {
        switch event.status {
        case .running:
            if let params = event.params, !params.isEmpty {
                let kv = params.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
                return "Running… (\(kv))"
            }
            return "Running…"
        case .success:
            if let ms = event.durationMs { return "Done in \(ms) ms" }
            return "Done"
        case .error:
            return "Error"
        case .blocked:
            return "Blocked"
        }
    }
}
