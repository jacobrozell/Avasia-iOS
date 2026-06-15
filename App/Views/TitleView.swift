import SwiftUI

struct TitleView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                Text("AVASIA")
                    .font(.system(size: 52, weight: .heavy, design: .serif))
                    .foregroundColor(Theme.accent)
                Text("King of Nacastrum")
                    .font(.system(.title3, design: .serif).italic())
                    .foregroundColor(Theme.parchment)

                Spacer()

                VStack(spacing: 14) {
                    MenuButton(title: "New Game") { vm.startNewGame() }
                    if vm.hasSave {
                        MenuButton(title: "Continue") { vm.continueGame() }
                    }
                    MenuButton(title: "Settings") { vm.screen = .settings }
                    MenuButton(title: "Credits") { vm.screen = .credits }
                }
                Spacer()
                Text("On is strongly recommended for first time players.")
                    .font(.footnote)
                    .foregroundColor(Theme.parchment.opacity(0.4))
            }
            .padding()
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title3, design: .serif))
                .frame(maxWidth: 280)
                .padding(.vertical, 12)
                .background(Theme.accent.opacity(0.15))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.accent, lineWidth: 1))
                .foregroundColor(Theme.parchment)
        }
    }
}
