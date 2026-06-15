import Foundation
import SwiftUI
import AvasiaEngine

/// Bridges the pure `GameEngine` to SwiftUI: owns the transcript, applies text
/// pacing, autosaves, and exposes quick-action verbs. All game logic stays in
/// the engine; this layer is presentation + timing only.
@MainActor
final class GameViewModel: ObservableObject {
    enum Screen { case title, settings, game, credits }

    @Published var screen: Screen = .title
    @Published private(set) var transcript: [StyledLine] = []
    @Published private(set) var pendingDeath = false
    @Published var input: String = ""

    private let engine: GameEngine
    private let store = SaveStore()

    init(engine: GameEngine = GameEngine()) {
        self.engine = engine
    }

    var state: GameState { engine.state }
    var textDelay: TextDelay {
        get { engine.state.textDelay }
        set { engine.setTextDelay(newValue) }
    }

    // MARK: - Lifecycle

    func startNewGame() {
        engine.restart()
        transcript = []
        pendingDeath = false
        appendIntro()
        append(engine.describeCurrent())
        screen = .game
    }

    func continueGame() {
        guard let saved = store.load() else { startNewGame(); return }
        engine.load(saved)
        transcript = []
        append(engine.describeCurrent())
        pendingDeath = false
        screen = .game
    }

    var hasSave: Bool { store.load() != nil }

    // MARK: - Turn loop

    func submit() {
        let raw = input.trimmingCharacters(in: .whitespaces)
        input = ""
        guard !raw.isEmpty else { return }
        append([.hint("> \(raw)")])
        let before = engine.state.deathCount
        let lines = engine.submit(raw)
        append(lines)
        if engine.state.deathCount > before {
            pendingDeath = true
        } else {
            try? store.save(engine.state)                      // autosave
            try? store.save(engine.state, to: .checkpoint)     // room-entry checkpoint
        }
    }

    func quickAction(_ verb: String) {
        input = verb
        submit()
    }

    // MARK: - Death handling (sanctioned improvement: offer checkpoint)

    func restartFromCheckpoint() {
        if let cp = store.load(.checkpoint) { engine.load(cp) }
        transcript = []
        append(engine.describeCurrent())
        pendingDeath = false
    }

    func restartFromBeginning() { startNewGame() }

    // MARK: - Helpers

    private func append(_ lines: [StyledLine]) {
        transcript.append(contentsOf: lines)
    }

    private func appendIntro() {
        append([
            .title("Avasia: King of Nacastrum"),
            .body("You hear waves and the sound of the ocean around you. But... where are you?"),
            .body("You pull yourself to your feet, alongside a beach. The remains of a gate stand to your north."),
            .blank
        ])
    }
}
