import SwiftUI

struct CodexDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry

    var body: some View {
        LayoutMetricsReader { metrics in
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 14) {
                            Image(systemName: entry.unlocked ? entry.symbolName : "questionmark")
                                .font(.largeTitle)
                                .foregroundColor(entry.unlocked ? Theme.accent : Theme.parchment.opacity(0.4))
                                .accessibilityHidden(true)
                            Text(entry.unlocked ? entry.title : "Undiscovered")
                                .font(.system(.title2, design: .serif).bold())
                                .foregroundColor(Theme.parchment)
                                .accessibilityAddTraits(.isHeader)
                        }
                        Text(entry.unlocked ? entry.summary : entry.lockedHint)
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
            .accessibilityLabel(entry.unlocked ? entry.title : "Undiscovered journal entry")
        }
    }
}
