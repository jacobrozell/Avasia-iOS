import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.system(.largeTitle, design: .serif).bold())
                        .foregroundColor(Theme.accent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityAddTraits(.isHeader)

                    policySection(
                        title: "Overview",
                        body: """
                        Avasia is an offline text adventure. We designed it to work without an account, \
                        analytics SDK, or ad network.
                        """
                    )

                    policySection(
                        title: "Data stored on your device",
                        body: """
                        The app saves game progress, achievements, trophies, Chronicler rank and XP ledger, \
                        and settings locally on your \
                        iPhone or iPad using standard iOS storage. This data is not transmitted to us.
                        """
                    )

                    policySection(
                        title: "Network use",
                        body: """
                        Gameplay does not require the internet. If you tap Support links (such as Buy Me a \
                        Coffee), your browser opens that third-party site under their privacy terms.
                        """
                    )

                    policySection(
                        title: "Contact",
                        body: """
                        Questions about this policy can be sent to the developers listed in Credits.
                        """
                    )

                    Text("Last updated: June 2026")
                        .font(.caption)
                        .foregroundColor(Theme.parchment.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)

                    MenuButton(title: "Back", systemImage: "chevron.backward", accessibilityIdentifier: "privacy-back") {
                        vm.screen = vm.privacyReturn
                    }
                        .padding(.top, 8)
                }
                .frame(maxWidth: metrics.contentMaxWidth)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.vertical, 16)
            }
        }
    }

    private func policySection(title: String, body: String) -> some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.accent)
                Text(body)
                    .font(.body)
                    .foregroundColor(Theme.parchment.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
