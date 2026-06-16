import SwiftUI
import AvasiaEngine
import AvasiaSoCEngine
import AvasiaAnthologyEngine

/// The main play screen: scrolling transcript, an input bar, quick-action chips,
/// and a status strip showing spells/items and the death counter. Mirrors the
/// wireframe in docs/WIREFRAMES.md.
struct GameView: View {
    @EnvironmentObject var vm: GameViewModel
    @Environment(\.layoutMetrics) private var metrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var inputFocused: Bool
    @State private var playEntered = false

    private let defaultQuickVerbs = [
        "North", "East", "South", "West", "Up", "Down",
        "Left", "Right", "Look", "Talk", "Take", "Continue"
    ]

    private var quickVerbs: [String] {
        if vm.product == .stories {
            if vm.anthologyState.currentRoom == .storyHub {
                return ["Choose Story", "Arena", "Shop", "List"]
            }
            if vm.anthologyState.currentRoom == .trainingShop {
                return ["Buy Boots", "Buy Whetstone", "Buy Mail", "Buy Pass", "Leave"]
            }
            if vm.anthologyState.currentRoom == .arenaPit, vm.anthologyState.arenaInCombat {
                return ["Attack", "Continue"]
            }
            if vm.anthologyState.currentRoom == .caveRecordArchive, !vm.anthologyState.caveRecordArchiveResolved {
                return ["Copy", "Leave", "Continue"]
            }
            if vm.anthologyState.currentRoom == .scoutRidge {
                return ["Withdraw", "Continue", "Talk", "Look"]
            }
            if vm.anthologyState.currentRoom == .scoutFork, !vm.anthologyState.forkResolved {
                return ["Report", "Follow", "Refuse", "Look", "Talk"]
            }
            if vm.anthologyState.currentRoom == .goodOnePier, !vm.anthologyState.goodOnePierResolved {
                return ["Evacuate", "Hold", "Continue"]
            }
            if vm.anthologyState.currentRoom == .badOneRecon, !vm.anthologyState.badOneReconResolved {
                return ["Report", "Lie", "Continue"]
            }
            if vm.anthologyState.currentRoom == .goodTwoNacastrumGate, !vm.anthologyState.goodTwoGateResolved {
                return ["Full", "Soften", "Continue"]
            }
            if vm.anthologyState.currentRoom == .badTwoBriefing, !vm.anthologyState.badTwoBriefingResolved {
                return ["Full", "Sanitize", "Continue"]
            }
            if vm.anthologyState.currentRoom == .goodThreeVerdict, !vm.anthologyState.goodThreeVerdictResolved {
                return ["Petition", "Withhold", "Continue"]
            }
            if vm.anthologyState.currentRoom == .badThreeOath, !vm.anthologyState.badThreeOathResolved {
                return ["Swear", "Refuse", "Continue"]
            }
            if vm.anthologyState.currentRoom == .neutralThreeSchismStall, !vm.anthologyState.neutralThreeStallResolved {
                return ["Broker", "Lean", "Continue"]
            }
            if vm.anthologyState.currentRoom == .goodFourBriefing, !vm.anthologyState.goodFourBriefingResolved {
                return ["Hold", "Push", "Continue"]
            }
            if vm.anthologyState.currentRoom == .badFourGate, !vm.anthologyState.badFourGateResolved {
                return ["Burn", "Storm", "Continue"]
            }
            if vm.anthologyState.currentRoom == .neutralFourCrowd, !vm.anthologyState.neutralFourCrowdResolved {
                return ["Witness", "Walk", "Continue"]
            }
            if vm.anthologyState.currentRoom == .goodFiveWitnessStone, !vm.anthologyState.goodFiveStoneResolved {
                return ["Swear", "Refuse", "Continue"]
            }
            if vm.anthologyState.currentRoom == .badFiveCommandFire, !vm.anthologyState.badFiveCommandResolved {
                return ["Accept", "Decline", "Continue"]
            }
            if vm.anthologyState.currentRoom == .neutralFiveMileMarker, !vm.anthologyState.neutralFiveRoadResolved {
                return ["Leave", "Stay", "Continue"]
            }
            if vm.anthologyState.currentRoom == .goodSixSigningFloor, !vm.anthologyState.goodSixAccordResolved {
                return ["Sign", "Walk", "Continue"]
            }
            if vm.anthologyState.currentRoom == .badSixThroneRoom, !vm.anthologyState.badSixThroneResolved {
                return ["Rule", "Yield", "Continue"]
            }
            if vm.anthologyState.currentRoom == .neutralSixBindingRoom, !vm.anthologyState.neutralSixLedgerResolved {
                return ["Publish", "Seal", "Continue"]
            }
            return ["Continue", "Look", "Talk"]
        }
        guard vm.product == .soc else { return defaultQuickVerbs }
        if vm.socIsConfirmingName { return ["Yes", "No"] }
        if vm.socIsNaming { return [] }
        if vm.socState.inCombat {
            var verbs = ["Attack", "Eat Potion", "Objectives", "Inventory"]
            if vm.socState.combatAllowsFlee || vm.socState.playerClass == .scout {
                verbs.insert("Flee", at: 2)
            }
            return verbs
        }
        switch vm.socState.currentRoom {
        case .oceandaleFront where vm.socState.oceandaleFrontCleared:
            return ["Advance", "Continue", "Inventory"]
        case .mageOutpost where vm.socState.mageOutpostCleared,
             .vashirrStand where vm.socState.vashirrDefeated:
            return ["March", "Continue", "Inventory"]
        case .throneRoom where vm.socState.throneAudience:
            return ["March", "Continue", "Inventory"]
        case .ageEpilogue where vm.socState.gameComplete && !vm.socState.ruinsVisited:
            return ["Visit Ruins", "Continue", "Inventory"]
        case .aylovaWarCamp, .silvariumElders, .varatroFalls, .ofelos,
             .northernMarch, .oceandaleFront, .mageOutpost, .vashirrStand, .ageEpilogue:
            var verbs = ["March", "Continue", "Inventory", "Look"]
            if let ingenuity = SoCClassIngenuity.quickVerb(for: vm.socState) {
                verbs.insert(ingenuity, at: 1)
            }
            return verbs
        case .cataractaHousing, .cataractaNorth, .cataractaShopping, .cataractaGarden,
             .cataractaBarracks, .cataractaHunterPath:
            return ["North", "East", "South", "West", "Look", "Continue", "Inventory", "Objectives"]
        default:
            return ["North", "East", "South", "West", "Look", "Continue", "Inventory"]
        }
    }

    var body: some View {
        ZStack {
            RegionBackground(media: vm.media)
            if metrics.usesSplitGameLayout {
                splitLayout(metrics)
            } else {
                stackedLayout(metrics)
            }
        }
        .overlay(alignment: .top) { toastOverlay(metrics) }
        .overlay { if vm.pendingDeath { deathOverlay(metrics) } }
        .overlay { if vm.pendingLevelUp != nil { levelUpOverlay(metrics) } }
        .sheet(isPresented: $vm.showStoryPicker) {
            StoryPickerView()
                .environmentObject(vm)
        }
        .onChange(of: vm.screen) { screen in
            if screen != .game {
                playEntered = false
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button { dismissKeyboard() } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
                .accessibilityLabel("Dismiss keyboard")
            }
        }
    }

    private func dismissKeyboard() {
        inputFocused = false
    }

    // MARK: - Layouts

    private func stackedLayout(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 0) {
            if !metrics.usesCompactStatusStrip {
                regionIllustration(metrics)
            }
            statusArea(metrics, vertical: metrics.usesCompactStatusStrip)
            Divider().background(Theme.accent.opacity(0.4))
            transcript
                .layoutPriority(1)
                .background(transcriptBackground)
                .playScreenEnter($playEntered)
            quickActions(metrics)
            inputBar(metrics)
        }
    }

    private func splitLayout(_ metrics: LayoutMetrics) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                regionIllustration(metrics)
                statusArea(metrics, vertical: true)
                Spacer(minLength: 0)
            }
            .frame(width: metrics.gameSidebarWidth)

            Divider().background(Theme.accent.opacity(0.4))

            VStack(spacing: 0) {
                transcript
                    .layoutPriority(1)
                    .background(transcriptBackground)
                    .playScreenEnter($playEntered)
                quickActions(metrics)
                inputBar(metrics)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: metrics.gameContentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    private func regionIllustration(_ metrics: LayoutMetrics) -> some View {
        RegionIllustration(media: vm.media, height: metrics.illustrationHeight)
            .offset(y: playEntered || reduceMotion ? 0 : -8)
            .animation(Motion.accessible(.easeOut(duration: 0.28), reduceMotion: reduceMotion), value: playEntered)
    }

    // MARK: - Status strip

    private var showsCombatEnemyRow: Bool {
        vm.combatStripVisible && !vm.displayedEnemyName.isEmpty
    }

    private var combatInteractionLocked: Bool {
        vm.isCombatBusy && (
            (vm.product == .soc && vm.socState.inCombat)
                || (vm.product == .stories && vm.anthologyState.arenaInCombat)
        )
    }

    private func statusArea(_ metrics: LayoutMetrics, vertical: Bool = false) -> some View {
        VStack(spacing: 6) {
            statusStrip(metrics, vertical: vertical)
            if showsCombatEnemyRow {
                combatEnemyRow(metrics)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .overlay {
            if vm.lowHpVignette {
                Color.red.opacity(0.12)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeOut(duration: 0.28), value: vm.combatStripVisible)
    }

    private func combatEnemyRow(_ metrics: LayoutMetrics) -> some View {
        CombatEnemyStatus(
            name: vm.displayedEnemyName,
            hp: vm.displayedEnemyHp,
            maxHp: max(vm.displayedEnemyMaxHp, 1)
        )
        .padding(.horizontal, metrics.horizontalPadding)
    }

    private func statusStrip(_ metrics: LayoutMetrics, vertical: Bool = false) -> some View {
        Group {
            if vertical {
                VStack(alignment: .leading, spacing: 10) {
                    statusControls(compact: true)
                    Divider().background(Theme.accent.opacity(0.25))
                    statusInventory
                    Divider().background(Theme.accent.opacity(0.25))
                    Text("☠ \(vm.displayDeathCount)")
                        .font(.caption2)
                        .foregroundColor(Theme.parchment.opacity(0.6))
                        .accessibilityLabel("Death count \(vm.displayDeathCount)")
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        statusControls(compact: false)
                        statusInventory
                        Text("☠ \(vm.displayDeathCount)")
                            .font(.caption2)
                            .foregroundColor(Theme.parchment.opacity(0.6))
                            .accessibilityLabel("Death count \(vm.displayDeathCount)")
                    }
                    .padding(.horizontal, metrics.horizontalPadding)
                }
            }
        }
        .padding(.vertical, vertical ? 6 : 8)
        .padding(.horizontal, vertical ? metrics.horizontalPadding : 0)
    }

    private func statusControls(compact: Bool) -> some View {
        Group {
            if compact {
                VStack(alignment: .leading, spacing: 8) {
                    statusControlButtons
                    anthologyHubButtons
                    combatBadges
                }
            } else {
                HStack(spacing: 14) {
                    statusControlButtons
                    anthologyHubButtons
                    combatBadges
                }
            }
        }
    }

    private var statusControlButtons: some View {
        HStack(spacing: 14) {
            Button { vm.screen = .title } label: {
                Image(systemName: "list.bullet").foregroundColor(Theme.accent)
            }
            .accessibilityLabel("Main menu")

            if AppSettings.chroniclerShowThisRunXP, vm.sagaProfile.currentRunXP > 0 {
                Button { vm.openChroniclerLedger(from: .game) } label: {
                    Text("This run: +\(vm.sagaProfile.currentRunXP) XP")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityLabel("This run chronicler experience \(vm.sagaProfile.currentRunXP)")
            }

            if vm.product == .kon || vm.product == .soc {
                Button { vm.openCodex(from: .game) } label: {
                    Image(systemName: "book.closed.fill").foregroundColor(Theme.accent)
                }
                .accessibilityLabel("Journal")
            }

            Button {
                switch vm.product {
                case .kon: vm.openAchievements(from: .game)
                case .soc: vm.openTrophies(from: .game)
                case .stories: break
                }
            } label: {
                Image(systemName: "trophy").foregroundColor(Theme.accent)
            }
            .accessibilityLabel(vm.product == .kon ? "Achievements" : "Trophies")
            .opacity(vm.product == .stories ? 0.35 : 1)
            .disabled(vm.product == .stories)
            .accessibilityHidden(vm.product == .stories)
        }
    }

    @ViewBuilder
    private var anthologyHubButtons: some View {
        if vm.product == .stories, vm.anthologyState.currentRoom == .storyHub {
            HStack(spacing: 10) {
                Button { vm.openStoryPicker() } label: {
                    Label("Stories", systemImage: "book.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityIdentifier("anthology-choose-story")
                .accessibilityLabel("Choose story")
                Button { vm.launchArena() } label: {
                    Label("Arena", systemImage: "figure.fencing")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityIdentifier("anthology-arena")
                .accessibilityLabel("Arena")
                .disabled(!vm.anthologyState.storyZeroComplete)
                Button { vm.openTrainingShop() } label: {
                    Label("Shop", systemImage: "bag.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityIdentifier("anthology-shop")
                .accessibilityLabel("Shop")
                .disabled(!vm.anthologyState.storyZeroComplete)
            }
        }
    }

    @ViewBuilder
    private var combatBadges: some View {
        if vm.product == .soc, vm.socState.inCombat || vm.combatStripVisible {
            StatusBadge(title: "Combat", systemImage: "bolt.fill", tint: .red)
                .scaleEffect(vm.combatStripVisible ? 1 : 0.9)
                .animation(.spring(response: 0.32), value: vm.combatStripVisible)
        }
        if vm.product == .stories, vm.anthologyState.arenaInCombat || vm.combatStripVisible {
            StatusBadge(title: "Arena", systemImage: "figure.fencing", tint: .red)
                .scaleEffect(vm.combatStripVisible ? 1 : 0.9)
                .animation(.spring(response: 0.32), value: vm.combatStripVisible)
        }
    }

    private var statusInventory: some View {
        Group {
            if vm.product == .kon {
                HStack(spacing: 14) {
                    ForEach(vm.konState.spells, id: \.self) { spell in
                        Label(spell.displayName, systemImage: "sparkles")
                            .font(.caption2)
                            .foregroundColor(Theme.accent)
                            .accessibilityLabel("Spell \(spell.displayName)")
                    }
                    ForEach(vm.konState.items, id: \.self) { item in
                        Image(systemName: icon(for: item))
                            .foregroundColor(Theme.parchment)
                            .accessibilityLabel(itemAccessibilityLabel(item))
                    }
                }
            } else if vm.product == .soc {
                HStack(spacing: 14) {
                    if vm.socState.playerClass != .none {
                        Label("Lv \(vm.socState.playerLevel)", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.accent)
                            .accessibilityLabel("Level \(vm.socState.playerLevel)")
                        AnimatedHealthBar(
                            value: vm.displayedPlayerHp,
                            max: vm.socState.playerMaxHp,
                            flash: vm.healthBarFlash
                        )
                    }
                    AnimatedGoldLabel(
                        value: vm.displayedGold,
                        floatDelta: vm.goldFloatDelta
                    )
                    ForEach(socItems, id: \.self) { item in
                        ItemBounceIcon(
                            systemImage: socIcon(for: item),
                            bounce: vm.bouncingSocItems.contains(item)
                        )
                        .accessibilityLabel(item.displayName)
                    }
                }
            } else if vm.product == .stories {
                HStack(spacing: 14) {
                    if vm.anthologyState.arenaRunActive || vm.anthologyState.arenaInCombat {
                        AnimatedHealthBar(
                            value: vm.displayedPlayerHp,
                            max: vm.anthologyState.arenaMaxHp,
                            flash: vm.healthBarFlash
                        )
                        AnimatedGoldLabel(
                            value: vm.displayedGold,
                            floatDelta: vm.goldFloatDelta
                        )
                    }
                    if vm.anthologyState.alignment != .none {
                        Label(vm.anthologyState.alignment.rawValue, systemImage: "flag.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.accent)
                            .accessibilityLabel("Alignment \(vm.anthologyState.alignment.rawValue)")
                    }
                }
            }
        }
    }

    private var socItems: [SoCItem] {
        SoCItem.allCases.filter { vm.socState.inventory[$0, default: 0] > 0 }
    }

    private func socIcon(for item: SoCItem) -> String {
        switch item {
        case .potion: return "cross.vial.fill"
        case .fieldRations: return "takeoutbag.and.cup.and.straw.fill"
        case .smallFish, .bigFish: return "fish.fill"
        case .crab: return "leaf.fill"
        case .oldShoe: return "shoe.fill"
        case .bladeOfCourage: return "shield.lefthalf.filled"
        }
    }

    // MARK: - Transcript & actions

    private var transcriptBackground: some View {
        ParchmentBackground()
    }

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(vm.visibleTranscriptLines) { entry in
                        LineView(
                            line: entry.line,
                            partialLength: entry.partialLength,
                            showsCursor: entry.showsCursor,
                            emphasis: entry.emphasis,
                            playReveal: entry.playReveal
                        )
                        .id(entry.id)
                    }
                    if vm.isPacingWaiting {
                        HStack(spacing: 6) {
                            Image(systemName: "hand.tap.fill")
                                .font(.caption2)
                                .foregroundColor(Theme.accent.opacity(0.7))
                            Text("Tap to continue")
                                .font(.caption)
                                .foregroundColor(Theme.parchment.opacity(0.45))
                                .italic()
                        }
                        .id("pacing-hint")
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Tap to continue")
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                    vm.advancePacing()
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Game transcript")
            .onChange(of: vm.completedLineCount) { _ in scrollTranscript(proxy) }
            .onChange(of: vm.typingVisibleCount) { _ in scrollTranscript(proxy) }
            .onChange(of: vm.isPacingWaiting) { waiting in
                if waiting {
                    withAnimation { proxy.scrollTo("pacing-hint", anchor: .bottom) }
                }
            }
        }
    }

    private func scrollTranscript(_ proxy: ScrollViewProxy) {
        if let last = vm.visibleTranscriptLines.last?.id {
            withAnimation(.easeOut(duration: 0.15)) { proxy.scrollTo(last, anchor: .bottom) }
        } else if vm.isPacingWaiting {
            withAnimation { proxy.scrollTo("pacing-hint", anchor: .bottom) }
        }
    }

    private func quickActions(_ metrics: LayoutMetrics) -> some View {
        Group {
            if quickVerbs.isEmpty {
                EmptyView()
            } else if metrics.usesWrappedQuickActions {
                Group {
                    if let maxHeight = metrics.quickActionsMaxHeight {
                        ScrollView {
                            quickActionsGrid(metrics)
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .frame(maxHeight: maxHeight)
                    } else {
                        quickActionsGrid(metrics)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickVerbs, id: \.self) { verb in
                            quickActionButton(verb, metrics: metrics)
                        }
                    }
                    .padding(.horizontal, metrics.horizontalPadding)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Quick actions")
    }

    private func quickActionsGrid(_ metrics: LayoutMetrics) -> some View {
        let columns = metrics.isAccessibilityText
            ? [GridItem(.flexible()), GridItem(.flexible())]
            : [GridItem(.adaptive(minimum: 88, maximum: 130), spacing: 8)]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(quickVerbs, id: \.self) { verb in
                quickActionButton(verb, metrics: metrics)
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
    }

    private func quickActionButton(_ verb: String, metrics: LayoutMetrics) -> some View {
        Button(verb) {
            dismissKeyboard()
            HapticManager.shared.play(.tap)
            vm.quickAction(verb)
        }
            .font(metrics.isAccessibilityText ? .body : .caption)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Theme.accent.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.accent.opacity(0.22), lineWidth: 1))
            .foregroundColor(Theme.parchment)
            .buttonStyle(PressScaleButtonStyle())
            .disabled(combatInteractionLocked)
            .opacity(combatInteractionLocked ? 0.5 : 1)
            .accessibilityLabel(verb)
            .accessibilityHint("Submit \(verb.lowercased()) command")
    }

    private func inputBar(_ metrics: LayoutMetrics) -> some View {
        HStack(spacing: 10) {
            TextField("What do you do?", text: $vm.input)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($inputFocused)
                .submitLabel(.send)
                .onSubmit { vm.submit(playHaptic: true) }
                .disabled(combatInteractionLocked)
                .padding(10)
                .frame(minHeight: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.accent.opacity(inputFocused ? 0.45 : 0.2), lineWidth: 1)
                )
                .foregroundColor(Theme.parchment)
                .accessibilityLabel("Command input")

            Button { vm.submit(playHaptic: true) } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(PressScaleButtonStyle())
            .disabled(combatInteractionLocked)
            .opacity(combatInteractionLocked ? 0.5 : 1)
            .accessibilityLabel("Send command")
        }
        .padding(metrics.horizontalPadding)
        .padding(.vertical, 8)
        .background(Theme.background.opacity(0.35))
        .opacity(combatInteractionLocked ? 0.85 : 1)
    }

    // MARK: - Death overlay

    private func deathOverlay(_ metrics: LayoutMetrics) -> some View {
        let konDeath = vm.lastDeath
        let socDeath = vm.lastSocDeath
        let title = konDeath?.cause.title ?? (vm.product == .soc ? "Defeated in Battle" : "You Have Died")
        let epitaph = konDeath?.cause.epitaph ?? socDeath?.epitaph
        let deathNumber = konDeath?.number ?? socDeath?.number ?? vm.displayDeathCount
        return ZStack {
            RadialGradient(
                colors: [
                    Color(red: 0.2, green: 0, blue: 0).opacity(0.85),
                    .black.opacity(0.95)
                ],
                center: .center,
                startRadius: 40,
                endRadius: 600
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    DeathSkullIcon()

                    Text(title)
                        .font(.system(.largeTitle, design: .serif).bold())
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)

                    if let epitaph {
                        Text(epitaph)
                            .font(.system(.body, design: .serif).italic())
                            .foregroundColor(Theme.parchment.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }

                    Text("You have died.  ·  Death #\(deathNumber)")
                        .font(.caption)
                        .foregroundColor(Theme.parchment.opacity(0.5))

                    VStack(spacing: 12) {
                        MenuButton(title: "Restart from checkpoint") { vm.restartFromCheckpoint() }
                        MenuButton(title: "New game") { vm.restartFromBeginning() }
                    }
                    .padding(.top, 8)
                }
                .padding(28)
                .frame(maxWidth: metrics.contentMaxWidth)
                .frame(maxWidth: .infinity)
                .celebrationModalEnter()
            }
        }
        .transition(.opacity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Death screen")
    }

    private func levelUpOverlay(_ metrics: LayoutMetrics) -> some View {
        let level = vm.pendingLevelUp ?? vm.socState.playerLevel
        return ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 16) {
                LevelUpStarIcon()
                Text("Level Up!")
                    .font(.system(.title, design: .serif).bold())
                    .foregroundColor(Theme.parchment)
                Text("You are now level \(level).")
                    .font(.body)
                    .foregroundColor(Theme.parchment.opacity(0.85))
                Text("Attack, defense, and luck increased.")
                    .font(.footnote)
                    .foregroundColor(Theme.parchment.opacity(0.65))
                MenuButton(title: "Continue") { vm.dismissLevelUp() }
            }
            .padding(28)
            .frame(maxWidth: metrics.contentMaxWidth)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(metrics.horizontalPadding)
            .celebrationModalEnter()
        }
        .transition(.opacity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Level up")
    }

    // MARK: - Toasts

    private func toastOverlay(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 8) {
            chroniclerXPToasts(metrics)
            achievementToasts(metrics)
            trophyToasts(metrics)
        }
    }

    private func chroniclerXPToasts(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 8) {
            ForEach(vm.recentChroniclerXP) { entry in
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Chronicler XP")
                            .font(.caption2).foregroundColor(Theme.parchment.opacity(0.6))
                        Text("+\(entry.amount) · \(entry.label)")
                            .font(.system(.caption, design: .serif).weight(.semibold))
                            .foregroundColor(Theme.parchment)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.accent.opacity(0.35)))
                .padding(.horizontal, metrics.horizontalPadding)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityLabel("Chronicler experience plus \(entry.amount), \(entry.label)")
            }
        }
        .animation(.spring(response: 0.4), value: vm.recentChroniclerXP.map(\.id))
    }

    private func trophyToasts(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 8) {
            ForEach(vm.recentlyUnlockedTrophies, id: \.self) { trophy in
                HStack(spacing: 10) {
                    ToastTrophyIcon(trigger: trophy)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trophy Unlocked")
                            .font(.caption2).foregroundColor(Theme.parchment.opacity(0.6))
                        Text(trophy.title)
                            .font(.system(.subheadline, design: .serif).bold())
                            .foregroundColor(Theme.parchment)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.accent.opacity(0.4)))
                .padding(.horizontal, metrics.horizontalPadding)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityLabel("Trophy unlocked: \(trophy.title)")
            }
        }
        .animation(.spring(response: 0.4), value: vm.recentlyUnlockedTrophies)
    }

    // MARK: - Achievement toasts

    private func achievementToasts(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 8) {
            ForEach(vm.recentlyUnlocked, id: \.self) { ach in
                HStack(spacing: 10) {
                    ToastTrophyIcon(trigger: ach)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Achievement Unlocked")
                            .font(.caption2).foregroundColor(Theme.parchment.opacity(0.6))
                        Text(ach.title)
                            .font(.system(.subheadline, design: .serif).bold())
                            .foregroundColor(Theme.parchment)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.accent.opacity(0.4)))
                .padding(.horizontal, metrics.horizontalPadding)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityLabel("Achievement unlocked: \(ach.title)")
            }
        }
        .padding(.top, 6)
        .animation(.spring(response: 0.4), value: vm.recentlyUnlocked)
    }

    private func icon(for item: Flag) -> String {
        switch item {
        case .sword: return "scribble"
        case .lantern: return "lantern.fill"
        case .dagger: return "scissors"
        case .rod: return "figure.fishing"
        default: return "bag"
        }
    }

    private func itemAccessibilityLabel(_ item: Flag) -> String {
        switch item {
        case .sword: return "Sword"
        case .lantern: return "Lantern"
        case .dagger: return "Dagger"
        case .rod: return "Fishing rod"
        default: return "Item"
        }
    }
}
