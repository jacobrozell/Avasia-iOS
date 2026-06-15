import SwiftUI
import AvasiaEngine

struct SettingsView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.system(.largeTitle, design: .serif).bold())
                        .foregroundColor(Theme.accent)
                        .accessibilityAddTraits(.isHeader)

                    appearanceSection
                    soundSection
                    supportLegalSection
                    pacingSection
                    speedSection
                    cursorSection

                    MenuButton(title: "Back", accessibilityIdentifier: "settings-back") {
                        vm.screen = vm.menuReturn
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: metrics.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, metrics.horizontalPadding)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
        .onAppear { vm.refreshThemePalette() }
    }

    private var appearanceSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Appearance")
                    .font(.headline)
                    .foregroundColor(Theme.parchment)
                Text("Light mode uses ink-on-parchment colors. System follows your device.")
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
                Picker("Appearance", selection: $vm.appearance) {
                    ForEach(AppAppearance.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("settings-appearance")
            }
        }
    }

    private var pacingSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Text pacing")
                    .font(.headline)
                    .foregroundColor(Theme.parchment)
                Text("On types each line in gradually. Tap the transcript to skip ahead.")
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
                Picker("Text pacing", selection: Binding(
                    get: { vm.textDelay },
                    set: { vm.textDelay = $0 }
                )) {
                    Text("On").tag(TextDelay.on)
                    Text("Off").tag(TextDelay.off)
                    Text("Tap").tag(TextDelay.tapToAdvance)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var speedSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Typewriter speed")
                    .font(.headline)
                    .foregroundColor(Theme.parchment)
                Picker("Typewriter speed", selection: $vm.typewriterSpeed) {
                    ForEach(TypewriterSpeed.allCases) { speed in
                        Text(speed.label).tag(speed)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var cursorSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Cursor style")
                    .font(.headline)
                    .foregroundColor(Theme.parchment)
                Picker("Cursor style", selection: $vm.cursorStyle) {
                    ForEach(CursorStyle.allCases) { style in
                        Text(style.label).tag(style)
                    }
                }
                .pickerStyle(.menu)
                cursorPreview
            }
        }
    }

    private var cursorPreview: some View {
        HStack(spacing: 0) {
            Text("The druid walks forward")
                .font(.system(.body, design: .serif))
                .foregroundColor(Theme.parchment.opacity(0.85))
            if let glyph = vm.cursorStyle.glyph {
                Text(glyph)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Theme.accent)
            }
        }
        .padding(.top, 4)
    }

    private var soundSection: some View {
        SettingsCard {
            Toggle(isOn: Binding(
                get: { vm.soundEnabled },
                set: { vm.soundEnabled = $0 }
            )) {
                Text("Sound & music")
                    .font(.headline)
                    .foregroundColor(Theme.parchment)
            }
            .tint(Theme.accent)
        }
    }

    private var supportLegalSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Support & legal")
                    .font(.headline)
                    .foregroundColor(Theme.parchment)
                SettingsLinkRow(
                    title: "Buy Me a Coffee",
                    systemImage: "cup.and.saucer.fill",
                    url: AppLinks.buyMeACoffee
                )
                .accessibilityIdentifier("settings-buymeacoffee")
                Divider().overlay(Theme.palette.cardStroke)
                MenuButton(
                    title: "Privacy Policy",
                    systemImage: "hand.raised.fill",
                    accessibilityIdentifier: "settings-privacy"
                ) {
                    vm.openPrivacyPolicy(from: .settings)
                }
            }
        }
    }
}
