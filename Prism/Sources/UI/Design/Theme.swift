import SwiftUI

public enum PrismTheme {
    public static let primaryStart = Color(hex: "#4A00E0")
    public static let primaryEnd = Color(hex: "#8E2DE2")
    public static let background = Color(hex: "#1E1E1E")
    public static let accent = Color(hex: "#00E5FF") // Electric cyan
    public static let card = Color.white.opacity(0.06)
    
    public static let headerGradient = LinearGradient(
        colors: [primaryStart, primaryEnd],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    public static let primaryGradient = LinearGradient(
        colors: [primaryStart, primaryEnd],
        startPoint: .leading, endPoint: .trailing
    )
}

public struct GlassCard: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(PrismTheme.card)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

public extension View {
    func glassCard() -> some View { modifier(GlassCard()) }
}

public struct PrismButtonStyle: ButtonStyle {
    public enum Kind { case primary, secondary }
    let kind: Kind
    
    public init(_ kind: Kind = .primary) { self.kind = kind }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxHeight: 44)
            .background(background(configuration: configuration))
            .foregroundColor(kind == .primary ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
    
    @ViewBuilder private func background(configuration: Configuration) -> some View {
        switch kind {
        case .primary:
            PrismTheme.primaryGradient
        case .secondary:
            Color.clear.overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(PrismTheme.accent.opacity(0.7), lineWidth: 1)
            )
        }
    }
}

public struct ModelBadge: View {
    public let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text)
            .font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(PrismTheme.primaryGradient)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

public extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
