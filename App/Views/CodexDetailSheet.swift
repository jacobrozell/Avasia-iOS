import SwiftUI

struct CodexDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Image(systemName: entry.unlocked ? entry.symbolName : "questionmark")
                            .font(.largeTitle)
                            .foregroundColor(entry.unlocked ? Theme.accent : Theme.parchment.opacity(0.4))
                        Text(entry.unlocked ? entry.title : "Undiscovered")
                            .font(.system(.title2, design: .serif).bold())
                            .foregroundColor(Theme.parchment)
                    }
                    Text(entry.unlocked ? entry.summary : entry.lockedHint)
                        .font(.body)
                        .foregroundColor(Theme.parchment.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Theme.night.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
