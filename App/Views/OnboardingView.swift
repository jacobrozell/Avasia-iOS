import SwiftUI
import AvasiaEngine

/// First-launch welcome tour — origin story, saga hub, play basics, Chronicler, extras.
struct OnboardingView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var page = 0

    private let pages = OnboardingPage.all

    var body: some View {
        ZStack {
            TitleScreenBackground()
            VStack(spacing: 0) {
                header
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        pageContent(item)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(
                    reduceMotion ? nil : Motion.accessible(.easeInOut(duration: 0.25), reduceMotion: reduceMotion),
                    value: page
                )
                footer
            }
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            if page < pages.count - 1 {
                Button("Skip") { vm.completeOnboarding() }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Theme.parchment.opacity(0.7))
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.vertical, 12)
                    .accessibilityHint("Skip the welcome tour")
            }
        }
        .frame(minHeight: 44)
    }

    private func pageContent(_ item: OnboardingPage) -> some View {
        ScrollView {
            VStack(spacing: metrics.isAccessibilityText ? 18 : 24) {
                Spacer(minLength: metrics.isLandscape ? 8 : 20)
                Image(systemName: item.systemImage)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 80, height: 80)
                    .background(Theme.accent.opacity(0.14), in: Circle())
                    .accessibilityHidden(true)

                Text(item.title)
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundColor(Theme.parchment)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(item.body)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(Theme.parchment.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let bullets = item.bullets {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(bullets, id: \.title) { bullet in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: bullet.systemImage)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(bullet.title)
                                        .font(.system(.subheadline, design: .serif).weight(.semibold))
                                        .foregroundColor(Theme.parchment)
                                    Text(bullet.detail)
                                        .font(.caption)
                                        .foregroundColor(Theme.parchment.opacity(0.68))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.palette.cardStroke, lineWidth: 1)
                    )
                }

                Spacer(minLength: 24)
            }
            .frame(maxWidth: metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, metrics.horizontalPadding)
            .accessibilityElement(children: .combine)
        }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Theme.accent : Theme.parchment.opacity(0.25))
                        .frame(width: index == page ? 8 : 6, height: index == page ? 8 : 6)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: page)
                }
            }
            .accessibilityLabel("Page \(page + 1) of \(pages.count)")

            if page < pages.count - 1 {
                MenuButton(title: "Next", systemImage: "arrow.right", style: .primary) {
                    withOptionalAnimation { page += 1 }
                }
            } else {
                MenuButton(title: "Enter the saga", systemImage: "sparkles", style: .primary) {
                    vm.completeOnboarding()
                }
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.bottom, 32)
    }

    private func withOptionalAnimation(_ action: () -> Void) {
        if reduceMotion {
            action()
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                action()
            }
        }
    }
}

// MARK: - Content

private struct OnboardingBullet: Hashable {
    let systemImage: String
    let title: String
    let detail: String
}

private struct OnboardingPage: Hashable {
    let systemImage: String
    let title: String
    let body: String
    let bullets: [OnboardingBullet]?

    static let all: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "laptopcomputer.and.arrow.down",
            title: "Where it began",
            body: """
            In high school, a few friends taught themselves Python after class — Chase, Devan, \
            Joshua, and the rest of us — building text adventures just for fun.

            We obsessed over this world for months. Years later, that passion became a native \
            iOS saga: faithful to the originals, rebuilt for your phone.
            """,
            bullets: nil
        ),
        OnboardingPage(
            systemImage: "books.vertical.fill",
            title: "A living saga",
            body: """
            Avasia is one long story told across chapters. Pick a chapter from the hub — \
            each has its own engine, save file, and arc in the same fictional history.
            """,
            bullets: [
                OnboardingBullet(
                    systemImage: "crown.fill",
                    title: "King of Nacastrum",
                    detail: "The amnesiac mage. Restore the floating city."
                ),
                OnboardingBullet(
                    systemImage: "shield.lefthalf.filled",
                    title: "Blade of Courage",
                    detail: "A druid's war. Win the coalition."
                ),
                OnboardingBullet(
                    systemImage: "book.fill",
                    title: "Short Stories",
                    detail: "Parallel tales. Choose sides — or refuse both."
                )
            ]
        ),
        OnboardingPage(
            systemImage: "text.cursor",
            title: "How you play",
            body: """
            Classic text adventure: read the story, then type a command or tap a suggestion. \
            Tap the transcript while text is typing to skip ahead.

            Adjust pacing, typewriter speed, cursor style, sound, and haptics in Settings.
            """,
            bullets: nil
        ),
        OnboardingPage(
            systemImage: "heart.text.square.fill",
            title: "Fights & saves",
            body: """
            Your progress is saved automatically after each turn. Pick up where you left off \
            with Continue on any chapter's title screen.
            """,
            bullets: [
                OnboardingBullet(
                    systemImage: "bookmark.fill",
                    title: "One save per chapter",
                    detail: "KoN, SoC, and Short Stories each keep their own file."
                ),
                OnboardingBullet(
                    systemImage: "bolt.shield.fill",
                    title: "Combat",
                    detail: "When battle finds you, watch your HP and strike back — attack, defend, or flee when you can."
                ),
                OnboardingBullet(
                    systemImage: "arrow.counterclockwise",
                    title: "Death & checkpoints",
                    detail: "Fall in combat and restart from your last checkpoint, or begin a fresh run."
                )
            ]
        ),
        OnboardingPage(
            systemImage: "scroll.fill",
            title: "The Chronicler",
            body: """
            Your investment follows you across chapters. Earn saga XP, rise in Chronicler Rank, \
            and open the ledger to see every gain — across all runs and all games.
            """,
            bullets: [
                OnboardingBullet(
                    systemImage: "rosette",
                    title: "Achievements & trophies",
                    detail: "KoN achievements and SoC trophies grant one-time XP when claimed."
                ),
                OnboardingBullet(
                    systemImage: "chart.line.uptrend.xyaxis",
                    title: "Rank on the hub",
                    detail: "The Chronicler strip on the saga home tracks your lifetime progress."
                )
            ]
        ),
        OnboardingPage(
            systemImage: "map.fill",
            title: "Explore the saga",
            body: """
            There is more than the main quest. Lore, history, and side paths reward curiosity.
            """,
            bullets: [
                OnboardingBullet(
                    systemImage: "book.closed.fill",
                    title: "Codex",
                    detail: "Lore entries unlock as you play each chapter."
                ),
                OnboardingBullet(
                    systemImage: "clock.arrow.circlepath",
                    title: "Saga Timeline",
                    detail: "Series chronology from the hub — how the eras connect."
                ),
                OnboardingBullet(
                    systemImage: "theatermasks.fill",
                    title: "Short Stories",
                    detail: "What-if tales from other corners of the war."
                )
            ]
        )
    ]
}
