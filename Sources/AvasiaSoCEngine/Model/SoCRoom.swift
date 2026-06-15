import Foundation
import AvasiaEngine

public enum SoCTransition: Sendable, Equatable {
    case stay
    case move(SoCRoomID)
}

public struct SoCTurnResult: Sendable {
    public var lines: [StyledLine]
    public var transition: SoCTransition
    public var playerDied: Bool

    public init(_ lines: [StyledLine] = [], _ transition: SoCTransition = .stay, playerDied: Bool = false) {
        self.lines = lines
        self.transition = transition
        self.playerDied = playerDied
    }
}

public protocol SoCRoomScript: Sendable {
    var id: SoCRoomID { get }
    var parseMode: Parser.Mode { get }
    /// Logic rooms that print a message and immediately return (Python `return "go back"`).
    func autoReturnAfterEnter(_ state: SoCGameState) -> SoCRoomID?
    /// Runs once when entering via a move transition (Python `on_enter` setup).
    func onEnter(_ state: inout SoCGameState) -> [StyledLine]?
    func describe(_ state: SoCGameState) -> [StyledLine]
    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult
}

public extension SoCRoomScript {
    var parseMode: Parser.Mode { .normalized }
    func autoReturnAfterEnter(_ state: SoCGameState) -> SoCRoomID? { nil }
    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? { nil }
}
