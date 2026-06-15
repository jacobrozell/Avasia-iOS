import SwiftUI
import AvasiaEngine
#if canImport(UIKit)
import UIKit
#endif

/// Per-region color palette used both as accent and as the gradient fallback
/// when a region's art asset hasn't been added yet. Tuned around the game's
/// blue-crystal motif (STORY.md §8).
enum RegionPalette {
    static func colors(_ region: Region) -> (top: Color, bottom: Color, accent: Color) {
        if Theme.isLight { return lightColors(region) }
        return darkColors(region)
    }

    private static func darkColors(_ region: Region) -> (top: Color, bottom: Color, accent: Color) {
        switch region {
        case .oceandale: return (c(0.10, 0.12, 0.16), c(0.04, 0.05, 0.08), Theme.accent)
        case .beach:     return (c(0.12, 0.16, 0.20), c(0.05, 0.08, 0.12), c(0.45, 0.75, 0.95))
        case .graveyard: return (c(0.10, 0.10, 0.12), c(0.03, 0.03, 0.05), c(0.6, 0.6, 0.7))
        case .splitpath: return (c(0.12, 0.12, 0.10), c(0.05, 0.05, 0.04), c(0.8, 0.7, 0.4))
        case .mountain:  return (c(0.10, 0.12, 0.15), c(0.04, 0.05, 0.07), c(0.5, 0.7, 0.9))
        case .cave:      return (c(0.16, 0.08, 0.16), c(0.06, 0.03, 0.08), c(0.95, 0.5, 0.85))
        case .forest:    return (c(0.07, 0.13, 0.09), c(0.03, 0.06, 0.04), c(0.4, 0.85, 0.5))
        case .tree:      return (c(0.10, 0.12, 0.08), c(0.05, 0.06, 0.03), c(0.6, 0.9, 0.5))
        case .road:      return (c(0.13, 0.11, 0.10), c(0.05, 0.04, 0.04), c(0.9, 0.6, 0.4))
        case .shore:     return (c(0.10, 0.15, 0.18), c(0.04, 0.07, 0.10), c(0.45, 0.75, 0.95))
        case .nacastrum: return (c(0.12, 0.14, 0.20), c(0.05, 0.06, 0.12), Theme.accent)
        case .aylova:    return (c(0.14, 0.13, 0.20), c(0.06, 0.05, 0.12), c(0.55, 0.6, 0.95))
        case .cataracta: return (c(0.08, 0.14, 0.11), c(0.03, 0.07, 0.05), c(0.45, 0.85, 0.55))
        }
    }

    private static func lightColors(_ region: Region) -> (top: Color, bottom: Color, accent: Color) {
        switch region {
        case .oceandale: return (c(0.90, 0.92, 0.95), c(0.82, 0.86, 0.91), Theme.accent)
        case .beach:     return (c(0.92, 0.94, 0.96), c(0.84, 0.89, 0.93), c(0.20, 0.45, 0.72))
        case .graveyard: return (c(0.88, 0.88, 0.90), c(0.80, 0.80, 0.84), c(0.35, 0.35, 0.45))
        case .splitpath: return (c(0.93, 0.91, 0.86), c(0.86, 0.83, 0.76), c(0.55, 0.42, 0.18))
        case .mountain:  return (c(0.90, 0.92, 0.95), c(0.82, 0.86, 0.90), c(0.25, 0.45, 0.68))
        case .cave:      return (c(0.91, 0.86, 0.91), c(0.84, 0.78, 0.84), c(0.55, 0.28, 0.52))
        case .forest:    return (c(0.88, 0.93, 0.89), c(0.80, 0.88, 0.82), c(0.18, 0.48, 0.28))
        case .tree:      return (c(0.90, 0.92, 0.86), c(0.83, 0.87, 0.80), c(0.28, 0.52, 0.30))
        case .road:      return (c(0.93, 0.90, 0.88), c(0.86, 0.82, 0.80), c(0.58, 0.38, 0.22))
        case .shore:     return (c(0.90, 0.93, 0.95), c(0.82, 0.88, 0.92), c(0.20, 0.45, 0.72))
        case .nacastrum: return (c(0.91, 0.92, 0.96), c(0.83, 0.85, 0.92), Theme.accent)
        case .aylova:    return (c(0.92, 0.91, 0.96), c(0.84, 0.83, 0.90), c(0.30, 0.35, 0.68))
        case .cataracta: return (c(0.88, 0.93, 0.90), c(0.80, 0.88, 0.84), c(0.18, 0.48, 0.32))
        }
    }
    private static func c(_ r: Double, _ g: Double, _ b: Double) -> Color { Color(red: r, green: g, blue: b) }
}

#if canImport(UIKit)
private func assetExists(_ name: String) -> Bool { UIImage(named: name) != nil }
#else
private func assetExists(_ name: String) -> Bool { false }
#endif

/// Full-bleed background: the region's art if present, else a region gradient.
struct RegionBackground: View {
    let media: RoomMedia
    var body: some View {
        let p = RegionPalette.colors(media.region)
        ZStack {
            LinearGradient(colors: [p.top, p.bottom], startPoint: .top, endPoint: .bottom)
            if assetExists(media.backgroundImage) {
                Image(media.backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.45)
                    .blur(radius: 1)
            }
        }
        .ignoresSafeArea()
    }
}

/// Header illustration band: the region's art if present, else a labeled
/// placeholder so the layout (and the hook) is visible before art exists.
struct RegionIllustration: View {
    let media: RoomMedia
    var height: CGFloat = 96

    var body: some View {
        let p = RegionPalette.colors(media.region)
        ZStack {
            if assetExists(media.illustration) {
                Image(media.illustration)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(colors: [p.accent.opacity(0.25), p.bottom],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                HStack {
                    Image(systemName: "sparkle")
                    Text(media.region.title)
                        .font(.system(.subheadline, design: .serif).smallCaps())
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(p.accent)
                .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
        .clipped()
        .overlay(Rectangle().frame(height: 1).foregroundColor(p.accent.opacity(0.5)), alignment: .bottom)
        .accessibilityLabel("Region: \(media.region.title)")
    }
}
