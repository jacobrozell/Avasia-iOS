import SwiftUI

/// Size-class and Dynamic Type aware layout constants for iPhone, iPad, and
/// accessibility text sizes.
struct LayoutMetrics: Equatable {
    let size: CGSize
    let horizontalSizeClass: UserInterfaceSizeClass?
    let verticalSizeClass: UserInterfaceSizeClass?
    let dynamicTypeSize: DynamicTypeSize

    var isLandscape: Bool { size.width > size.height }
    var isRegularWidth: Bool { horizontalSizeClass == .regular }
    var isAccessibilityText: Bool { dynamicTypeSize.isAccessibilitySize }

    /// Two-column game layout on iPad or very wide landscape (not iPhone landscape).
    var usesSplitGameLayout: Bool {
        isRegularWidth || (isLandscape && size.width >= 900)
    }

    var illustrationHeight: CGFloat {
        if usesSplitGameLayout { return min(size.height * 0.38, 240) }
        if isLandscape { return isAccessibilityText ? 52 : 68 }
        return isAccessibilityText ? 72 : 96
    }

    /// Max width for menu-style screens (title, settings, credits).
    var contentMaxWidth: CGFloat { isRegularWidth ? 520 : .infinity }

    /// Max width when centering the game panel on very wide screens.
    var gameContentMaxWidth: CGFloat {
        usesSplitGameLayout ? min(size.width, 1100) : .infinity
    }

    var gameSidebarWidth: CGFloat {
        min(max(size.width * 0.30, 220), 300)
    }

    var horizontalPadding: CGFloat { isRegularWidth ? 28 : 16 }

    /// Flow-wrap quick actions instead of a single horizontal scroller.
    var usesWrappedQuickActions: Bool {
        isAccessibilityText
            || usesSplitGameLayout
            || (isLandscape && !usesSplitGameLayout && size.height < 420)
    }
}

private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics(
        size: CGSize(width: 390, height: 844),
        horizontalSizeClass: .compact,
        verticalSizeClass: .regular,
        dynamicTypeSize: .large
    )
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

/// Publishes `LayoutMetrics` from the current geometry and environment.
struct LayoutMetricsReader<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ViewBuilder let content: (LayoutMetrics) -> Content

    var body: some View {
        GeometryReader { geo in
            let metrics = LayoutMetrics(
                size: geo.size,
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass,
                dynamicTypeSize: dynamicTypeSize
            )
            content(metrics)
                .environment(\.layoutMetrics, metrics)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

/// Centers content and caps width on iPad.
struct CenteredPanel<Content: View>: View {
    @Environment(\.layoutMetrics) private var metrics
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, metrics.horizontalPadding)
    }
}
