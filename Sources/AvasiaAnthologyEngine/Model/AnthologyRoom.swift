import Foundation
import AvasiaEngine

public enum AnthologyTransition: Sendable, Equatable {
    case stay
    case move(AnthologyRoomID)
}

public struct AnthologyTurnResult: Sendable {
    public var lines: [StyledLine]
    public var transition: AnthologyTransition

    public init(_ lines: [StyledLine] = [], _ transition: AnthologyTransition = .stay) {
        self.lines = lines
        self.transition = transition
    }
}

public protocol AnthologyRoomScript: Sendable {
    var id: AnthologyRoomID { get }
    var parseMode: Parser.Mode { get }
    func onEnter(_ state: inout AnthologyGameState) -> [StyledLine]?
    func describe(_ state: AnthologyGameState) -> [StyledLine]
    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult
}

public extension AnthologyRoomScript {
    var parseMode: Parser.Mode { .normalized }
    func onEnter(_ state: inout AnthologyGameState) -> [StyledLine]? { nil }
}
