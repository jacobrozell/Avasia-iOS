import Foundation
import AvasiaEngine

/// Python `mainloop` global commands — intercepted before room dispatch.
enum SoCGlobalCommands {
  static let helpTriggers = ["HELP", "COMMANDS"]
  static let inventoryTriggers = ["INVENTORY"]
  static let eatTriggers = ["EAT", "DRINK"]
  static let trophyTriggers = ["TROPHY", "TROPHIES", "ACHIEVEMENT", "ACHIEVEMENTS"]
  static let saveTriggers = ["SAVE"]

  /// Returns lines if handled; `nil` lets the room script run.
  static func handle(_ input: ParsedInput, state: inout SoCGameState) -> [StyledLine]? {
    guard !state.inCombat else { return nil }

    if helpTriggers.contains(where: { input.contains($0) }) {
      return [
        .hint("INVENTORY, EAT, SAVE, TROPHY"),
        .hint("Move with NORTH, EAST, SOUTH, WEST, LOOK, TALK…")
      ]
    }

    if inventoryTriggers.contains(where: { input.contains($0) }) {
      return inventoryLines(state)
    }

    if trophyTriggers.contains(where: { input.contains($0) }) {
      return trophyLines(state)
    }

    if saveTriggers.contains(where: { input.contains($0) }) {
      return [.body("Your game has been saved.")]
    }

    if eatTriggers.contains(where: { input.contains($0) }) {
      return eat(input, state: &state)
    }

    return nil
  }

  private static func inventoryLines(_ state: SoCGameState) -> [StyledLine] {
    var lines: [StyledLine] = [.body("Gold: \(state.gold)")]
    if state.inventory.isEmpty {
      lines.append(.body("(no items)"))
    } else {
      for item in SoCItem.allCases {
        guard let count = state.inventory[item], count > 0 else { continue }
        let label = count > 1 ? "\(item.displayName) x\(count)" : item.displayName
        lines.append(.body(label))
      }
    }
    if state.playerClass != .none {
      lines.append(.body(SoCQuestProgress.levelSummary(state)))
      lines.append(.body("HP: \(state.playerHp)/\(state.playerMaxHp)"))
    }
    return lines
  }

  private static func trophyLines(_ state: SoCGameState) -> [StyledLine] {
    guard !state.trophies.isEmpty else {
      return [.body("You haven't unlocked any trophies yet.")]
    }
    return state.trophies.sorted { $0.rawValue < $1.rawValue }.map {
      .symbol("✓ \($0.title)")
    }
  }

  private static func eat(_ input: ParsedInput, state: inout SoCGameState) -> [StyledLine] {
    guard state.playerClass != .none, state.playerMaxHp > 0 else {
      return [.body("You don't need food right now.")]
    }
    if state.playerHp >= state.playerMaxHp {
      return [.body("Health is full!")]
    }

    guard let item = matchingFood(in: input, state: state) else {
      var lines = inventoryLines(state)
      lines.append(.hint("What do you want to eat? (e.g. EAT POTION)"))
      return lines
    }

    guard state.removeItem(item) else {
      return [.body("Item not found!")]
    }
    let heal = item.healAmount ?? 0
    state.playerHp = min(state.playerMaxHp, state.playerHp + heal)
    return [
      .item("Health restored by \(heal)!"),
      .body("HP: \(state.playerHp)/\(state.playerMaxHp)")
    ]
  }

  private static func matchingFood(in input: ParsedInput, state: SoCGameState) -> SoCItem? {
    let norm = input.normalized
    for item in SoCItem.allCases {
      guard item.healAmount != nil, state.inventory[item, default: 0] > 0 else { continue }
      let key = item.displayName.uppercased().replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
      let compact = key.replacingOccurrences(of: " ", with: "")
      if norm.contains(compact) || norm.contains(item.rawValue.uppercased()) {
        return item
      }
      if item == .smallFish && norm.contains("SMALLFISH") { return item }
      if item == .bigFish && norm.contains("BIGFISH") { return item }
      if item == .oldShoe { continue }
    }
    return nil
  }
}
