import Foundation
import AvasiaEngine
import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    func preferredColorScheme(system: ColorScheme) -> ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    func resolvedScheme(system: ColorScheme) -> ColorScheme {
        switch self {
        case .system: return system
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum TypewriterSpeed: String, CaseIterable, Identifiable {
    case slow
    case normal
    case fast

    var id: String { rawValue }

    var label: String {
        switch self {
        case .slow: return "Slow"
        case .normal: return "Normal"
        case .fast: return "Fast"
        }
    }

    /// Multiplier applied to per-character delays (higher = slower).
    var delayMultiplier: Double {
        switch self {
        case .slow: return 1.55
        case .normal: return 1.0
        case .fast: return 0.5
        }
    }
}

enum CursorStyle: String, CaseIterable, Identifiable {
    case bar
    case underscore
    case block
    case none

    var id: String { rawValue }

    var label: String {
        switch self {
        case .bar: return "Bar"
        case .underscore: return "Underscore"
        case .block: return "Block"
        case .none: return "None"
        }
    }

    var glyph: String? {
        switch self {
        case .bar: return "▌"
        case .underscore: return "_"
        case .block: return "█"
        case .none: return nil
        }
    }
}

/// Cross-session preferences not tied to a single save slot.
enum AppSettings {
    private static let textDelayKey = "avasia.textDelay"
    private static let soundEnabledKey = "avasia.soundEnabled"
    private static let appearanceKey = "avasia.appearance"
    private static let typewriterSpeedKey = "avasia.typewriterSpeed"
    private static let cursorStyleKey = "avasia.cursorStyle"
    private static let hapticsEnabledKey = "avasia.hapticsEnabled"
    private static let chroniclerShowXPToastsKey = "avasia.chronicler.showXPToasts"
    private static let chroniclerAutoClaimKey = "avasia.chronicler.autoClaim"
    private static let chroniclerShowThisRunKey = "avasia.chronicler.showThisRun"

    static var hapticsEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: hapticsEnabledKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: hapticsEnabledKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: hapticsEnabledKey) }
    }

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

    static var appearance: AppAppearance {
        get {
            guard let raw = UserDefaults.standard.string(forKey: appearanceKey),
                  let value = AppAppearance(rawValue: raw) else { return .dark }
            return value
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: appearanceKey) }
    }

    static var typewriterSpeed: TypewriterSpeed {
        get {
            guard let raw = UserDefaults.standard.string(forKey: typewriterSpeedKey),
                  let value = TypewriterSpeed(rawValue: raw) else { return .normal }
            return value
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: typewriterSpeedKey) }
    }

    static var cursorStyle: CursorStyle {
        get {
            guard let raw = UserDefaults.standard.string(forKey: cursorStyleKey),
                  let value = CursorStyle(rawValue: raw) else { return .bar }
            return value
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: cursorStyleKey) }
    }

    static var chroniclerShowXPToasts: Bool {
        get {
            if UserDefaults.standard.object(forKey: chroniclerShowXPToastsKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: chroniclerShowXPToastsKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: chroniclerShowXPToastsKey) }
    }

    static var chroniclerAutoClaimAchievements: Bool {
        get { UserDefaults.standard.bool(forKey: chroniclerAutoClaimKey) }
        set { UserDefaults.standard.set(newValue, forKey: chroniclerAutoClaimKey) }
    }

    static var chroniclerShowThisRunXP: Bool {
        get {
            if UserDefaults.standard.object(forKey: chroniclerShowThisRunKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: chroniclerShowThisRunKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: chroniclerShowThisRunKey) }
    }
}
