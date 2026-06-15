import SwiftUI
import AvasiaEngine

/// Maps engine `StyledLine.Style` to colors/fonts (ENGINE_SPEC §B.7). The
/// blue-crystal accent is the app's signature (STORY.md §8).
enum Theme {
    static let accent = Color(red: 0.35, green: 0.65, blue: 0.95)   // blue crystal
    static let parchment = Color(red: 0.90, green: 0.87, blue: 0.78)
    static let night = Color(red: 0.06, green: 0.07, blue: 0.10)

    static func color(for style: StyledLine.Style) -> Color {
        switch style {
        case .body:   return parchment
        case .speech: return parchment.opacity(0.95)
        case .item:   return Color.green
        case .death:  return Color.red
        case .symbol: return Color.orange
        case .title:  return accent
        case .hint:   return parchment.opacity(0.55)
        }
    }

    static func font(for style: StyledLine.Style) -> Font {
        switch style {
        case .title:  return .system(.title2, design: .serif).bold()
        case .symbol: return .system(.body, design: .monospaced)
        case .speech: return .system(.body, design: .serif).italic()
        case .hint:   return .system(.callout, design: .serif)
        default:      return .system(.body, design: .serif)
        }
    }
}

struct LineView: View {
    let line: StyledLine
    var body: some View {
        Text(line.text.isEmpty ? " " : line.text)
            .font(Theme.font(for: line.style))
            .foregroundColor(Theme.color(for: line.style))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(line.text)
    }
}

struct MenuButton: View {
    enum Style { case standard, primary }

    let title: String
    var systemImage: String?
    var style: Style
    let action: () -> Void

    init(
        title: String,
        systemImage: String? = nil,
        style: Style = .standard,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.system(.body, design: .serif).weight(style == .primary ? .semibold : .regular))
                Spacer(minLength: 0)
            }
            .foregroundColor(style == .primary ? Theme.night : Theme.parchment)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.accent.opacity(style == .primary ? 0 : 0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private var buttonBackground: Color {
        style == .primary ? Theme.accent : Theme.accent.opacity(0.12)
    }
}
