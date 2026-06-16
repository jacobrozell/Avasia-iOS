import SwiftUI

/// Chronological Age-era saga timeline — merges KoN, gap anthology beats, and SoC.
struct SagaTimelineView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @State private var selected: SagaTimelineEvent?

    private var events: [SagaTimelineEvent] {
        SagaTimelineCatalog.allEvents(
            kon: vm.sagaKonSave,
            soc: vm.sagaSocSave,
            anthology: vm.sagaAnthologySave
        )
    }

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                            if shouldShowEraHeader(at: index) {
                                eraHeader(event.era)
                            }
                            TimelineEventRow(
                                event: event,
                                isLast: index == events.count - 1,
                                onSelect: { selected = event }
                            )
                        }
                    }
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 8)
                    .frame(maxWidth: metrics.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                }
                MenuButton(title: "Back") { vm.screen = vm.timelineReturn }
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 12)
            }
        }
        .sheet(item: $selected) { event in
            SagaTimelineDetailSheet(event: event)
        }
    }

    private var header: some View {
        let unlocked = SagaTimelineCatalog.unlockedCount(
            kon: vm.sagaKonSave,
            soc: vm.sagaSocSave,
            anthology: vm.sagaAnthologySave
        )
        let total = SagaTimelineCatalog.totalCount
        let progress = total > 0 ? Double(unlocked) / Double(total) : 0
        return VStack(spacing: 8) {
            Text("Saga Timeline")
                .font(.system(.largeTitle, design: .serif).bold())
                .foregroundColor(Theme.accent)
                .accessibilityAddTraits(.isHeader)
            Text("\(unlocked) / \(total) eras discovered")
                .font(.callout)
                .foregroundColor(Theme.parchment.opacity(0.6))
            ProgressBar(value: progress)
                .padding(.horizontal, 8)
        }
        .padding(.top, 24)
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, 8)
    }

    private func shouldShowEraHeader(at index: Int) -> Bool {
        guard index < events.count else { return false }
        if index == 0 { return true }
        return events[index].era != events[index - 1].era
    }

    private func eraHeader(_ era: SagaEra) -> some View {
        HStack {
            Text(era.title)
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundColor(Theme.parchment.opacity(0.75))
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 2)
    }
}
