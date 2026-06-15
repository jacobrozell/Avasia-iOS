import SwiftUI
import AvasiaEngine

struct SettingsView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("Settings")
                        .font(.system(.largeTitle, design: .serif).bold())
                        .foregroundColor(Theme.accent)
                        .accessibilityAddTraits(.isHeader)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Text pacing")
                            .font(.headline).foregroundColor(Theme.parchment)
                        Text("Delay between sentences. On is strongly recommended for first time players.")
                            .font(.caption).foregroundColor(Theme.parchment.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
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

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle(isOn: Binding(
                            get: { vm.soundEnabled },
                            set: { vm.soundEnabled = $0 }
                        )) {
                            Text("Sound & music")
                                .font(.headline).foregroundColor(Theme.parchment)
                        }
                        .tint(Theme.accent)
                        Text("Ambient loops and effects. (Audio assets are optional — see docs/ASSETS.md.)")
                            .font(.caption).foregroundColor(Theme.parchment.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.accent.opacity(0.4)))

                    MenuButton(title: "Back") { vm.screen = vm.menuReturn }
                        .padding(.top, 8)
                }
                .frame(maxWidth: metrics.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.vertical, 16)
            }
        }
    }
}
