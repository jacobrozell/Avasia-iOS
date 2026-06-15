import SwiftUI
import AvasiaEngine

/// Lists every achievement with locked/unlocked state. Secret achievements stay
/// masked until earned (title shown as "???", detail hidden). Reachable from the
/// title menu and the in-game trophy button.
struct AchievementsView: View {
    @EnvironmentObject var vm: GameViewModel

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
                    }
                    .padding()
                }
                MenuButton(title: "Back") { vm.screen = vm.achievementsReturn }
                    .padding(.bottom)
            }
        }
    }

    private var header: some View {
        let p = vm.achievements
        return VStack(spacing: 4) {
            Text("Achievements")
                .font(.system(.largeTitle, design: .serif).bold())
                .foregroundColor(Theme.accent)
            Text("\(p.unlockedCount) / \(p.total) unlocked")
                .font(.callout).foregroundColor(Theme.parchment.opacity(0.6))
            if p.totalDeaths > 0 {
                Text("Lifetime deaths: \(p.totalDeaths)")
                    .font(.caption2).foregroundColor(Theme.parchment.opacity(0.4))
            }
        }
        .padding(.top, 24)
    }

    private func row(_ ach: Achievement, unlocked: Bool) -> some View {
        let masked = ach.isSecret && !unlocked
        return HStack(spacing: 14) {
            Image(systemName: unlocked ? "trophy.fill" : (masked ? "questionmark.circle" : "lock"))
                .font(.title3)
                .foregroundColor(unlocked ? .yellow : Theme.parchment.opacity(0.35))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(masked ? "??? (Secret)" : ach.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundColor(unlocked ? Theme.parchment : Theme.parchment.opacity(0.7))
                Text(masked ? "Hidden — discover it in play." : ach.detail)
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.5))
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(unlocked ? Theme.accent.opacity(0.12) : Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(unlocked ? Theme.accent.opacity(0.5) : Color.white.opacity(0.06)))
    }
}
