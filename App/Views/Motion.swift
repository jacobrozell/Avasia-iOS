import SwiftUI

/// Shared motion helpers — respects Reduce Motion per `docs/UI_POLISH.md`.
enum Motion {
    static func accessible(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.15) : animation
    }

    static func regionBackground(reduceMotion: Bool) -> Animation {
        accessible(.easeInOut(duration: 0.4), reduceMotion: reduceMotion)
    }

    static func regionIllustration(reduceMotion: Bool) -> Animation {
        accessible(.easeInOut(duration: 0.35), reduceMotion: reduceMotion)
    }

    static func modalEnter(reduceMotion: Bool) -> Animation {
        accessible(.spring(response: 0.32, dampingFraction: 0.86), reduceMotion: reduceMotion)
    }
}

/// Scales/fades modal card content in on appear (death, level-up).
struct CelebrationModalEnter: ViewModifier {
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared ? 1 : (reduceMotion ? 1 : 0.96))
            .opacity(appeared ? 1 : (reduceMotion ? 1 : 0.94))
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(Motion.modalEnter(reduceMotion: false)) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    func celebrationModalEnter() -> some View {
        modifier(CelebrationModalEnter())
    }
}

struct DeathSkullIcon: View {
    @State private var pulse = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Image(systemName: "skull")
                    .symbolEffect(.pulse, options: .nonRepeating, value: pulse)
            } else {
                Image(systemName: "skull")
            }
        }
        .font(.system(size: 44))
        .foregroundColor(.red.opacity(0.9))
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else { return }
            pulse = true
        }
    }
}

struct LevelUpStarIcon: View {
    @State private var rotation: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Image(systemName: "arrow.up.circle.fill")
            .font(.system(size: 48))
            .foregroundColor(Theme.accent)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 0.5)) {
                    rotation = 360
                }
            }
    }
}

struct ToastTrophyIcon<Trigger: Hashable>: View {
    let trigger: Trigger

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .symbolEffect(.bounce, value: trigger)
            } else {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
}
