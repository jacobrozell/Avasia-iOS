import SwiftUI
import AvasiaEngine

/// Full Chronicler XP history — lifetime, this run, and pending achievement claims.
struct ChroniclerLedgerView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @State private var filter: LedgerFilter = .all

    enum LedgerFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case thisRun = "This run"
        case kon = "KoN"
        case soc = "SoC"
        case stories = "Stories"

        var id: String { rawValue }
    }

    private var profile: SagaProfile { vm.sagaProfile }

    private var filteredEntries: [SagaXPEntry] {
        let ledger = profile.ledger.reversed()
        switch filter {
        case .all: return Array(ledger)
        case .thisRun:
            guard let runID = profile.currentRunID else { return [] }
            return ledger.filter { $0.runID == runID }
        case .kon: return ledger.filter { $0.product == .kon }
        case .soc: return ledger.filter { $0.product == .soc }
        case .stories: return ledger.filter { $0.product == .stories }
        }
    }

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            CatalogScreenChrome(backTitle: "Back", onBack: { vm.screen = vm.chroniclerReturn }) {
                header
            } accessory: {
                VStack(spacing: 0) {
                    filterPicker
                    if !vm.chroniclerPendingClaims.isEmpty {
                        pendingClaims
                    }
                }
            } content: {
                ledgerList
            }
        }
    }

    private var ledgerList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if filteredEntries.isEmpty {
                    Text(emptyMessage)
                        .font(.subheadline)
                        .foregroundColor(Theme.parchment.opacity(0.55))
                        .padding(.top, 24)
                        .accessibilityAddTraits(.isStaticText)
                } else {
                    ForEach(filteredEntries) { entry in
                        ledgerRow(entry)
                    }
                }
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.bottom, 8)
            .frame(maxWidth: metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .thisRun: return "No Chronicler XP this run yet."
        default: return "Your ledger is empty. Play to earn Chronicler XP."
        }
    }

    private var header: some View {
        let rank = profile.chroniclerRank
        let progress = ChroniclerRank.progressToNextRank(from: profile.sagaXP)
        return VStack(spacing: metrics.isLandscape ? 4 : 8) {
            Text("The Chronicler's Ledger")
                .font(.system(metrics.isLandscape ? .title : .largeTitle, design: .serif).bold())
                .foregroundColor(Theme.accent)
                .accessibilityAddTraits(.isHeader)
            Text("Chronicler · Rank \(rank)")
                .font(.headline)
                .foregroundColor(Theme.parchment)
            if !metrics.isLandscape {
                Text(profile.chroniclerSubtitle)
                    .font(.subheadline)
                    .foregroundColor(Theme.parchment.opacity(0.7))
            }
            Text("\(profile.sagaXP) XP · \(ChroniclerRank.xpToNextRank(from: profile.sagaXP)) to next rank")
                .font(.caption)
                .foregroundColor(Theme.parchment.opacity(0.55))
            ProgressBar(value: progress)
                .padding(.horizontal, 8)
            HStack(spacing: 12) {
                statPill("KoN", count: profile.completionsKon)
                statPill("SoC", count: profile.completionsSoc)
                statPill("Stories", count: profile.completionsStories)
            }
            .font(.caption2)
            .padding(.top, 4)
        }
        .padding(.top, metrics.menuHeaderTopPadding)
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, metrics.menuHeaderBottomPadding)
        .frame(maxWidth: metrics.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Chronicler ledger, rank \(rank), \(profile.sagaXP) experience")
    }

    private func statPill(_ label: String, count: Int) -> some View {
        Text("\(label) \(count)×")
            .foregroundColor(Theme.parchment.opacity(0.65))
            .accessibilityLabel("\(label), \(count) completions")
    }

    private var filterPicker: some View {
        Group {
            if metrics.isLandscape || metrics.isAccessibilityText {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 88, maximum: 120), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(LedgerFilter.allCases) { item in
                        filterButton(item)
                    }
                }
                .padding(.horizontal, metrics.horizontalPadding)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(LedgerFilter.allCases) { item in
                            filterButton(item)
                        }
                    }
                    .padding(.horizontal, metrics.horizontalPadding)
                }
            }
        }
        .padding(.bottom, 8)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Ledger filter")
    }

    private func filterButton(_ item: LedgerFilter) -> some View {
        Button {
            filter = item
        } label: {
            Text(item.rawValue)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .frame(maxWidth: .infinity)
                .background(
                    filter == item ? Theme.accent.opacity(0.25) : Theme.palette.cardFill,
                    in: Capsule()
                )
                .foregroundColor(filter == item ? Theme.accent : Theme.parchment.opacity(0.75))
        }
        .accessibilityLabel(item.rawValue)
        .accessibilityAddTraits(filter == item ? .isSelected : [])
    }

    private var pendingClaims: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pending claims")
                .font(.caption.weight(.semibold))
                .foregroundColor(Theme.parchment.opacity(0.6))
                .accessibilityAddTraits(.isHeader)
            ForEach(vm.chroniclerPendingClaims, id: \.self) { ach in
                HStack {
                    Text(ach.title)
                        .font(.subheadline)
                        .foregroundColor(Theme.parchment)
                    Spacer()
                    Button("Claim +\(SagaXPTracker.xpForAchievement(ach))") {
                        vm.claimChroniclerAchievement(ach)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.accent)
                    .accessibilityLabel("Claim \(SagaXPTracker.xpForAchievement(ach)) experience for \(ach.title)")
                }
                .padding(10)
                .background(Theme.palette.cardFill, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityElement(children: .contain)
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, 8)
        .frame(maxWidth: metrics.contentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    private func ledgerRow(_ entry: SagaXPEntry) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(entry.amount > 0 ? "+\(entry.amount)" : "—")
                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                .foregroundColor(entry.amount > 0 ? Theme.accent : Theme.parchment.opacity(0.4))
                .frame(width: 44, alignment: .trailing)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.label)
                    .font(.subheadline)
                    .foregroundColor(Theme.parchment)
                    .fixedSize(horizontal: false, vertical: true)
                if let note = entry.modifierNote {
                    Text(note)
                        .font(.caption2)
                        .foregroundColor(Theme.parchment.opacity(0.5))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Theme.palette.cardFill, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ledgerAccessibilityLabel(entry))
    }

    private func ledgerAccessibilityLabel(_ entry: SagaXPEntry) -> String {
        let amount = entry.amount > 0 ? "plus \(entry.amount) experience" : "no experience change"
        if let note = entry.modifierNote {
            return "\(entry.label), \(amount), \(note)"
        }
        return "\(entry.label), \(amount)"
    }
}
