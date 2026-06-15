import SwiftUI
import AvasiaEngine

/// Saga hub — pick King of Nacastrum or Sword of Courage. Each game has its own
/// title screen, save slot, and engine.
struct SagaTitleView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 48

    var body: some View {
        ZStack {
            TitleScreenBackground()
            ScrollView {
                VStack(spacing: metrics.isAccessibilityText ? 20 : 28) {
                    Spacer(minLength: metrics.isLandscape ? 8 : 24)
                    sagaHero
                    gamePicker
                    footerHint
                }
                .frame(maxWidth: metrics.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }

    private var sagaHero: some View {
        VStack(spacing: metrics.isAccessibilityText ? 10 : 14) {
            TitleOrnament()
            Text("AVASIA")
                .font(.system(size: titleSize, weight: .heavy, design: .serif))
                .tracking(metrics.isAccessibilityText ? 2 : 6)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accent.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Theme.accent.opacity(0.45), radius: 18, y: 4)
                .minimumScaleFactor(0.65)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            Text("Choose your chapter")
                .font(.system(.title3, design: .serif).italic())
                .foregroundColor(Theme.parchment.opacity(0.88))
            TitleOrnament(flipped: true)
        }
    }

    private var gamePicker: some View {
        VStack(spacing: 14) {
            ForEach(AvasiaProduct.allCases, id: \.self) { game in
                MenuButton(title: game.menuTitle, systemImage: icon(for: game), style: .primary) {
                    vm.openProduct(game)
                }
                Text(game.subtitle)
                    .font(.footnote)
                    .foregroundColor(Theme.parchment.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
            }
            MenuButton(title: "Settings", systemImage: "gearshape") {
                vm.openSettings(from: .saga)
            }
            MenuButton(title: "Credits", systemImage: "scroll") {
                vm.openCredits(from: .saga)
            }
        }
    }

    private func icon(for product: AvasiaProduct) -> String {
        switch product {
        case .kon: return "crown.fill"
        case .soc: return "shield.lefthalf.filled"
        }
    }

    private var footerHint: some View {
        Text("Each chapter has its own save file.")
            .font(.footnote)
            .foregroundColor(Theme.parchment.opacity(0.55))
            .multilineTextAlignment(.center)
    }
}

// Shared with TitleView
struct TitleScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.07, blue: 0.12),
                    Theme.night,
                    Color(red: 0.04, green: 0.04, blue: 0.07)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Theme.accent.opacity(0.22), .clear],
                center: .init(x: 0.5, y: 0.18),
                startRadius: 20,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

struct TitleOrnament: View {
    var flipped: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            line
            Image(systemName: "sparkle")
                .font(.caption)
                .foregroundStyle(Theme.accent)
            line
        }
        .rotationEffect(flipped ? .degrees(180) : .zero)
        .accessibilityHidden(true)
    }

    private var line: some View {
        LinearGradient(
            colors: [.clear, Theme.accent.opacity(0.55), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .frame(maxWidth: 72)
    }
}
