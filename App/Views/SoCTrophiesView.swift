import SwiftUI
import AvasiaSoCEngine

/// Trophy catalog for *Sword of Courage* — mirrors KoN `AchievementsView`.
struct SoCTrophiesView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(SoCTrophy.allCases, id: \.self) { trophy in
                            row(trophy, unlocked: vm.socState.trophies.contains(trophy))
                        }
                    }
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 8)
                    .frame(maxWidth: metrics.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                }
                MenuButton(title: "Back") { vm.screen = vm.trophiesReturn }
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 12)
            }
        }
    }

    private var header: some View {
        let unlocked = vm.socState.trophies.count
        let total = SoCTrophy.allCases.count
        return VStack(spacing: 4) {
            Text("Trophies")
                .font(.system(.largeTitle, design: .serif).bold())
                .foregroundColor(Theme.accent)
                .accessibilityAddTraits(.isHeader)
            Text("\(unlocked) / \(total) unlocked")
                .font(.callout)
                .foregroundColor(Theme.parchment.opacity(0.6))
            if vm.socState.questExp > 0 {
                Text(SoCQuestProgress.levelSummary(vm.socState))
                    .font(.caption2)
                    .foregroundColor(Theme.parchment.opacity(0.4))
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, metrics.horizontalPadding)
    }

    private func row(_ trophy: SoCTrophy, unlocked: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: unlocked ? "trophy.fill" : "lock")
                .font(.title3)
                .foregroundColor(unlocked ? .yellow : Theme.parchment.opacity(0.35))
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(trophy.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(unlocked ? Theme.parchment : Theme.parchment.opacity(0.7))
                Text(unlocked ? trophy.detail : trophy.unlockHint)
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(unlocked ? Theme.accent.opacity(0.12) : Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(unlocked ? Theme.accent.opacity(0.5) : Color.white.opacity(0.06)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(trophy.title)
        .accessibilityValue(unlocked ? "Unlocked" : "Locked")
    }
}
