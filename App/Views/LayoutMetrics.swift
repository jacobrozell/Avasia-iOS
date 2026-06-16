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

    /// Two-column game layout on iPad or landscape phones with enough width.
    var usesSplitGameLayout: Bool {
        isRegularWidth || (isLandscape && size.width >= 700)
    }

    /// Stacked layout in landscape — vertical status avoids a horizontal scroller.
    var usesCompactStatusStrip: Bool {
        isLandscape && !usesSplitGameLayout
    }

    var illustrationHeight: CGFloat {
        if usesSplitGameLayout { return min(size.height * 0.38, 240) }
        if isLandscape { return isAccessibilityText ? 40 : 52 }
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
            || isLandscape
    }

    /// Caps quick-action area height so the transcript keeps room in landscape.
    var quickActionsMaxHeight: CGFloat? {
        if isLandscape && !usesSplitGameLayout { return isAccessibilityText ? 140 : 108 }
        if isAccessibilityText { return 180 }
        return nil
    }

    // MARK: - Catalog screens (journal, achievements, timeline, ledger)

    var menuHeaderTopPadding: CGFloat { isLandscape ? 8 : 24 }
    var menuHeaderBottomPadding: CGFloat { isLandscape ? 4 : 8 }

    /// Landscape catalog screens use a toolbar back button to preserve scroll height.
    var usesToolbarBackButton: Bool { isLandscape }

    var catalogGridMinimum: CGFloat {
        if isRegularWidth { return 96 }
        if isLandscape { return 72 }
        return 88
    }

    var catalogGridMaximum: CGFloat {
        if isRegularWidth { return 140 }
        if isLandscape { return 100 }
        return 110
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

/// Shared chrome for journal, achievements, trophies, timeline, and ledger screens.
struct CatalogScreenChrome<Header: View, Accessory: View, Content: View>: View {
    @Environment(\.layoutMetrics) private var metrics
    let backTitle: String
    let onBack: () -> Void
    @ViewBuilder let header: () -> Header
    @ViewBuilder let accessory: () -> Accessory
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            header()
            accessory()
            content()
                .layoutPriority(1)
            if !metrics.usesToolbarBackButton {
                MenuButton(title: backTitle, action: onBack)
                    .padding(.horizontal, metrics.horizontalPadding)
                    .padding(.bottom, 12)
            }
        }
        .toolbar {
            if metrics.usesToolbarBackButton {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onBack) {
                        Label(backTitle, systemImage: "chevron.backward")
                            .foregroundColor(Theme.accent)
                    }
                    .accessibilityLabel(backTitle)
                }
            }
        }
    }
}
