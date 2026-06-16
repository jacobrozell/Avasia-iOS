import SwiftUI
import AvasiaAnthologyEngine

/// Story selection sheet for anthology hub — replaces typing PLAY commands.
struct StoryPickerView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    @State private var pickerEntered = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    header
                    ForEach(Array(AnthologyCatalog.pickerSections.enumerated()), id: \.element.title) { index, section in
                        sectionBlock(section, index: index)
                    }
                    hubUtilitiesSection
                }
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.vertical, 20)
            }
            .background(pickerBackground.ignoresSafeArea())
            .navigationTitle("Story Adventures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticManager.shared.play(.tap)
                        dismiss()
                    }
                    .foregroundColor(Theme.accent)
                }
            }
            .onAppear {
                guard !pickerEntered else { return }
                if reduceMotion {
                    pickerEntered = true
                } else {
                    withAnimation(.easeOut(duration: 0.28)) {
                        pickerEntered = true
                    }
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
            Text("Spend faction points to unlock paths matching your Scout Patrol choice.")
                .font(.footnote)
                .foregroundColor(Theme.parchment.opacity(0.65))
            if vm.anthologyState.storyZeroComplete {
                Text("More Story Adventures arrive in future updates.")
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
        .opacity(pickerEntered ? 1 : (reduceMotion ? 1 : 0))
        .offset(y: pickerEntered || reduceMotion ? 0 : 8)
    }

    private func sectionBlock(_ section: AnthologyCatalog.PickerSection, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(section)
            ForEach(section.stories, id: \.id) { meta in
                storyRow(meta)
            }
        }
        .opacity(pickerEntered ? 1 : (reduceMotion ? 1 : 0))
        .offset(y: pickerEntered || reduceMotion ? 0 : 10)
        .animation(
            Motion.accessible(.easeOut(duration: 0.24), reduceMotion: reduceMotion)
                .delay(reduceMotion ? 0 : Double(index) * 0.04),
            value: pickerEntered
        )
    }

    private func sectionHeader(_ section: AnthologyCatalog.PickerSection) -> some View {
        HStack(spacing: 6) {
            Image(systemName: section.systemImage)
                .font(.caption.weight(.semibold))
            Text(section.title)
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .foregroundColor(Theme.parchment.opacity(0.45))
        .padding(.top, 4)
    }

    private var hubUtilitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(AnthologyCatalog.PickerSection(
                title: "Training",
                systemImage: "figure.fencing",
                stories: []
            ))
            arenaRow
            shopRow
        }
        .opacity(pickerEntered ? 1 : (reduceMotion ? 1 : 0))
    }

    private func storyRow(_ meta: AnthologyStoryMeta) -> some View {
        let state = vm.anthologyState
        let done = state.completedStories.contains(meta.id)
        let (allowed, reason) = AnthologyCatalog.canPlay(meta.id, state: state)
        let costLabel = meta.fpCost == 0 ? "Free" : "\(meta.fpCost) FP"
        let usesRingPass = allowed && !done && meta.fpCost > 0 && state.factionPoints < meta.fpCost
            && AnthologyRingPass.canSpendForStory(meta.id, state: state)
        let isActivePath = meta.requiredAlignment == state.alignment || meta.id == .storyZero

        return Button {
            HapticManager.shared.play(allowed || done ? .confirm : .tap)
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
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(meta.title)
                            .font(.system(.headline, design: .serif).weight(.semibold))
                            .foregroundColor(Theme.parchment.opacity(allowed || done ? 1 : 0.45))
                        Spacer(minLength: 4)
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
                    Text(meta.synopsis)
                        .font(.caption)
                        .foregroundColor(Theme.parchment.opacity(allowed || done ? 0.55 : 0.32))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                    if usesRingPass {
                        Text("Uses 1 ring pass")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(Theme.accent.opacity(0.75))
                    } else if let reason, !allowed, !done {
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
            .background(
                Theme.accent.opacity(allowed || done ? 0.10 : (isActivePath ? 0.06 : 0.04)),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Theme.palette.cardStroke.opacity(allowed || done ? 1 : (isActivePath ? 0.65 : 0.5)),
                        lineWidth: isActivePath && allowed ? 1.5 : 1
                    )
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
            HapticManager.shared.play(unlocked ? .confirm : .tap)
            vm.launchArena()
            dismiss()
        } label: {
            hubUtilityRow(
                icon: "figure.fencing",
                title: AnthologyCatalog.arenaTitle,
                subtitle: AnthologyCatalog.arenaSubtitle,
                trailing: "Free",
                unlocked: unlocked
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
        let trailing = vm.anthologyState.anthologyGold > 0
            ? "\(vm.anthologyState.anthologyGold) gold"
            : nil
        return Button {
            HapticManager.shared.play(unlocked ? .confirm : .tap)
            vm.openTrainingShop()
            dismiss()
        } label: {
            hubUtilityRow(
                icon: "bag.fill",
                title: AnthologyCatalog.shopTitle,
                subtitle: AnthologyCatalog.shopSubtitle,
                trailing: trailing,
                unlocked: unlocked
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(!unlocked)
        .accessibilityLabel(AnthologyCatalog.shopTitle)
        .accessibilityHint(AnthologyCatalog.shopSubtitle)
        .accessibilityValue(unlocked ? "Available" : "Locked")
        .accessibilityIdentifier("story-shop")
    }

    private func hubUtilityRow(
        icon: String,
        title: String,
        subtitle: String,
        trailing: String?,
        unlocked: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(unlocked ? Theme.accent : Theme.parchment.opacity(0.35))
                .frame(width: 44, height: 44)
                .background(Theme.accent.opacity(unlocked ? 0.14 : 0.06), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(.headline, design: .serif).weight(.semibold))
                        .foregroundColor(Theme.parchment.opacity(unlocked ? 1 : 0.45))
                    Spacer()
                    if let trailing {
                        Text(trailing)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Theme.accent.opacity(unlocked ? 1 : 0.45))
                    }
                }
                Text(subtitle)
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
}
