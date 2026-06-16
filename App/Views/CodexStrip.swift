import SwiftUI

/// Horizontal strip of discovered journal tokens on the title screen.
struct CodexStrip: View {
    let entries: [JournalEntry]
    var onOpenJournal: () -> Void
    var onSelect: (JournalEntry) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Journal", systemImage: "book.closed.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.accent)
                Spacer()
                Button("See all", action: onOpenJournal)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.parchment.opacity(0.75))
                    .accessibilityLabel("See all journal entries")
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(entries) { entry in
                        Button { onSelect(entry) } label: {
                            VStack(spacing: 6) {
                                Image(systemName: entry.symbolName)
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(Theme.accent)
                                    .frame(width: 44, height: 44)
                                    .background(Theme.accent.opacity(0.12), in: Circle())
                                    .overlay(Circle().stroke(Theme.accent.opacity(0.45)))
                                Text(entry.title)
                                    .font(.caption2.weight(.medium))
                                    .foregroundColor(Theme.parchment.opacity(0.85))
                                    .lineLimit(1)
                                    .frame(width: 72)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(entry.title)
                        .accessibilityHint("Shows journal detail")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(14)
        .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Journal, \(entries.count) discoveries")
    }
}
