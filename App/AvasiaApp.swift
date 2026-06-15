import SwiftUI

@main
struct AvasiaApp: App {
    @StateObject private var vm = GameViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .preferredColorScheme(.dark) // parchment-on-night fantasy feel
        }
    }
}

/// Routes between the title, settings, game, and credits screens.
struct RootView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        switch vm.screen {
        case .title:    TitleView()
        case .settings: SettingsView()
        case .game:     GameView()
        case .credits:  CreditsView()
        }
    }
}
