import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum HapticCue {
    case tap
    case confirm
    case notify
    case warning
    case impactLight
}

@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func play(_ cue: HapticCue) {
        guard AppSettings.hapticsEnabled else { return }
        #if canImport(UIKit)
        guard supportsHaptics else { return }
        switch cue {
        case .tap, .impactLight:
            let style: UIImpactFeedbackGenerator.FeedbackStyle = cue == .tap ? .light : .soft
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .confirm:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        case .notify:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.error)
        }
        #endif
    }

    #if canImport(UIKit)
    private var supportsHaptics: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
            || UIDevice.current.userInterfaceIdiom == .phone
    }
    #endif
}
