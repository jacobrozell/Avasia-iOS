import Foundation

/// Shared narrative lines keyed off throne-room choices and class.
enum SoCStoryVoice {
    static func sergeantOpener(_ state: SoCGameState) -> String {
        switch state.throneRecountStyle {
        case .honorDentros:
            return "Coalition Sergeant: You spoke of Dentros before the king. Grief's honest — keep it. Now listen."
        case .reportFacts:
            return "Coalition Sergeant: Clear reports saved us at Nacastrum. Same standard on this front, Cataractan."
        case .none:
            return "Coalition Sergeant: Eyes up, Cataractan. King Kaefden isn't here to give pretty speeches — listen."
        }
    }

    static func ofelosAddress(_ state: SoCGameState) -> String {
        switch state.throneRecountStyle {
        case .honorDentros:
            return "Council Speaker Maelen: The Sylvians say you honor the dead before the living. Ofelos respects that."
        case .reportFacts:
            return "Council Speaker Maelen: You report like a soldier, not a poet. Ofelos respects clarity."
        case .none:
            return "Council Speaker Maelen: Seven years we stayed neutral while Oceandale burned and Cataracta learned the cost of delay."
        }
    }
}
