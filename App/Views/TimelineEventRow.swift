import SwiftUI

struct TimelineEventRow: View {
    let event: SagaTimelineEvent
    let isLast: Bool
    var onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 14) {
                timelineRail
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(event.dateLabel)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(Theme.accent.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Theme.accent.opacity(0.12), in: Capsule())
                        if !event.unlocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundColor(Theme.parchment.opacity(0.35))
                        }
                    }
                    Text(event.unlocked ? event.title : "???")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(event.unlocked ? Theme.parchment : Theme.parchment.opacity(0.55))
                        .multilineTextAlignment(.leading)
                    if event.unlocked {
                        Text(event.summary)
                            .font(.caption)
                            .foregroundColor(Theme.parchment.opacity(0.55))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(event.unlocked ? Theme.accent.opacity(0.1) : Theme.palette.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(event.unlocked ? Theme.accent.opacity(0.4) : Theme.palette.cardStroke.opacity(0.45))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(event.unlocked ? event.title : "Locked timeline event")
        .accessibilityValue(event.dateLabel)
        .accessibilityHint(event.unlocked ? "Shows timeline detail" : event.lockedHint)
    }

    private var timelineRail: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(event.unlocked ? Theme.accent.opacity(0.2) : Theme.palette.cardFill)
                    .frame(width: 36, height: 36)
                Image(systemName: event.unlocked ? event.symbolName : "questionmark")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(event.unlocked ? Theme.accent : Theme.parchment.opacity(0.35))
            }
            if !isLast {
                Rectangle()
                    .fill(Theme.accent.opacity(0.25))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, 4)
            }
        }
        .frame(width: 36)
        .accessibilityHidden(true)
    }
}

struct SagaTimelineDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let event: SagaTimelineEvent

    var body: some View {
        LayoutMetricsReader { metrics in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(event.dateLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Theme.accent)
                        HStack(spacing: 14) {
                            Image(systemName: event.unlocked ? event.symbolName : "questionmark")
                                .font(.largeTitle)
                                .foregroundColor(event.unlocked ? Theme.accent : Theme.parchment.opacity(0.4))
                                .accessibilityHidden(true)
                            Text(event.unlocked ? event.title : "Undiscovered")
                                .font(.system(.title2, design: .serif).bold())
                                .foregroundColor(Theme.parchment)
                                .accessibilityAddTraits(.isHeader)
                        }
                        Text(event.era.title)
                            .font(.subheadline)
                            .foregroundColor(Theme.parchment.opacity(0.6))
                        Text(event.unlocked ? event.summary : event.lockedHint)
                            .font(.body)
                            .foregroundColor(Theme.parchment.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(24)
                    .frame(maxWidth: metrics.contentMaxWidth)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Theme.night.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .accessibilityLabel("Done")
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .accessibilityElement(children: .contain)
            .accessibilityLabel(event.unlocked ? event.title : "Undiscovered timeline event")
        }
    }
}
