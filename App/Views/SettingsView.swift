import SwiftUI
import AvasiaEngine

struct SettingsView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Settings")
                    .font(.system(.largeTitle, design: .serif).bold())
                    .foregroundColor(Theme.accent)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Text pacing")
                        .font(.headline).foregroundColor(Theme.parchment)
                    Text("Delay between sentences. On is strongly recommended for first time players.")
                        .font(.caption).foregroundColor(Theme.parchment.opacity(0.6))
                    Picker("Text pacing", selection: Binding(
                        get: { vm.textDelay },
                        set: { vm.textDelay = $0 }
                    )) {
                        Text("On").tag(TextDelay.on)
                        Text("Off").tag(TextDelay.off)
                        Text("Tap to advance").tag(TextDelay.tapToAdvance)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.accent.opacity(0.4)))

                Spacer()
                MenuButton(title: "Back") { vm.screen = .title }
            }
            .padding()
        }
    }
}
