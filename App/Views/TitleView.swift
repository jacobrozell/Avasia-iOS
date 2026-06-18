import SwiftUI
import AvasiaEngine

/// Per-game title screen (KoN or Blade of Courage) after saga selection.
struct TitleView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 52
    @State private var codexPreview: JournalEntry?

    var body: some View {
        ZStack {
            TitleScreenBackground()
            ScrollView {
                VStack(spacing: metrics.isAccessibilityText ? 20 : 32) {
                    Spacer(minLength: metrics.isLandscape ? 8 : 20)
                    titleHero
                    codexSection
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
        .sheet(item: $codexPreview) { entry in
            CodexDetailSheet(entry: entry)
        }
    }

    @ViewBuilder
    private var codexSection: some View {
        let unlocked = JournalCatalog.unlockedEntries(
            for: vm.product,
            kon: vm.konCodexState,
            soc: vm.socCodexState
        )
        if !unlocked.isEmpty {
            CodexStrip(
                entries: unlocked,
                onOpenJournal: { vm.openCodex(from: .title) },
                onSelect: { codexPreview = $0 }
            )
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

            chroniclerBadge

            TitleOrnament(flipped: true)
                .padding(.top, 2)
        }
        .accessibilityElement(children: .combine)
    }

    private var chroniclerBadge: some View {
        let profile = vm.sagaProfile
        return Button {
            vm.openChroniclerLedger(from: .title)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                Text("Chronicler · Rank \(profile.chroniclerRank)")
                    .font(.caption.weight(.semibold))
                if profile.currentRunXP > 0, AppSettings.chroniclerShowThisRunXP {
                    Text("· +\(profile.currentRunXP) this run")
                        .font(.caption2)
                        .foregroundColor(Theme.parchment.opacity(0.7))
                }
            }
            .foregroundColor(Theme.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.accent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Chronicler rank \(profile.chroniclerRank), open ledger")
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
                MenuButton(title: "Journal", systemImage: "book.closed.fill") {
                    vm.openCodex(from: .title)
                }
                MenuButton(title: "Achievements", systemImage: "trophy") {
                    vm.openAchievements(from: .title)
                }
            } else if vm.product == .soc {
                MenuButton(title: "Journal", systemImage: "book.closed.fill") {
                    vm.openCodex(from: .title)
                }
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
                        TitleHintBanner(
                            systemImage: "checkmark.seal.fill",
                            text: "Campaign complete — replay anytime from New Game.",
                            emphasis: true
                        )
                    }
                    TitleHintBanner(
                        systemImage: "hammer.fill",
                        text: "Full campaign through the Age epilogue. Level up through quests and combat."
                    )
                    TitleHintBanner(
                        systemImage: "sparkles",
                        text: TitleHints.pacing
                    )
                }
            } else if vm.product == .stories {
                VStack(spacing: 8) {
                    TitleHintBanner(
                        systemImage: "book.fill",
                        text: "Story hub — finish Scout Patrol, then spend FP on your alignment story."
                    )
                    TitleHintBanner(
                        systemImage: "sparkles",
                        text: TitleHints.pacing
                    )
                }
            } else {
                TitleHintBanner(
                    systemImage: "sparkles",
                    text: TitleHints.pacing
                )
            }
        }
    }
}

enum TitleHints {
    static let pacing = "Story text appears gradually. Tap the transcript to skip ahead."
}

struct TitleHintBanner: View {
    var systemImage: String
    var text: String
    var emphasis: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption)
                .foregroundColor(Theme.accent.opacity(emphasis ? 1 : 0.8))
                .accessibilityHidden(true)
            Text(text)
                .font(.footnote)
                .foregroundColor(Theme.parchment.opacity(emphasis ? 0.85 : 0.62))
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent.opacity(emphasis ? 0.15 : 0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}
