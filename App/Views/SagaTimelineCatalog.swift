import Foundation
import AvasiaEngine
import AvasiaSoCEngine
import AvasiaAnthologyEngine

enum SagaEra: String, CaseIterable, Identifiable {
    case legend
    case kon
    case gap
    case soc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .legend: return "Legend"
        case .kon: return "King of Nacastrum"
        case .gap: return "Seven-year gap"
        case .soc: return "Blade of Courage"
        }
    }
}

struct SagaTimelineEvent: Identifiable {
    let id: String
    let era: SagaEra
    let order: Int
    let title: String
    let dateLabel: String
    let symbolName: String
    let summary: String
    let lockedHint: String
    let unlocked: Bool
}

enum SagaTimelineCatalog {
  private static let gapEvents: [GapEvent] = [
    GapEvent(
      id: "gapQuiet",
      order: 90,
      title: "Seven Years Without an Army",
      dateLabel: "Year 1–7",
      symbolName: "hourglass",
      summary: "Kaefden IV crowned; Oceandale falls to ruin. No Agromanian invasion crosses the border — but Paladin rumors reach Silvarium, and requisition whispers follow the Varatho.",
      lockedHint: "Finish King of Nacastrum.",
      isUnlocked: { kon, _, _ in kon?.gameComplete == true }
    ),
    GapEvent(
      id: "gapScoutPatrol",
      order: 100,
      title: "Scout Patrol",
      dateLabel: "Gap · forest",
      symbolName: "binoculars.fill",
      summary: "A Cataracta patrol meets Vashirr's sermon at the ridge — REPORT, FOLLOW, or REFUSE. The anthology's fork sets which war stories unlock.",
      lockedHint: "Play Scout Patrol in Story Adventures.",
      isUnlocked: { _, _, anthology in anthology?.storyZeroComplete == true }
    ),
    GapEvent(
      id: "gapElkFeast",
      order: 105,
      title: "Elk Feast",
      dateLabel: "Gap · neutral",
      symbolName: "flame.fill",
      summary: "Harvest feast away from both banners. Schism told as cautionary tale, not propaganda — the neutral path's first anthology beat.",
      lockedHint: "Complete Elk Feast in Story Adventures (REFUSE path).",
      isUnlocked: { _, _, anthology in anthology?.elkFeastComplete == true }
    ),
    GapEvent(
      id: "gapCaveRecord",
      order: 108,
      title: "Cave Record",
      dateLabel: "Gap · archive",
      symbolName: "archivebox.fill",
      summary: "Bark-sheet records hidden before the mages scattered — KoN mountain lore from a neutral archivist who feared both towers.",
      lockedHint: "Complete Cave Record in Story Adventures.",
      isUnlocked: { _, _, anthology in anthology?.caveRecordComplete == true }
    ),
    GapEvent(
      id: "gapRequisition",
      order: 110,
      title: "Anula on the Varatho",
      dateLabel: "Year 7",
      symbolName: "shippingbox.fill",
      summary: "Requisition crates reach Cataracta. King's war chest buys crystal now; river folk pay in fish and silence. The legion summons you.",
      lockedHint: "Begin Blade of Courage.",
      isUnlocked: { _, soc, _ in soc?.actOneIntroShown == true }
    ),
  ]

  private struct GapEvent {
    let id: String
    let order: Int
    let title: String
    let dateLabel: String
    let symbolName: String
    let summary: String
    let lockedHint: String
    let isUnlocked: (GameState?, SoCGameState?, AnthologyGameState?) -> Bool

    func materialize(kon: GameState?, soc: SoCGameState?, anthology: AnthologyGameState?) -> SagaTimelineEvent {
      SagaTimelineEvent(
        id: id,
        era: .gap,
        order: order,
        title: title,
        dateLabel: dateLabel,
        symbolName: symbolName,
        summary: summary,
        lockedHint: lockedHint,
        unlocked: isUnlocked(kon, soc, anthology)
      )
    }
  }

  static func allEvents(kon: GameState?, soc: SoCGameState?, anthology: AnthologyGameState?) -> [SagaTimelineEvent] {
    var events: [SagaTimelineEvent] = []

    if let kon {
      for entry in KonCodex.timelineEntries(for: kon) {
        let era: SagaEra = entry == .schismLore ? .legend : .kon
        events.append(SagaTimelineEvent(
          id: "kon.\(entry.rawValue)",
          era: era,
          order: entry.timelineOrder ?? 0,
          title: entry.title,
          dateLabel: entry == .schismLore ? "Before memory" : "KoN",
          symbolName: entry.symbolName,
          summary: entry.summary,
          lockedHint: entry.lockedHint,
          unlocked: KonCodex.isUnlocked(entry, state: kon)
        ))
      }
    } else {
      events += placeholderKonEvents()
    }

    events += gapEvents.map { $0.materialize(kon: kon, soc: soc, anthology: anthology) }

    if let soc {
      for entry in SoCCodex.timelineEntries() {
        events.append(SagaTimelineEvent(
          id: "soc.\(entry.rawValue)",
          era: .soc,
          order: entry.timelineOrder ?? 0,
          title: entry.title,
          dateLabel: entry.timelineLabel ?? "SoC",
          symbolName: entry.symbolName,
          summary: entry.summary,
          lockedHint: entry.lockedHint,
          unlocked: SoCCodex.isUnlocked(entry, state: soc)
        ))
      }
    } else {
      events += placeholderSocEvents()
    }

    return events.sorted { $0.order < $1.order }
  }

  static func events(
    for product: AvasiaProduct,
    kon: GameState?,
    soc: SoCGameState?,
    anthology: AnthologyGameState?
  ) -> [SagaTimelineEvent] {
    let all = allEvents(kon: kon, soc: soc, anthology: anthology)
    switch product {
    case .kon:
      return all.filter { $0.era == .legend || $0.era == .kon }
    case .soc:
      return all.filter { $0.era == .gap || $0.era == .soc || ($0.era == .kon && $0.id == "kon.victory") }
    case .stories:
      return all
    }
  }

  static func unlockedCount(kon: GameState?, soc: SoCGameState?, anthology: AnthologyGameState?) -> Int {
    allEvents(kon: kon, soc: soc, anthology: anthology).filter(\.unlocked).count
  }

  static var totalCount: Int {
    KonCodexEntry.allCases.filter { $0.timelineOrder != nil }.count
      + gapEvents.count
      + SoCCodexEntry.allCases.filter { $0.timelineOrder != nil }.count
  }

  private static func placeholderKonEvents() -> [SagaTimelineEvent] {
    KonCodex.timelineEntries(for: GameState()).map { entry in
      SagaTimelineEvent(
        id: "kon.\(entry.rawValue)",
        era: entry == .schismLore ? .legend : .kon,
        order: entry.timelineOrder ?? 0,
        title: entry.title,
        dateLabel: entry == .schismLore ? "Before memory" : "KoN",
        symbolName: entry.symbolName,
        summary: entry.summary,
        lockedHint: entry.lockedHint,
        unlocked: false
      )
    }
  }

  private static func placeholderSocEvents() -> [SagaTimelineEvent] {
    SoCCodex.timelineEntries().map { entry in
      SagaTimelineEvent(
        id: "soc.\(entry.rawValue)",
        era: .soc,
        order: entry.timelineOrder ?? 0,
        title: entry.title,
        dateLabel: "SoC",
        symbolName: entry.symbolName,
        summary: entry.summary,
        lockedHint: entry.lockedHint,
        unlocked: false
      )
    }
  }
}
