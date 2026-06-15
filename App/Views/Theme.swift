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
    }
}
