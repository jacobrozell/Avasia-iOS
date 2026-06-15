import Foundation
import AvasiaEngine

/// Cross-session preferences not tied to a single save slot.
enum AppSettings {
    private static let textDelayKey = "avasia.textDelay"
    private static let soundEnabledKey = "avasia.soundEnabled"

    static var textDelay: TextDelay {
        get {
            guard let raw = UserDefaults.standard.string(forKey: textDelayKey),
                  let value = TextDelay(rawValue: raw) else { return .on }
            return value
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: textDelayKey) }
    }

    static var soundEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: soundEnabledKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: soundEnabledKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: soundEnabledKey) }
    }
}
