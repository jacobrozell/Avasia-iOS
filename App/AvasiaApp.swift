import SwiftUI

@main
struct AvasiaApp: App {
    @StateObject private var vm = GameViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .preferredColorScheme(vm.preferredColorScheme)
        }
    }
}

/// Routes between the title, settings, game, and credits screens.
struct RootView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.colorScheme) private var systemColorScheme

    var body: some View {
        LayoutMetricsReader { _ in
            Group {
                switch vm.screen {
                case .saga:             SagaTitleView()
                case .title:            TitleView()
                case .settings:         SettingsView()
                case .privacyPolicy:    PrivacyPolicyView()
                case .game:             GameView()
                case .credits:          CreditsView()
                case .achievements:     AchievementsView()
                case .trophies:         SoCTrophiesView()
                }
            }
            .id(vm.themeRevision)
            .onAppear {
                vm.onLaunch()
                vm.updateSystemColorScheme(systemColorScheme)
            }
            .onChange(of: systemColorScheme) { vm.updateSystemColorScheme($0) }
        }
    }
}
