import AvasiaEngine

extension GameEngine {
    /// Test helper — `state` is read-only outside the engine.
    func load(room: RoomID, configure: (inout GameState) -> Void = { _ in }) {
        var state = self.state
        state.currentRoom = room
        configure(&state)
        load(state)
    }
}
