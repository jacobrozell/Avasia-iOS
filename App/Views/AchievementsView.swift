import SwiftUI
import AvasiaEngine

/// Lists every achievement with locked/unlocked state. Secret achievements stay
/// masked until earned (title shown as "???", detail hidden). Reachable from the
/// title menu and the in-game trophy button.
struct AchievementsView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Achievement.allCases, id: \.self) { ach in
                            row(ach, unlocked: vm.achievements.has(ach))
                        }
                        if !vm.chroniclerPendingClaims.isEmpty {
                            Text("Tap Claim to add achievement XP to your Chronicler rank.")
                                .font(.caption)
                                .foregroundColor(Theme.parchment.opacity(0.5))
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 8)
                    .frame(maxWidth: metrics.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                }
                MenuButton(title: "Back") { vm.screen = vm.achievementsReturn }
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 12)
            }
        }
    }

    private var header: some View {
        let p = vm.achievements
        let progress = p.total > 0 ? Double(p.unlockedCount) / Double(p.total) : 0
        return VStack(spacing: 8) {
            Text("Achievements")
                .font(.system(.largeTitle, design: .serif).bold())
                .foregroundColor(Theme.accent)
                .accessibilityAddTraits(.isHeader)
            Text("\(p.unlockedCount) / \(p.total) unlocked")
                .font(.callout).foregroundColor(Theme.parchment.opacity(0.6))
            ProgressBar(value: progress)
                .padding(.horizontal, 8)
            if p.totalDeaths > 0 {
                Text("Lifetime deaths: \(p.totalDeaths)")
                    .font(.caption2).foregroundColor(Theme.parchment.opacity(0.4))
            }
            let pending = vm.chroniclerPendingClaims.count
            if pending > 0 {
                Text("\(pending) achievement\(pending == 1 ? "" : "s") ready to claim for Chronicler XP")
                    .font(.caption2)
                    .foregroundColor(Theme.accent.opacity(0.85))
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, 8)
    }

    private func row(_ ach: Achievement, unlocked: Bool) -> some View {
        let masked = ach.isSecret && !unlocked
        return HStack(alignment: .top, spacing: 14) {
            Image(systemName: unlocked ? "trophy.fill" : (masked ? "questionmark.circle" : "lock"))
                .font(.title3)
                .foregroundColor(unlocked ? .yellow : Theme.parchment.opacity(0.35))
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(masked ? "??? (Secret)" : ach.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(unlocked ? Theme.parchment : Theme.parchment.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                Text(masked ? "Hidden — discover it in play." : ach.detail)
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if unlocked, vm.sagaProfile.canClaimAchievement(ach) {
                Button("Claim +\(SagaXPTracker.xpForAchievement(ach))") {
                    vm.claimChroniclerAchievement(ach)
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(Theme.accent)
            } else if unlocked, !vm.sagaProfile.canClaimAchievement(ach) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Theme.accent.opacity(0.6))
                    .accessibilityLabel("XP claimed")
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(unlocked ? Theme.accent.opacity(0.12) : Theme.palette.cardFill))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(unlocked ? Theme.accent.opacity(0.5) : Theme.palette.cardStroke.opacity(0.5)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(masked ? "Secret achievement, locked" : ach.title)
        .accessibilityValue(unlocked ? "Unlocked" : "Locked")
    }
}
