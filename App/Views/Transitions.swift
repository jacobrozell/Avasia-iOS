import SwiftUI

/// Per-screen enter transitions for `RootView` (`docs/UI_POLISH.md` §2).
enum ScreenTransition {
    static func transition(for screen: GameViewModel.Screen, reduceMotion: Bool) -> AnyTransition {
        switch screen {
        case .saga, .title:
            return hubEnter(reduceMotion: reduceMotion)
        case .game:
            return playEnter(reduceMotion: reduceMotion)
        case .settings, .credits, .privacyPolicy, .achievements, .trophies, .codex, .timeline, .chroniclerLedger:
            return stackEnter(reduceMotion: reduceMotion)
        }
    }

    static func hubEnter(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 12)),
            removal: .opacity
        )
    }

    static func stackEnter(reduceMotion: Bool) -> AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        )
    }

    static func playEnter(reduceMotion: Bool) -> AnyTransition {
        .opacity
    }
}

/// Illustration band + transcript fade when entering play (`GameView`).
struct PlayScreenEnter: ViewModifier {
    @Binding var entered: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(entered ? 1 : (reduceMotion ? 1 : 0))
            .onAppear {
                guard !entered else { return }
                if reduceMotion {
                    entered = true
                } else {
                    withAnimation(.easeOut(duration: 0.28)) {
                        entered = true
                    }
                }
            }
    }
}

extension View {
    func playScreenEnter(_ entered: Binding<Bool>) -> some View {
        modifier(PlayScreenEnter(entered: entered))
    }
}

/// Subtle reveal when a transcript line finishes typing (`docs/UI_POLISH.md` §4.1).
struct TranscriptLineReveal: ViewModifier {
    let playReveal: Bool
    let isHint: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false

    func body(content: Content) -> some View {
        content
            .opacity(revealed ? 1 : (shouldAnimate ? 0.55 : 1))
            .offset(y: revealed || isHint || !shouldAnimate ? 0 : 4)
            .onAppear { triggerReveal() }
            .onChange(of: playReveal) { _ in triggerReveal() }
    }

    private var shouldAnimate: Bool {
        playReveal && !reduceMotion
    }

    private func triggerReveal() {
        guard shouldAnimate else {
            revealed = true
            return
        }
        revealed = false
        withAnimation(.easeOut(duration: 0.18)) {
            revealed = true
        }
    }
}

extension View {
    func transcriptLineReveal(playReveal: Bool, isHint: Bool) -> some View {
        modifier(TranscriptLineReveal(playReveal: playReveal, isHint: isHint))
    }
}
