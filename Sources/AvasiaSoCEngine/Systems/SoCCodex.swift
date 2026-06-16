import Foundation
import AvasiaEngine

public enum SoCCodexCategory: String, CaseIterable, Sendable {
    case character
    case storyBeat

    public var title: String {
        switch self {
        case .character: return "Characters"
        case .storyBeat: return "Story"
        }
    }
}

/// Unlockable journal entries derived from save state — characters met and major beats cleared.
public enum SoCCodexEntry: String, CaseIterable, Sendable {
  case kimious
  case ulric
  case doran
  case thekia
  case kaefden
  case vashirr
  case dentros
  case sylvianElders

  case enlistment
  case courtyardMassacre
  case throneAudience
  case warCamp
  case bladeRecovered
  case ofelosAlliance
  case vashirrFall
  case campaignComplete

  public var category: SoCCodexCategory {
    switch self {
    case .kimious, .ulric, .doran, .thekia, .kaefden, .vashirr, .dentros, .sylvianElders:
      return .character
    case .enlistment, .courtyardMassacre, .throneAudience, .warCamp, .bladeRecovered,
         .ofelosAlliance, .vashirrFall, .campaignComplete:
      return .storyBeat
    }
  }

  public var title: String {
    switch self {
    case .kimious: return "King Kimious"
    case .ulric: return "Ulric the Blacksmith"
    case .doran: return "Doran the Fisher"
    case .thekia: return "Thekia"
    case .kaefden: return "Kaefden IV"
    case .vashirr: return "Vashirr"
    case .dentros: return "Dentros"
    case .sylvianElders: return "Sylvian Elders"
    case .enlistment: return "Legion Enlistment"
    case .courtyardMassacre: return "Courtyard Massacre"
    case .throneAudience: return "Throne Audience"
    case .warCamp: return "Aylova War Camp"
    case .bladeRecovered: return "Blade of Courage"
    case .ofelosAlliance: return "Ofelos Alliance"
    case .vashirrFall: return "Vashirr's Redoubt"
    case .campaignComplete: return "Age Epilogue"
    }
  }

  public var symbolName: String {
    switch self {
    case .kimious, .kaefden: return "crown.fill"
    case .ulric: return "hammer.fill"
    case .doran: return "fish.fill"
    case .thekia: return "book.closed.fill"
    case .vashirr: return "bolt.fill"
    case .dentros: return "leaf.fill"
    case .sylvianElders: return "tree.fill"
    case .enlistment: return "shield.fill"
    case .courtyardMassacre: return "flame.fill"
    case .throneAudience: return "building.columns.fill"
    case .warCamp: return "tent.fill"
    case .bladeRecovered: return "sword.fill"
    case .ofelosAlliance: return "flag.fill"
    case .vashirrFall: return "mountain.2.fill"
    case .campaignComplete: return "seal.fill"
    }
  }

  public var summary: String {
    switch self {
    case .kimious:
      return "King of Cataracta. He rallied the Legion against Agromanian raids and called hidden reserves before Vashirr struck the courtyard."
    case .ulric:
      return "Cataracta's blacksmith. Gruff but loyal — he sends new recruits to Doran's pier and jokes about Anula prices."
    case .doran:
      return "Fisher at the pier and Ulric's brother. Offers a free rod to legionnaires who earn Ulric's trust."
    case .thekia:
      return "Nacastrum council elder and Kaefden's mentor. She survived the portal assault and urges the king toward coalition war."
    case .kaefden:
      return "Mage-King of Nacastrum. Once the amnesiac from Oceandale beach — now he commands the coalition against Vashirr."
    case .vashirr:
      return "Ex-King of Nacastrum. He forges Paladins, preaches the Many Hands doctrine, and believes one fused army can end the schism."
    case .dentros:
      return "Druid scout from KoN's forest gate. He enlisted at Cataracta's courtyard and died holding the line so others could warn Nacastrum."
    case .sylvianElders:
      return "Council of Sylvian druids. They commission the quest for Kaefden's Blade — courage as civic duty, not personal glory."
    case .enlistment:
      return "You chose Wolf, Bear, or Fox and swore to Cataracta's Legion — seven years after the beach awakening in King of Nacastrum."
    case .courtyardMassacre:
      return "Vashirr's Paladins struck Kimious's rally. The keep fell, the fountain cracked, and Cataracta burned."
    case .throneAudience:
      return "You reached Nacastrum's throne and told Kaefden IV what the ashes left behind — honoring Dentros or reporting the facts."
    case .warCamp:
      return "Aylova mustered the coalition: briefing, quartermaster, and the march east toward Silvarium."
    case .bladeRecovered:
      return "Kaefden's Blade of Courage lifted from the first king's tomb at Varatro Falls — symbol enough to move neutral Ofelos."
    case .ofelosAlliance:
      return "Ofelos council accepted the Blade. Neutrality's ledger price: march north with the coalition."
    case .vashirrFall:
      return "The redoubt broke. Vashirr's reform ended at the ridge — history will argue whether he was traitor or zealot."
    case .campaignComplete:
      return "The Age-era war closed with memorial stone and victory speech. Cataracta's debt is tallied in crystal and names."
    }
  }

  public var lockedHint: String {
    switch self {
    case .kimious: return "Reach the courtyard enlistment."
    case .ulric: return "Visit the blacksmith in Cataracta shopping."
    case .doran: return "Accept Ulric's send-off to the pier."
    case .thekia: return "Find Thekia in Nacastrum's library or throne room."
    case .kaefden: return "Gain audience with the Mage-King."
    case .vashirr: return "March to Vashirr's redoubt."
    case .dentros: return "Recall Dentros at the throne audience."
    case .sylvianElders: return "Reach Silvarium elders after war camp."
    case .enlistment: return "Enlist in the Cataracta courtyard."
    case .courtyardMassacre: return "Survive the courtyard assault."
    case .throneAudience: return "Warn Kaefden IV on the throne."
    case .warCamp: return "Complete Aylova muster."
    case .bladeRecovered: return "Clear Varatro Falls tomb."
    case .ofelosAlliance: return "Present the Blade before Ofelos."
    case .vashirrFall: return "Defeat Vashirr at the redoubt."
    case .campaignComplete: return "Finish the Age epilogue."
    }
  }

  /// Chronological position on the Age-era saga timeline (story beats only).
  public var timelineOrder: Int? {
    switch self {
    case .enlistment: return 120
    case .courtyardMassacre: return 130
    case .throneAudience: return 140
    case .warCamp: return 150
    case .bladeRecovered: return 160
    case .ofelosAlliance: return 170
    case .vashirrFall: return 180
    case .campaignComplete: return 190
    default: return nil
    }
  }

  public var timelineLabel: String? {
    guard timelineOrder != nil else { return nil }
    return "SoC"
  }
}

public enum SoCCodex {
  public static func isUnlocked(_ entry: SoCCodexEntry, state: SoCGameState) -> Bool {
    switch entry {
    case .kimious:
      return state.courtyardComplete || state.courtyardPhase != .notStarted
    case .ulric:
      return state.ulric
    case .doran:
      return state.doran
    case .thekia:
      return state.metThekia
    case .kaefden:
      return state.throneAudience
    case .vashirr:
      return state.vashirrStandPhase != .notStarted
    case .dentros:
      return state.throneRecountStyle != .none
    case .sylvianElders:
      return state.silvariumEldersPhase != .notStarted
    case .enlistment:
      return state.courtyardComplete || state.playerClass != .none
    case .courtyardMassacre:
      return state.courtyardComplete
    case .throneAudience:
      return state.throneAudience
    case .warCamp:
      return state.aylovaMusterComplete
    case .bladeRecovered:
      return state.varatroFallsCleared || state.trophies.contains(.bladeBearer)
    case .ofelosAlliance:
      return state.ofelosAllianceComplete
    case .vashirrFall:
      return state.vashirrDefeated
    case .campaignComplete:
      return state.gameComplete
    }
  }

  public static func entries(for category: SoCCodexCategory) -> [SoCCodexEntry] {
    SoCCodexEntry.allCases.filter { $0.category == category }
  }

  public static func timelineEntries() -> [SoCCodexEntry] {
    SoCCodexEntry.allCases
      .filter { $0.timelineOrder != nil }
      .sorted { ($0.timelineOrder ?? 0) < ($1.timelineOrder ?? 0) }
  }

  public static func unlockedCount(for state: SoCGameState) -> Int {
    SoCCodexEntry.allCases.filter { isUnlocked($0, state: state) }.count
  }
}
