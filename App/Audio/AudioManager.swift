import Foundation
import AvasiaEngine
#if canImport(AVFoundation)
import AVFoundation
#endif

/// Plays the per-region ambient loop and one-shot sound effects. Every method
/// no-ops gracefully when an asset is missing, so the game is fully playable
/// before any audio is added — these are *hooks*, ready for files dropped into
/// `App/Resources/Audio/` (see docs/ASSETS.md).
@MainActor
final class AudioManager {
    static let shared = AudioManager()

    var isMuted: Bool = false {
        didSet {
            AppSettings.soundEnabled = !isMuted
            if isMuted { stopAmbient() }
        }
    }

    #if canImport(AVFoundation)
    private var ambientPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []
    private var currentAmbient: String?
    #endif

    private init() {
        isMuted = !AppSettings.soundEnabled
        #if canImport(AVFoundation) && os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    /// Start (or switch to) a looping ambient track by base name. Idempotent:
    /// re-requesting the playing track does nothing.
    func playAmbient(_ name: String?) {
        #if canImport(AVFoundation)
        guard !isMuted, let name else { stopAmbient(); return }
        guard name != currentAmbient else { return }
        guard let url = Self.url(forResource: name) else {
            currentAmbient = nil
            ambientPlayer?.stop()
            return
        }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = 0.5
        player?.prepareToPlay()
        player?.play()
        ambientPlayer = player
        currentAmbient = name
        #endif
    }

    func stopAmbient() {
        #if canImport(AVFoundation)
        ambientPlayer?.stop()
        ambientPlayer = nil
        currentAmbient = nil
        #endif
    }

    /// Fire a one-shot effect. Safe to call for cues with no file yet.
    func play(_ cue: SoundCue) {
        #if canImport(AVFoundation)
        guard !isMuted, let url = Self.url(forResource: cue.rawValue) else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = 0.8
        player.prepareToPlay()
        player.play()
        sfxPlayers.append(player)
        // Trim finished players so the array doesn't grow unbounded.
        sfxPlayers.removeAll { !$0.isPlaying && $0 !== player }
        #endif
    }

    #if canImport(AVFoundation)
    /// Resolve an audio asset by trying common extensions in `Resources/Audio`.
    private static func url(forResource name: String) -> URL? {
        let exts = ["m4a", "mp3", "caf", "wav"]
        for ext in exts {
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Audio")
                ?? Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }
    #endif
}
