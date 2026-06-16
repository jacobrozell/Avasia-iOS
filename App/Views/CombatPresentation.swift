import SwiftUI
import AvasiaEngine
import AvasiaSoCEngine
import AvasiaAnthologyEngine

/// UI-facing combat beats derived from engine state diffs (see `docs/COMBAT_UI.md`).
enum CombatPresentationEvent: Equatable {
    case combatBegan(enemyName: String)
    case combatEnded(victory: Bool)
    case playerDamaged(from: Int, to: Int, max: Int)
    case playerHealed(from: Int, to: Int, max: Int)
    case enemyDamaged(from: Int, to: Int, max: Int, name: String)
    case playerMiss
    case enemyMiss(name: String)
    case block(name: String)
    case lowHpWarning
    case expGained(amount: Int)
}

enum HealthBarFlash: Equatable {
    case damage
    case heal
}

enum CombatLineEmphasis: Equatable {
    case playerHit
    case playerDamaged
    case miss
    case block
    case kill
    case lowHp
    case heal
}

enum CombatTriggerAction: Equatable {
    case setPlayerHp(Int, flash: HealthBarFlash?)
    case setEnemyHp(Int, max: Int, name: String?)
    case setGold(Int, floatDelta: Int?)
    case emphasis(CombatLineEmphasis)
    case playSound(SoundCue)
    case haptic(HapticCue)
    case combatEnter
    case combatExit(victory: Bool)
    case bounceItem(SoCItem)
    case lowHpVignette
}

enum CombatTriggerMode {
    case soc
    case arena
}

/// Maps transcript line indices to presentation actions fired when pacing completes each line.
enum CombatTriggerPlanner {
    struct Plan {
        var events: [CombatPresentationEvent] = []
        var triggers: [Int: [CombatTriggerAction]] = [:]
    }

    static func planSoc(
        lines: [StyledLine],
        lineStartIndex: Int,
        hpBefore: Int,
        playerMaxHp: Int,
        enemyHpBefore: Int?,
        enemyMaxHp: Int?,
        enemyName: String?,
        goldBefore: Int,
        newItems: Set<SoCItem>,
        inCombatBefore: Bool,
        after: SoCGameState
    ) -> Plan {
        var plan = Plan()
        var playerHp = hpBefore
        var enemyHp = enemyHpBefore
        let enemyMax = enemyMaxHp ?? after.enemy?.maxHp ?? 0
        var gold = goldBefore

        if !inCombatBefore, after.inCombat, let enemy = after.enemy {
            plan.events.append(.combatBegan(enemyName: enemy.name))
            add(&plan, lineStartIndex, .combatEnter)
            add(&plan, lineStartIndex, .playSound(.combatStart))
            enemyHp = enemy.hp
        }

        for (offset, line) in lines.enumerated() {
            let idx = lineStartIndex + offset
            let text = line.text

            if text.contains("Health restored by") {
                playerHp = after.playerHp
                plan.events.append(.playerHealed(from: hpBefore, to: playerHp, max: playerMaxHp))
                add(&plan, idx, .setPlayerHp(playerHp, flash: .heal))
                add(&plan, idx, .emphasis(.heal))
                add(&plan, idx, .playSound(.heal))
            } else if text.contains("You strike"), text.contains("damage") {
                if let dmg = parseDamage(in: text, after: "for ") {
                    let before = enemyHp ?? 0
                    let next = max(0, before - dmg)
                    enemyHp = next
                    if let name = enemyName ?? after.enemy?.name {
                        plan.events.append(.enemyDamaged(from: before, to: next, max: enemyMax, name: name))
                    }
                    add(&plan, idx, .setEnemyHp(next, max: enemyMax, name: enemyName))
                    add(&plan, idx, .emphasis(.playerHit))
                    add(&plan, idx, .playSound(.hit))
                }
            } else if text.contains("hits you for") {
                if let dmg = parseDamage(in: text, after: "hits you for ") {
                    playerHp = max(0, playerHp - dmg)
                    plan.events.append(.playerDamaged(from: hpBefore, to: playerHp, max: playerMaxHp))
                    add(&plan, idx, .setPlayerHp(playerHp, flash: .damage))
                    add(&plan, idx, .emphasis(.playerDamaged))
                    add(&plan, idx, .playSound(.hit))
                    add(&plan, idx, .haptic(.impactLight))
                }
            } else if text.hasSuffix("Miss.") {
                plan.events.append(.playerMiss)
                add(&plan, idx, .emphasis(.miss))
                add(&plan, idx, .playSound(.miss))
            } else if text.contains("turn the blow aside")
                || text.contains("glances off your guard")
                || text.contains("dodge clear") {
                let name = enemyName ?? after.enemy?.name ?? "Foe"
                plan.events.append(.enemyMiss(name: name))
                add(&plan, idx, .emphasis(.miss))
                add(&plan, idx, .playSound(.miss))
            } else if text.contains("absorbs the blow") {
                let name = enemyName ?? after.enemy?.name ?? "Foe"
                plan.events.append(.block(name: name))
                add(&plan, idx, .emphasis(.block))
                add(&plan, idx, .playSound(.block))
            } else if text.contains("You killed") {
                add(&plan, idx, .emphasis(.kill))
                add(&plan, idx, .playSound(.victory))
                add(&plan, idx, .haptic(.notify))
            } else if text.contains("Blood runs hot") {
                plan.events.append(.lowHpWarning)
                add(&plan, idx, .emphasis(.lowHp))
                add(&plan, idx, .lowHpVignette)
                add(&plan, idx, .haptic(.warning))
            } else if text.hasPrefix("You gain "), text.contains(" exp!") {
                let digits = text.dropFirst("You gain ".count).prefix(while: \.isNumber)
                if let amount = Int(digits) {
                    plan.events.append(.expGained(amount: amount))
                }
            }

            if let parsedGold = parseGoldLine(text) {
                let delta = parsedGold > gold ? parsedGold - gold : nil
                gold = parsedGold
                add(&plan, idx, .setGold(parsedGold, floatDelta: delta))
            }
        }

        if inCombatBefore, !after.inCombat {
            let victory = after.playerHp > 0 && lines.contains { $0.text.contains("You killed") }
            plan.events.append(.combatEnded(victory: victory))
            let exitIndex = lineStartIndex + max(lines.count - 1, 0)
            add(&plan, exitIndex, .combatExit(victory: victory))
            if victory {
                add(&plan, exitIndex, .playSound(.victory))
            }
        }

        for item in newItems {
            if let idx = lines.firstIndex(where: { $0.style == .item || $0.text.localizedCaseInsensitiveContains(item.displayName) }) {
                add(&plan, lineStartIndex + idx, .bounceItem(item))
            }
        }

        return plan
    }

    static func planArena(
        lines: [StyledLine],
        lineStartIndex: Int,
        hpBefore: Int,
        maxHp: Int,
        enemyHpBefore: Int,
        enemyMaxHp: Int,
        enemyName: String,
        goldBefore: Int,
        inCombatBefore: Bool,
        after: AnthologyGameState
    ) -> Plan {
        var plan = Plan()
        var playerHp = hpBefore
        var enemyHp = enemyHpBefore
        var gold = goldBefore

        if !inCombatBefore, after.arenaInCombat {
            plan.events.append(.combatBegan(enemyName: enemyName))
            add(&plan, lineStartIndex, .combatEnter)
            add(&plan, lineStartIndex, .playSound(.combatStart))
        }

        for (offset, line) in lines.enumerated() {
            let idx = lineStartIndex + offset
            let text = line.text

            if text.hasPrefix("You strike for "), let dmg = parseDamage(in: text, after: "You strike for ") {
                let before = enemyHp
                enemyHp = max(0, before - dmg)
                plan.events.append(.enemyDamaged(from: before, to: enemyHp, max: enemyMaxHp, name: enemyName))
                add(&plan, idx, .setEnemyHp(enemyHp, max: enemyMaxHp, name: enemyName))
                add(&plan, idx, .emphasis(.playerHit))
                add(&plan, idx, .playSound(.hit))
            } else if text.contains("hits you for"), let dmg = parseDamage(in: text, after: "hits you for ") {
                playerHp = max(0, playerHp - dmg)
                plan.events.append(.playerDamaged(from: hpBefore, to: playerHp, max: maxHp))
                add(&plan, idx, .setPlayerHp(playerHp, flash: .damage))
                add(&plan, idx, .emphasis(.playerDamaged))
                add(&plan, idx, .playSound(.hit))
                add(&plan, idx, .haptic(.impactLight))
            } else if text.contains("falls.") {
                add(&plan, idx, .emphasis(.kill))
                add(&plan, idx, .playSound(.victory))
                add(&plan, idx, .haptic(.notify))
            } else if text.contains("training gold") {
                let earned = parseEarnedGold(text) ?? parseLeadingPlusAmount(text)
                if let earned {
                    gold = goldBefore + earned
                    add(&plan, idx, .setGold(after.anthologyGold, floatDelta: earned))
                } else if gold != after.anthologyGold {
                    let delta = after.anthologyGold > goldBefore ? after.anthologyGold - goldBefore : nil
                    gold = after.anthologyGold
                    add(&plan, idx, .setGold(after.anthologyGold, floatDelta: delta))
                }
            }
        }

        if inCombatBefore, !after.arenaInCombat {
            let victory = after.arenaHp > 0
            plan.events.append(.combatEnded(victory: victory))
            let exitIndex = lineStartIndex + max(lines.count - 1, 0)
            add(&plan, exitIndex, .combatExit(victory: victory))
        }

        return plan
    }

    private static func add(_ plan: inout Plan, _ index: Int, _ action: CombatTriggerAction) {
        plan.triggers[index, default: []].append(action)
    }

    private static func parseDamage(in text: String, after marker: String) -> Int? {
        guard let range = text.range(of: marker) else { return nil }
        let digits = text[range.upperBound...].prefix(while: \.isNumber)
        return Int(digits)
    }

    private static func parseGoldLine(_ text: String) -> Int? {
        guard text.hasPrefix("Gold: ") else { return nil }
        let digits = text.dropFirst("Gold: ".count).prefix(while: \.isNumber)
        return Int(digits)
    }

    private static func parseLeadingPlusAmount(_ text: String) -> Int? {
        guard text.hasPrefix("+") else { return nil }
        let digits = text.dropFirst().prefix(while: \.isNumber)
        return Int(digits)
    }

    private static func parseEarnedGold(_ text: String) -> Int? {
        guard let range = text.range(of: "earned ") else { return nil }
        let digits = text[range.upperBound...].prefix(while: \.isNumber)
        return Int(digits)
    }
}

/// Compact HP readout for the status strip — bar fill and number tween on change.
struct AnimatedHealthBar: View {
    let value: Int
    let maxHp: Int
    var flash: HealthBarFlash?
    var systemImage: String = "heart.fill"
    var barWidth: CGFloat = 56

    @State private var displayed: Double
    @State private var heartScale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        value: Int,
        max: Int,
        flash: HealthBarFlash? = nil,
        systemImage: String = "heart.fill",
        barWidth: CGFloat = 56
    ) {
        self.value = value
        self.maxHp = max
        self.flash = flash
        self.systemImage = systemImage
        self.barWidth = barWidth
        _displayed = State(initialValue: Double(value))
    }

    private var fraction: Double {
        guard maxHp > 0 else { return 0 }
        return min(max(displayed / Double(maxHp), 0), 1)
    }

    private var shownHp: Int { Int(displayed.rounded()) }

    private var fillColor: Color {
        let ratio = maxHp > 0 ? Double(value) / Double(maxHp) : 1
        if ratio <= 0.25 { return .red }
        if ratio <= 0.5 { return .orange }
        return Theme.accent
    }

    private var heartColor: Color {
        switch flash {
        case .damage: return .red
        case .heal: return .green
        case nil: return fillColor
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption2)
                .foregroundColor(heartColor)
                .scaleEffect(heartScale)
                .accessibilityHidden(systemImage != "heart.fill")

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.palette.cardFill)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [fillColor, fillColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * fraction, fraction > 0 ? 3 : 0))
                }
            }
            .frame(width: barWidth, height: 5)

            Text("\(shownHp)/\(maxHp)")
                .font(.caption2.monospacedDigit())
                .foregroundColor(Theme.parchment)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Health")
        .accessibilityValue("\(value) of \(maxHp)")
        .onAppear { syncDisplayed(animated: false) }
        .onChange(of: value) { _ in syncDisplayed(animated: true) }
        .onChange(of: flash) { newFlash in
            guard newFlash != nil else { return }
            pulseHeart()
        }
    }

    private func syncDisplayed(animated: Bool) {
        let target = Double(value)
        guard displayed != target else { return }
        if animated && !reduceMotion {
            withAnimation(.easeOut(duration: 0.45)) {
                displayed = target
            }
        } else {
            displayed = target
        }
    }

    private func pulseHeart() {
        guard !reduceMotion else { return }
        withAnimation(.easeOut(duration: 0.12)) { heartScale = 1.18 }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 180_000_000)
            withAnimation(.easeOut(duration: 0.15)) { heartScale = 1 }
        }
    }
}

struct CombatEnemyStatus: View {
    let name: String
    let hp: Int
    let maxHp: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill")
                .font(.caption2)
                .foregroundColor(.red.opacity(0.85))
            Text(name)
                .font(.caption2.weight(.semibold))
                .foregroundColor(Theme.parchment)
                .lineLimit(1)
            AnimatedHealthBar(
                value: hp,
                max: maxHp,
                systemImage: "figure.stand",
                barWidth: 48
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name) health")
        .accessibilityValue("\(hp) of \(maxHp)")
    }
}

struct AnimatedGoldLabel: View {
    let value: Int
    var floatDelta: Int?

    @State private var displayed: Double
    @State private var floatOpacity: Double = 0
    @State private var floatOffset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(value: Int, floatDelta: Int? = nil) {
        self.value = value
        self.floatDelta = floatDelta
        _displayed = State(initialValue: Double(value))
    }

    var body: some View {
        ZStack(alignment: .top) {
            if let delta = floatDelta, delta > 0 {
                Text("+\(delta)")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(Theme.accent)
                    .opacity(floatOpacity)
                    .offset(y: floatOffset)
                    .accessibilityHidden(true)
            }
            Label("\(Int(displayed.rounded()))", systemImage: "circle.fill")
                .font(.caption2.monospacedDigit())
                .foregroundColor(Theme.accent)
        }
        .accessibilityLabel("Gold \(value)")
        .onAppear { sync(animated: false) }
        .onChange(of: value) { _ in sync(animated: true) }
        .onChange(of: floatDelta) { delta in
            guard let delta, delta > 0, !reduceMotion else { return }
            floatOpacity = 1
            floatOffset = 0
            withAnimation(.easeOut(duration: 0.55)) {
                floatOffset = -14
                floatOpacity = 0
            }
        }
    }

    private func sync(animated: Bool) {
        let target = Double(value)
        guard displayed != target else { return }
        if animated && !reduceMotion {
            withAnimation(.easeOut(duration: 0.35)) { displayed = target }
        } else {
            displayed = target
        }
    }
}

struct ItemBounceIcon: View {
    let systemImage: String
    let bounce: Bool

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Image(systemName: systemImage)
                    .foregroundColor(Theme.parchment)
                    .symbolEffect(.bounce, value: bounce)
            } else {
                Image(systemName: systemImage)
                    .foregroundColor(Theme.parchment)
                    .scaleEffect(bounce ? 1.2 : 1)
                    .animation(.spring(response: 0.35), value: bounce)
            }
        }
    }
}
