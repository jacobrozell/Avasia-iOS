import SwiftUI
import AvasiaAnthologyEngine

/// Story selection sheet for anthology hub — replaces typing PLAY commands.
struct StoryPickerView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    ForEach(AnthologyCatalog.all, id: \.id) { meta in
                        storyRow(meta)
                    }
                    arenaRow
                    shopRow
                }
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.vertical, 20)
            }
            .background(pickerBackground.ignoresSafeArea())
            .navigationTitle("Story Adventures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.accent)
                }
            }
        }
    }

    private var pickerBackground: some View {
        LinearGradient(
            colors: [
                Theme.palette.backgroundGradientTop,
                Theme.palette.background,
                Theme.palette.backgroundGradientBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("\(vm.anthologyState.factionPoints) FP", systemImage: "star.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.accent)
                Spacer()
                if vm.anthologyState.alignment != .none {
                    Text(vm.anthologyState.alignment.rawValue.capitalized)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.parchment.opacity(0.75))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.12), in: Capsule())
                }
            }
            if vm.anthologyState.anthologyGold > 0 {
                Label("\(vm.anthologyState.anthologyGold) gold", systemImage: "circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.7))
            }
            if vm.anthologyState.ringPasses > 0 {
                Label("\(vm.anthologyState.ringPasses) passes", systemImage: "circle.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.7))
            }
            if let progress = AnthologyPathProgress.progressLabel(state: vm.anthologyState) {
                Text(progress)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(
                        AnthologyPathProgress.isActivePathComplete(state: vm.anthologyState)
                            ? Theme.accent : Theme.parchment.opacity(0.65)
                    )
            }
            Text("Spend faction points to unlock paths matching your Scout Patrol choice.")
                .font(.footnote)
                .foregroundColor(Theme.parchment.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private func storyRow(_ meta: AnthologyStoryMeta) -> some View {
        let state = vm.anthologyState
        let done = state.completedStories.contains(meta.id)
        let (allowed, reason) = AnthologyCatalog.canPlay(meta.id, state: state)
        let costLabel = meta.fpCost == 0 ? "Free" : "\(meta.fpCost) FP"

        return Button {
            vm.launchAnthologyStory(meta.id)
            dismiss()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: meta.systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(done ? Theme.accent : (allowed ? Theme.accent : Theme.parchment.opacity(0.35)))
                    .frame(width: 44, height: 44)
                    .background(Theme.accent.opacity(allowed || done ? 0.14 : 0.06), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(meta.title)
                            .font(.system(.headline, design: .serif).weight(.semibold))
                            .foregroundColor(Theme.parchment.opacity(allowed || done ? 1 : 0.45))
                        Spacer(minLength: 8)
                        if done {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Theme.accent)
                        } else {
                            Text(costLabel)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.accent.opacity(allowed ? 1 : 0.45))
                        }
                    }
                    Text(meta.subtitle)
                        .font(.subheadline)
                        .foregroundColor(Theme.parchment.opacity(allowed || done ? 0.72 : 0.4))
                        .fixedSize(horizontal: false, vertical: true)
                    if let reason, !allowed, !done {
                        Text(reason)
                            .font(.caption)
                            .foregroundColor(Theme.parchment.opacity(0.5))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.3))
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accent.opacity(allowed || done ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.palette.cardStroke.opacity(allowed || done ? 1 : 0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(!allowed && !done)
        .accessibilityLabel(meta.title)
        .accessibilityValue(done ? "Completed" : (allowed ? costLabel : "Locked"))
        .accessibilityHint(meta.subtitle)
        .accessibilityIdentifier("story-\(meta.id.rawValue)")
    }

    private var arenaRow: some View {
        let unlocked = vm.anthologyState.storyZeroComplete
        return Button {
            vm.launchArena()
            dismiss()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "figure.fencing")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(unlocked ? Theme.accent : Theme.parchment.opacity(0.35))
                    .frame(width: 44, height: 44)
                    .background(Theme.accent.opacity(unlocked ? 0.14 : 0.06), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(AnthologyCatalog.arenaTitle)
                            .font(.system(.headline, design: .serif).weight(.semibold))
                            .foregroundColor(Theme.parchment.opacity(unlocked ? 1 : 0.45))
                        Spacer()
                        Text("Free")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Theme.accent.opacity(unlocked ? 1 : 0.45))
                    }
                    Text(AnthologyCatalog.arenaSubtitle)
                        .font(.subheadline)
                        .foregroundColor(Theme.parchment.opacity(unlocked ? 0.72 : 0.4))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.3))
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accent.opacity(unlocked ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.palette.cardStroke.opacity(unlocked ? 1 : 0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(!unlocked)
        .accessibilityLabel(AnthologyCatalog.arenaTitle)
        .accessibilityHint(AnthologyCatalog.arenaSubtitle)
        .accessibilityValue(unlocked ? "Available" : "Locked")
        .accessibilityIdentifier("story-arena")
    }

    private var shopRow: some View {
        let unlocked = vm.anthologyState.storyZeroComplete
        return Button {
            vm.openTrainingShop()
            dismiss()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "bag.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(unlocked ? Theme.accent : Theme.parchment.opacity(0.35))
                    .frame(width: 44, height: 44)
                    .background(Theme.accent.opacity(unlocked ? 0.14 : 0.06), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(AnthologyCatalog.shopTitle)
                            .font(.system(.headline, design: .serif).weight(.semibold))
                            .foregroundColor(Theme.parchment.opacity(unlocked ? 1 : 0.45))
                        Spacer()
                        if vm.anthologyState.anthologyGold > 0 {
                            Text("\(vm.anthologyState.anthologyGold) gold")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.accent.opacity(unlocked ? 1 : 0.45))
                        }
                    }
                    Text(AnthologyCatalog.shopSubtitle)
                        .font(.subheadline)
                        .foregroundColor(Theme.parchment.opacity(unlocked ? 0.72 : 0.4))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.3))
                    .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.accent.opacity(unlocked ? 0.10 : 0.04), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.palette.cardStroke.opacity(unlocked ? 1 : 0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(!unlocked)
        .accessibilityLabel(AnthologyCatalog.shopTitle)
        .accessibilityHint(AnthologyCatalog.shopSubtitle)
        .accessibilityValue(unlocked ? "Available" : "Locked")
        .accessibilityIdentifier("story-shop")
    }
}
