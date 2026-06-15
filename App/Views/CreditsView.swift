import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                Text("Avasia: King of Nacastrum")
                    .font(.system(.title, design: .serif).bold())
                    .foregroundColor(Theme.accent)
                Text("Original game by Jacob Rozell")
                    .foregroundColor(Theme.parchment)
                Text("with Chase Pernatozzi, Devan Deloach, and Joshua Rogers")
                    .font(.callout)
                    .foregroundColor(Theme.parchment.opacity(0.7))
                    .multilineTextAlignment(.center)
                Text("iOS remake")
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.5))
                Spacer()
                MenuButton(title: "Back") { vm.screen = .title }
                Spacer()
            }
            .padding()
        }
    }
}
