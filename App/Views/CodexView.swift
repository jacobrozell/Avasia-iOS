import SwiftUI

/// Browsable journal of met characters and cleared story beats.
struct CodexView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @State private var category: JournalCategory = .character
    @State private var selected: JournalEntry?
    @State private var selectedTimeline: SagaTimelineEvent?

    private var entries: [JournalEntry] {
        JournalCatalog.entries(
            for: vm.product,
            category: category,
            kon: vm.konCodexState,
            soc: vm.socCodexState
        )
    }

    private var timelineEvents: [SagaTimelineEvent] {
        JournalCatalog.timelineEvents(
            for: vm.product,
            kon: vm.konCodexState,
            soc: vm.socCodexState,
            anthology: vm.sagaAnthologySave
        )
    }

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            CatalogScreenChrome(backTitle: "Back", onBack: { vm.screen = vm.codexReturn }) {
                header
            } accessory: {
                categoryPicker
            } content: {
                if category == .timeline {
                    timelineList
                } else {
                    entryGrid
                }
            }
        }
        .sheet(item: $selected) { entry in
            CodexDetailSheet(entry: entry)
        }
        .sheet(item: $selectedTimeline) { event in
            SagaTimelineDetailSheet(event: event)
        }
    }

    private var entryGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(
                            minimum: metrics.catalogGridMinimum,
                            maximum: metrics.catalogGridMaximum
                        ),
                        spacing: 12
                    )
                ],
                spacing: 12
            ) {
                ForEach(entries) { entry in
                    token(entry)
                }
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.bottom, 8)
            .frame(maxWidth: metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
    }

    private var timelineList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(Array(timelineEvents.enumerated()), id: \.element.id) { index, event in
                    TimelineEventRow(
                        event: event,
                        isLast: index == timelineEvents.count - 1,
                        onSelect: { selectedTimeline = event }
                    )
                }
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.bottom, 8)
            .frame(maxWidth: metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
    }

    private var header: some View {
        let unlocked = JournalCatalog.unlockedCount(
            for: vm.product,
            kon: vm.konCodexState,
            soc: vm.socCodexState
        )
        let total = JournalCatalog.totalCount(for: vm.product)
        let progress = total > 0 ? Double(unlocked) / Double(total) : 0
        return VStack(spacing: metrics.isLandscape ? 4 : 8) {
            Text("Journal")
                .font(.system(metrics.isLandscape ? .title : .largeTitle, design: .serif).bold())
                .foregroundColor(Theme.accent)
                .accessibilityAddTraits(.isHeader)
            Text("\(unlocked) / \(total) discovered")
                .font(.callout)
                .foregroundColor(Theme.parchment.opacity(0.6))
            ProgressBar(value: progress)
                .padding(.horizontal, 8)
        }
        .padding(.top, metrics.menuHeaderTopPadding)
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, metrics.menuHeaderBottomPadding)
        .frame(maxWidth: metrics.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Journal, \(unlocked) of \(total) discovered")
    }

    private var categoryPicker: some View {
        Picker("Category", selection: $category) {
            ForEach(availableCategories) { cat in
                Text(cat.title).tag(cat)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, metrics.isLandscape ? 8 : 12)
        .frame(maxWidth: metrics.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("Journal category")
    }

    private var availableCategories: [JournalCategory] {
        switch vm.product {
        case .kon, .soc: return JournalCategory.allCases
        case .stories: return [.character, .storyBeat]
        }
    }

    private func token(_ entry: JournalEntry) -> some View {
        Button {
            selected = entry
        } label: {
            VStack(spacing: 8) {
                Image(systemName: entry.unlocked ? entry.symbolName : "questionmark")
                    .font(.title2)
                    .foregroundColor(entry.unlocked ? Theme.accent : Theme.parchment.opacity(0.35))
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(entry.unlocked ? Theme.accent.opacity(0.15) : Theme.palette.cardFill)
                    )
                    .overlay(
                        Circle()
                            .stroke(entry.unlocked ? Theme.accent.opacity(0.5) : Theme.palette.cardStroke.opacity(0.5))
                    )
                Text(entry.unlocked ? entry.title : "???")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(entry.unlocked ? Theme.parchment : Theme.parchment.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.unlocked ? entry.title : "Undiscovered entry")
        .accessibilityHint(entry.unlocked ? "Shows journal detail" : entry.lockedHint)
    }
}
