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
            RegionBackground(media: vm.media)
            VStack(spacing: 0) {
                RegionIllustration(media: vm.media)
                statusStrip
                Divider().background(Theme.accent.opacity(0.4))
                transcript
                quickActions
                inputBar
            }
        }
        .overlay(alignment: .top) { achievementToasts }
        .overlay { if vm.pendingDeath { deathOverlay } }
    }

    private var statusStrip: some View {
        HStack(spacing: 14) {
            Button { vm.screen = .title } label: {
                Image(systemName: "list.bullet").foregroundColor(Theme.accent)
            }
            Button { vm.openAchievements(from: .game) } label: {
                Image(systemName: "trophy").foregroundColor(Theme.accent)
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
                ForEach(["North", "East", "South", "West", "Up", "Down", "Left", "Right", "Look", "Talk", "Take", "Continue"], id: \.self) { verb in
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

    // MARK: - Death overlay

    private var deathOverlay: some View {
        let death = vm.lastDeath
        return ZStack {
            RadialGradient(colors: [Color(red: 0.2, green: 0, blue: 0).opacity(0.85), .black.opacity(0.95)],
                           center: .center, startRadius: 40, endRadius: 600)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "skull")
                    .font(.system(size: 44))
                    .foregroundColor(.red.opacity(0.9))
                Text(death?.cause.title ?? "You Have Died")
                    .font(.system(.largeTitle, design: .serif).bold())
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                if let epitaph = death?.cause.epitaph {
                    Text(epitaph)
                        .font(.system(.body, design: .serif).italic())
                        .foregroundColor(Theme.parchment.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Text("You have died.  ·  Death #\(death?.number ?? vm.state.deathCount)")
                    .font(.caption)
                    .foregroundColor(Theme.parchment.opacity(0.5))
                VStack(spacing: 12) {
                    MenuButton(title: "Restart from checkpoint") { vm.restartFromCheckpoint() }
                    MenuButton(title: "New game") { vm.restartFromBeginning() }
                }
                .padding(.top, 8)
            }
            .padding(28)
        }
        .transition(.opacity)
    }

    // MARK: - Achievement toasts

    private var achievementToasts: some View {
        VStack(spacing: 8) {
            ForEach(vm.recentlyUnlocked, id: \.self) { ach in
                HStack(spacing: 10) {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked")
                            .font(.caption2).foregroundColor(Theme.parchment.opacity(0.6))
                        Text(ach.title)
                            .font(.system(.subheadline, design: .serif).bold())
                            .foregroundColor(Theme.parchment)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.accent.opacity(0.4)))
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.top, 6)
        .animation(.spring(response: 0.4), value: vm.recentlyUnlocked)
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
