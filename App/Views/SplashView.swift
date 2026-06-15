import SwiftUI

/// Brief branded overlay after the system launch screen; fades into `RootView`.
struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var glowScale: CGFloat = 0.92

    var body: some View {
        ZStack {
            TitleScreenBackground()
            RadialGradient(
                colors: [Theme.accent.opacity(0.28), .clear],
                center: .init(x: 0.5, y: 0.42),
                startRadius: 10,
                endRadius: 260
            )
            .scaleEffect(glowScale)
            Image("AvasiaLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300)
                .padding(.horizontal, 40)
                .opacity(logoOpacity)
                .accessibilityLabel("Avasia")
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                logoOpacity = 1
                glowScale = 1
            }
        }
    }
}
