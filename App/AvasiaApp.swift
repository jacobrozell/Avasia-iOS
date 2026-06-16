import SwiftUI

@main
struct AvasiaApp: App {
    @StateObject private var vm = GameViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environmentObject(vm)
                    .preferredColorScheme(vm.preferredColorScheme)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .milliseconds(1400))
                withAnimation(.easeOut(duration: 0.45)) {
                    showSplash = false
                }
            }
        }
    }
}

/// Routes between the title, settings, game, and credits screens.
struct RootView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        LayoutMetricsReader { _ in
            ZStack {
                switch vm.screen {
                case .saga:             SagaTitleView()
                case .title:            TitleView()
                case .settings:         SettingsView()
                case .privacyPolicy:    PrivacyPolicyView()
                case .game:             GameView()
                case .credits:          CreditsView()
                case .achievements:     AchievementsView()
                case .trophies:         SoCTrophiesView()
                case .codex:            CodexView()
                case .timeline:         SagaTimelineView()
                case .chroniclerLedger: ChroniclerLedgerView()
                }
            }
            .transition(ScreenTransition.transition(for: vm.screen, reduceMotion: reduceMotion))
            .animation(Motion.accessible(.easeInOut(duration: 0.28), reduceMotion: reduceMotion), value: vm.screen)
            .id(vm.themeRevision)
            .onAppear {
                vm.onLaunch()
                vm.updateSystemColorScheme(systemColorScheme)
            }
            .onChange(of: systemColorScheme) { vm.updateSystemColorScheme($0) }
        }
    }
}
