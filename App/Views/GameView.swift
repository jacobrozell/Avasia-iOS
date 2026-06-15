import SwiftUI
import AvasiaEngine

/// The main play screen: scrolling transcript, an input bar, quick-action chips,
/// and a status strip showing spells/items and the death counter. Mirrors the
/// wireframe in docs/WIREFRAMES.md.
struct GameView: View {
    @EnvironmentObject var vm: GameViewModel
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            Theme.night.ignoresSafeArea()
            VStack(spacing: 0) {
                statusStrip
                Divider().background(Theme.accent.opacity(0.4))
                transcript
                quickActions
                inputBar
            }
        }
        .overlay { if vm.pendingDeath { deathOverlay } }
    }

    private var statusStrip: some View {
        HStack {
            Button { vm.screen = .title } label: {
                Image(systemName: "list.bullet").foregroundColor(Theme.accent)
            }
            Spacer()
            ForEach(vm.state.spells, id: \.self) { spell in
                Label(spell.displayName, systemImage: "sparkles")
                    .font(.caption2).foregroundColor(Theme.accent)
            }
            ForEach(vm.state.items, id: \.self) { item in
                Image(systemName: icon(for: item)).foregroundColor(Theme.parchment)
            }
            Spacer()
            Text("☠ \(vm.state.deathCount)")
                .font(.caption2).foregroundColor(Theme.parchment.opacity(0.6))
        }
        .padding(.horizontal).padding(.vertical, 8)
    }

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(vm.transcript.enumerated()), id: \.offset) { idx, line in
                        LineView(line: line).id(idx)
                    }
                }
                .padding()
            }
            .onChange(of: vm.transcript.count) { _ in
                if let last = vm.transcript.indices.last {
                    withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                }
            }
        }
    }

    private var quickActions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["North", "East", "South", "West", "Look", "Talk", "Take"], id: \.self) { verb in
                    Button(verb) { vm.quickAction(verb) }
                        .font(.caption)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.12))
                        .clipShape(Capsule())
                        .foregroundColor(Theme.parchment)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 6)
    }

    private var inputBar: some View {
        HStack {
            TextField("What do you do?", text: $vm.input)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($inputFocused)
                .submitLabel(.send)
                .onSubmit { vm.submit() }
                .padding(10)
                .background(Theme.parchment.opacity(0.08))
                .cornerRadius(8)
                .foregroundColor(Theme.parchment)
            Button { vm.submit() } label: {
                Image(systemName: "arrow.up.circle.fill").font(.title2).foregroundColor(Theme.accent)
            }
        }
        .padding()
    }

    private var deathOverlay: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 18) {
                Text("You have died.")
                    .font(.system(.largeTitle, design: .serif).bold())
                    .foregroundColor(.red)
                MenuButton(title: "Restart from checkpoint") { vm.restartFromCheckpoint() }
                MenuButton(title: "New game") { vm.restartFromBeginning() }
            }
            .padding()
        }
    }

    private func icon(for item: Flag) -> String {
        switch item {
        case .sword: return "scribble"
        case .lantern: return "lantern.fill"
        case .dagger: return "scissors"
        case .rod: return "figure.fishing"
        default: return "bag"
        }
    }
}
