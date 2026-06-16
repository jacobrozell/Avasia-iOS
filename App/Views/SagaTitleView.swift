import SwiftUI
import AvasiaEngine

/// Saga hub — pick King of Nacastrum or Blade of Courage. Each game has its own
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
                    chroniclerStrip
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

    private var chroniclerStrip: some View {
        let profile = vm.sagaProfile
        let progress = ChroniclerRank.progressToNextRank(from: profile.sagaXP)
        return Button {
            vm.openChroniclerLedger(from: .saga)
        } label: {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Chronicler · Rank \(profile.chroniclerRank)")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(Theme.parchment)
                        Text(profile.chroniclerSubtitle)
                            .font(.caption)
                            .foregroundColor(Theme.parchment.opacity(0.65))
                    }
                    Spacer()
                    Text("\(profile.sagaXP) XP")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.parchment.opacity(0.35))
                }
                ProgressBar(value: progress)
            }
            .padding(14)
            .background(Theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.palette.cardStroke, lineWidth: 1))
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Chronicler rank \(profile.chroniclerRank), \(profile.sagaXP) experience")
    }

    private var gamePicker: some View {
        VStack(spacing: 14) {
            ForEach(AvasiaProduct.allCases, id: \.self) { game in
                ChapterCard(
                    product: game,
                    systemImage: icon(for: game),
                    hasSave: vm.hasSave(for: game),
                    saveHint: vm.sagaSaveHint(for: game),
                    completionCount: vm.sagaProfile.completions(for: game)
                ) {
                    vm.openProduct(game)
                }
            }
            MenuButton(title: "Saga Timeline", systemImage: "clock.arrow.circlepath") {
                vm.openTimeline(from: .saga)
            }
            MenuButton(title: "Settings", systemImage: "gearshape", accessibilityIdentifier: "saga-settings") {
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
        case .stories: return "book.fill"
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
                    Theme.palette.backgroundGradientTop,
                    Theme.palette.background,
                    Theme.palette.backgroundGradientBottom
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
