import Foundation
import AvasiaEngine

public enum AnthologyTrainingUpgrade: String, Codable, CaseIterable, Sendable {
    case sturdyBoots
    case whetstone
    case trainingMail
}

public struct AnthologyTrainingUpgradeMeta: Sendable {
    public let id: AnthologyTrainingUpgrade
    public let title: String
    public let cost: Int
    public let detail: String
    public let buyVerb: String

    public init(id: AnthologyTrainingUpgrade, title: String, cost: Int, detail: String, buyVerb: String) {
        self.id = id
        self.title = title
        self.cost = cost
        self.detail = detail
        self.buyVerb = buyVerb
    }
}

public enum AnthologyTrainingShop {
    public static let upgrades: [AnthologyTrainingUpgradeMeta] = [
        AnthologyTrainingUpgradeMeta(
            id: .sturdyBoots,
            title: "Sturdy Boots",
            cost: 40,
            detail: "+5 max HP between waves.",
            buyVerb: "BOOTS"
        ),
        AnthologyTrainingUpgradeMeta(
            id: .whetstone,
            title: "Whetstone",
            cost: 60,
            detail: "Training strikes hit harder (3–6 damage).",
            buyVerb: "WHETSTONE"
        ),
        AnthologyTrainingUpgradeMeta(
            id: .trainingMail,
            title: "Training Mail",
            cost: 80,
            detail: "Enemy hits deal −1 damage (min 1).",
            buyVerb: "MAIL"
        )
    ]

    public static func owns(_ upgrade: AnthologyTrainingUpgrade, state: AnthologyGameState) -> Bool {
        state.arenaUpgrades.contains(upgrade)
    }

    public static func canBuy(_ upgrade: AnthologyTrainingUpgrade, state: AnthologyGameState) -> (allowed: Bool, reason: String?) {
        if owns(upgrade, state: state) {
            return (false, "Already owned.")
        }
        let meta = meta(for: upgrade)
        if state.anthologyGold < meta.cost {
            return (false, "Need \(meta.cost) gold — you have \(state.anthologyGold).")
        }
        return (true, nil)
    }

    public static func meta(for upgrade: AnthologyTrainingUpgrade) -> AnthologyTrainingUpgradeMeta {
        upgrades.first { $0.id == upgrade }!
    }

    @discardableResult
    public static func purchase(_ upgrade: AnthologyTrainingUpgrade, state: inout AnthologyGameState) -> [StyledLine] {
        let (allowed, reason) = canBuy(upgrade, state: state)
        guard allowed else {
            return [.body(reason ?? "Cannot buy that.")]
        }
        let meta = meta(for: upgrade)
        state.anthologyGold -= meta.cost
        state.arenaUpgrades.insert(upgrade)
        return [
            .title("Purchased"),
            .body("\(meta.title) — \(meta.detail)"),
            .body("Gold remaining: \(state.anthologyGold)")
        ]
    }

    public static func shopLines(state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Training Shop"),
            .body("Gold: \(state.anthologyGold)"),
            .body("Gear persists for every arena run."),
            .blank
        ]
        for meta in upgrades {
            let owned = owns(meta.id, state: state)
            let tag = owned ? " ✓ owned" : " — \(meta.cost) gold"
            lines.append(.body("\(meta.title)\(tag)"))
            lines.append(.hint("  \(meta.detail)"))
        }
        lines.append(.body("Ring Pass — \(AnthologyRingPass.shopCost) gold (stackable)"))
        lines.append(.hint("  Excuse one FP story unlock. One free pass per day at the hub."))
        if state.ringPasses > 0 {
            lines.append(.body("Passes held: \(state.ringPasses)"))
        }
        lines.append(.blank)
        lines.append(.hint("BUY BOOTS · BUY WHETSTONE · BUY MAIL · BUY PASS · LEAVE"))
        return lines
    }

    public static func upgradeFromBuyCommand(_ input: ParsedInput) -> AnthologyTrainingUpgrade? {
        if input.contains("BOOTS") || input.contains("HP") { return .sturdyBoots }
        if input.contains("WHETSTONE") || input.contains("BLADE") { return .whetstone }
        if input.contains("MAIL") || input.contains("ARMOR") { return .trainingMail }
        return nil
    }
}

struct AnthologyTrainingShopRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .trainingShop

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        AnthologyTrainingShop.shopLines(state: state)
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LEAVE") || input.contains("EXIT") || input.contains("BACK") || input.contains("HUB") {
            return AnthologyTurnResult([.body("Back to Story Adventures.")], .move(.storyHub))
        }
        if input.contains("BUY") {
            if input.contains("PASS") || input.contains("RING") {
                let lines = AnthologyRingPass.purchase(state: &state)
                return AnthologyTurnResult(lines + AnthologyTrainingShop.shopLines(state: state))
            }
            if let upgrade = AnthologyTrainingShop.upgradeFromBuyCommand(input) {
                let lines = AnthologyTrainingShop.purchase(upgrade, state: &state)
                return AnthologyTurnResult(lines + AnthologyTrainingShop.shopLines(state: state))
            }
            return AnthologyTurnResult([.hint("BUY BOOTS · BUY WHETSTONE · BUY MAIL · BUY PASS")])
        }
        if input.contains("LIST") || input.contains("SHOP") {
            return AnthologyTurnResult(AnthologyTrainingShop.shopLines(state: state))
        }
        return AnthologyTurnResult([.hint("BUY an upgrade · LEAVE for the hub.")])
    }
}

enum AnthologyTrainingShopLauncher {
    static func enter(state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard state.storyZeroComplete else {
            return AnthologyTurnResult([.body("Finish Scout Patrol before visiting the training shop.")])
        }
        return AnthologyTurnResult(
            [.body("The quartermaster's tent smells of leather and sand.")],
            .move(.trainingShop)
        )
    }
}
