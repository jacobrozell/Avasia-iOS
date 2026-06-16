import SwiftUI
import AvasiaEngine

struct ThemeColors {
    let background: Color
    let backgroundGradientTop: Color
    let backgroundGradientBottom: Color
    let parchment: Color
    let accent: Color
    let onAccent: Color
    let cardFill: Color
    let cardStroke: Color

    static let dark = ThemeColors(
        background: Color(red: 0.06, green: 0.07, blue: 0.10),
        backgroundGradientTop: Color(red: 0.05, green: 0.07, blue: 0.12),
        backgroundGradientBottom: Color(red: 0.04, green: 0.04, blue: 0.07),
        parchment: Color(red: 0.90, green: 0.87, blue: 0.78),
        accent: Color(red: 0.35, green: 0.65, blue: 0.95),
        onAccent: Color(red: 0.06, green: 0.07, blue: 0.10),
        cardFill: Color.white.opacity(0.03),
        cardStroke: Color(red: 0.35, green: 0.65, blue: 0.95).opacity(0.4)
    )

    static let light = ThemeColors(
        background: Color(red: 0.96, green: 0.94, blue: 0.90),
        backgroundGradientTop: Color(red: 0.98, green: 0.96, blue: 0.93),
        backgroundGradientBottom: Color(red: 0.91, green: 0.88, blue: 0.82),
        parchment: Color(red: 0.16, green: 0.13, blue: 0.10),
        accent: Color(red: 0.20, green: 0.45, blue: 0.78),
        onAccent: Color(red: 0.98, green: 0.97, blue: 0.95),
        cardFill: Color.black.opacity(0.04),
        cardStroke: Color(red: 0.20, green: 0.45, blue: 0.78).opacity(0.35)
    )
}

/// Maps engine `StyledLine.Style` to colors/fonts (ENGINE_SPEC §B.7).
enum Theme {
    private(set) static var palette = ThemeColors.dark

    static var background: Color { palette.background }
    static var night: Color { palette.background }
    static var parchment: Color { palette.parchment }
    static var accent: Color { palette.accent }
    static var onAccent: Color { palette.onAccent }

    static func applyPalette(for appearance: AppAppearance, system: ColorScheme) {
        palette = appearance.resolvedScheme(system: system) == .dark ? .dark : .light
    }

    static var isLight: Bool { palette.background == ThemeColors.light.background }

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
    @EnvironmentObject private var vm: GameViewModel
    let line: StyledLine
    var partialLength: Int?
    var showsCursor: Bool = false
    var emphasis: CombatLineEmphasis?
    var playReveal: Bool = false

    @State private var cursorVisible = true
    @State private var emphasisPulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var displayText: String {
        if line.text.isEmpty { return " " }
        guard let partialLength else { return line.text }
        return String(line.text.prefix(partialLength))
    }

    private var cursorGlyph: String? {
        guard showsCursor else { return nil }
        return vm.cursorStyle.glyph
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(displayText)
                .font(Theme.font(for: line.style))
                .foregroundColor(displayColor)
                .scaleEffect(emphasisScale)
            if let glyph = cursorGlyph {
                Text(glyph)
                    .font(Theme.font(for: line.style))
                    .foregroundColor(Theme.accent.opacity(0.75))
                    .opacity(cursorVisible ? 1 : 0.2)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .transcriptLineReveal(
            playReveal: playReveal && partialLength == nil,
            isHint: line.style == .hint
        )
        .accessibilityLabel(line.text)
        .task(id: showsCursor) {
            guard showsCursor, cursorGlyph != nil else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 480_000_000)
                cursorVisible.toggle()
            }
        }
        .onAppear { triggerEmphasisPulse() }
        .onChange(of: emphasis) { _ in triggerEmphasisPulse() }
    }

    private var displayColor: Color {
        guard emphasisPulse, let emphasis else {
            return Theme.color(for: line.style)
        }
        switch emphasis {
        case .playerHit: return Theme.accent
        case .playerDamaged, .kill, .lowHp: return .red
        case .miss: return Theme.parchment.opacity(0.65)
        case .block: return Theme.accent
        case .heal: return .green
        }
    }

    private var emphasisScale: CGFloat {
        guard emphasisPulse, emphasis == .kill else { return 1 }
        return 1.03
    }

    private func triggerEmphasisPulse() {
        guard emphasis != nil else {
            emphasisPulse = false
            return
        }
        if reduceMotion {
            emphasisPulse = true
            return
        }
        emphasisPulse = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 320_000_000)
            withAnimation(.easeOut(duration: 0.2)) {
                emphasisPulse = false
            }
        }
    }
}

struct MenuButton: View {
    enum Style { case standard, primary }

    let title: String
    var systemImage: String?
    var style: Style
    var accessibilityIdentifier: String?
    let action: () -> Void

    init(
        title: String,
        systemImage: String? = nil,
        style: Style = .standard,
        accessibilityIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.shared.play(style == .primary ? .confirm : .tap)
            action()
        } label: {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.system(.body, design: .serif).weight(style == .primary ? .semibold : .regular))
                Spacer(minLength: 0)
            }
            .foregroundColor(style == .primary ? Theme.onAccent : Theme.parchment)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.palette.cardStroke.opacity(style == .primary ? 0 : 1), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(title)
        .accessibilityIdentifier(accessibilityIdentifier ?? title)
    }

    private var buttonBackground: Color {
        style == .primary ? Theme.accent : Theme.accent.opacity(0.12)
    }
}

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.palette.cardFill, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.palette.cardStroke))
    }
}

// MARK: - Interaction

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Surfaces

/// Subtle parchment wash behind the game transcript (WIREFRAMES art direction).
struct ParchmentBackground: View {
    var body: some View {
        ZStack {
            Theme.background.opacity(Theme.isLight ? 0.92 : 0.55)
            LinearGradient(
                colors: [
                    Theme.parchment.opacity(Theme.isLight ? 0.06 : 0.04),
                    Theme.background.opacity(0),
                    Theme.parchment.opacity(Theme.isLight ? 0.03 : 0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct ProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.palette.cardFill)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Theme.accent, Theme.accent.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * min(max(value, 0), 1), value > 0 ? 4 : 0))
            }
        }
        .frame(height: 5)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(value * 100)) percent")
    }
}

struct ChapterCard: View {
    let product: AvasiaProduct
    let systemImage: String
    var hasSave: Bool
    var saveHint: String?
    var completionCount: Int = 0
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.play(.tap)
            action()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 44, height: 44)
                    .background(Theme.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(product.menuTitle)
                            .font(.system(.headline, design: .serif).weight(.semibold))
                            .foregroundColor(Theme.parchment)
                        Spacer(minLength: 8)
                        if hasSave {
                            Label("Saved", systemImage: "bookmark.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(Theme.accent)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    Text(product.subtitle)
                        .font(.subheadline)
                        .foregroundColor(Theme.parchment.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                    if let saveHint {
                        Text(saveHint)
                            .font(.caption)
                            .foregroundColor(Theme.parchment.opacity(0.55))
                    }
                    if completionCount > 0 {
                        Text("Completed \(completionCount)×")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(Theme.accent.opacity(0.85))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.35))
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.palette.cardStroke, lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(product.menuTitle)
        .accessibilityHint(product.subtitle)
        .accessibilityValue(hasSave ? "Save in progress" : "No save")
        .accessibilityIdentifier(
            product == .kon ? "saga-kon" : (product == .soc ? "saga-soc" : "saga-stories")
        )
    }
}

struct StatusBadge: View {
    let title: String
    let systemImage: String
    var tint: Color = Theme.accent

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.weight(.semibold))
            .foregroundColor(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.14), in: Capsule())
    }
}

struct SettingsLinkRow: View {
    let title: String
    let systemImage: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundColor(Theme.accent)
                Text(title)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Theme.parchment)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.45))
            }
            .padding(.vertical, 4)
        }
    }
}
