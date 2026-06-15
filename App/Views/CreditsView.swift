import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics

    private let developers = [
        "CO-LEAD DEV: Jacob Rozell",
        "CO-LEAD DEV: Chase Pernatozzi",
        "DEV: Devan Deloach",
        "DEV: Joshua Rogers"
    ]
    private let testers = [
        "Megan Haskins", "Jeremiah Rhodes", "Anna Ferguson",
        "Derek Powell", "Jack Powell", "Nathan Brooks"
    ]

    var body: some View {
        ZStack {
            TitleScreenBackground()
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("AVASIA")
                            .font(.system(.title, design: .serif).weight(.heavy))
                            .tracking(4)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.accent.opacity(0.75)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .accessibilityAddTraits(.isHeader)
                        Text("King of Nacastrum  ·  Blade of Courage")
                            .font(.system(.subheadline, design: .serif).italic())
                            .foregroundColor(Theme.parchment.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    TitleOrnament()

                    Text("~-CREDITS-~")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Theme.parchment)

                    section("DEVELOPERS", developers)
                    section("BETA TESTERS", testers)

                    Text("Special thanks to our friends and family for their love & support.")
                        .font(.callout)
                        .foregroundColor(Theme.parchment.opacity(0.7))
                        .multilineTextAlignment(.center)

                    Text("iOS remake")
                        .font(.caption)
                        .foregroundColor(Theme.parchment.opacity(0.5))

                    MenuButton(title: "Back") { vm.screen = vm.menuReturn }
                        .padding(.top, 12)
                }
                .frame(maxWidth: metrics.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.bottom, 16)
            }
        }
    }

    private func section(_ title: String, _ lines: [String]) -> some View {
        VStack(spacing: 6) {
            Text("-\(title)-")
                .font(.system(.subheadline, design: .serif).bold())
                .foregroundColor(Theme.accent)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.callout)
                    .foregroundColor(Theme.parchment)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
}
