import SwiftUI
import AvasiaEngine

/// Per-game title screen (KoN or Blade of Courage) after saga selection.
struct TitleView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 52

    var body: some View {
        ZStack {
            TitleScreenBackground()
            ScrollView {
                VStack(spacing: metrics.isAccessibilityText ? 20 : 32) {
                    Spacer(minLength: metrics.isLandscape ? 8 : 20)
                    titleHero
                    menuSection
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

    private var titleHero: some View {
        VStack(spacing: metrics.isAccessibilityText ? 10 : 14) {
            TitleOrnament()
                .padding(.bottom, 4)

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

            Text(vm.product.menuTitle)
                .font(.system(.title3, design: .serif).italic())
                .foregroundColor(Theme.parchment.opacity(0.92))
                .multilineTextAlignment(.center)

            TitleOrnament(flipped: true)
                .padding(.top, 2)
        }
        .accessibilityElement(children: .combine)
    }

    private var menuSection: some View {
        VStack(spacing: 12) {
            MenuButton(title: "Back to Saga", systemImage: "chevron.backward") {
                vm.backToSaga()
            }
            MenuButton(title: "New Game", systemImage: "play.fill", style: .primary) {
                vm.startNewGame()
            }
            if vm.hasSave {
                MenuButton(title: "Continue", systemImage: "arrow.clockwise", style: .primary) {
                    vm.continueGame()
                }
                if let summary = vm.socSaveSummary ?? vm.storiesSaveSummary {
                    Text(summary)
                        .font(.footnote)
                        .foregroundColor(Theme.parchment.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
            }
            if vm.product == .kon {
                MenuButton(title: "Achievements", systemImage: "trophy") {
                    vm.openAchievements(from: .title)
                }
            } else if vm.product == .soc {
                MenuButton(title: "Trophies", systemImage: "trophy") {
                    vm.openTrophies(from: .title)
                }
            }
            MenuButton(title: "Settings", systemImage: "gearshape") {
                vm.openSettings(from: .title)
            }
            MenuButton(title: "Credits", systemImage: "scroll") {
                vm.openCredits(from: .title)
            }
        }
        .padding(.vertical, 4)
    }

    private var footerHint: some View {
        Group {
            if vm.product == .soc {
                VStack(spacing: 8) {
                    if vm.socCampaignComplete {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Theme.accent)
                            Text("Campaign complete — replay anytime from New Game.")
                                .font(.footnote)
                                .foregroundColor(Theme.parchment.opacity(0.85))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                    }
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "hammer.fill")
                            .font(.caption)
                            .foregroundColor(Theme.accent.opacity(0.8))
                            .accessibilityHidden(true)
                        Text("Full campaign through the Age epilogue. Level up via quest and combat exp.")
                            .font(.footnote)
                            .foregroundColor(Theme.parchment.opacity(0.62))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                }
            } else if vm.product == .stories {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.caption)
                        .foregroundColor(Theme.accent.opacity(0.8))
                        .accessibilityHidden(true)
                    Text("Story hub — PLAY SCOUT first, then spend FP on your alignment path.")
                        .font(.footnote)
                        .foregroundColor(Theme.parchment.opacity(0.62))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            } else {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(Theme.accent.opacity(0.8))
                        .accessibilityHidden(true)
                    Text("Text pacing On types lines in gradually. Tap the transcript to skip.")
                        .font(.footnote)
                        .foregroundColor(Theme.parchment.opacity(0.62))
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
