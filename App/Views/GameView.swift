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
    @FocusState private var inputFocused: Bool

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
            return ["Attack", "Eat Potion", "Inventory"]
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
             .northernMarch, .mageOutpost, .vashirrStand, .ageEpilogue:
            return ["March", "Continue", "Inventory", "Look"]
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
            RegionIllustration(media: vm.media, height: metrics.illustrationHeight)
            statusStrip(metrics)
            Divider().background(Theme.accent.opacity(0.4))
            transcript
                .layoutPriority(1)
                .background(transcriptBackground)
            quickActions(metrics)
            inputBar(metrics)
        }
    }

    private func splitLayout(_ metrics: LayoutMetrics) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                RegionIllustration(media: vm.media, height: metrics.illustrationHeight)
                statusStrip(metrics, vertical: true)
                Spacer(minLength: 0)
            }
            .frame(width: metrics.gameSidebarWidth)

            Divider().background(Theme.accent.opacity(0.4))

            VStack(spacing: 0) {
                transcript
                    .layoutPriority(1)
                    .background(transcriptBackground)
                quickActions(metrics)
                inputBar(metrics)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: metrics.gameContentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Status strip

    private func statusStrip(_ metrics: LayoutMetrics, vertical: Bool = false) -> some View {
        Group {
            if vertical {
                VStack(alignment: .leading, spacing: 10) {
                    statusControls
                    statusInventory
                    Text("☠ \(vm.displayDeathCount)")
                        .font(.caption2)
                        .foregroundColor(Theme.parchment.opacity(0.6))
                        .accessibilityLabel("Death count \(vm.displayDeathCount)")
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        statusControls
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
        .padding(.vertical, 8)
        .padding(.horizontal, vertical ? metrics.horizontalPadding : 0)
    }

    private var statusControls: some View {
        HStack(spacing: 14) {
            Button { vm.screen = .title } label: {
                Image(systemName: "list.bullet").foregroundColor(Theme.accent)
            }
            .accessibilityLabel("Main menu")

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

            if vm.product == .stories, vm.anthologyState.currentRoom == .storyHub {
                Button { vm.openStoryPicker() } label: {
                    Label("Stories", systemImage: "book.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityIdentifier("anthology-choose-story")
                Button { vm.launchArena() } label: {
                    Label("Arena", systemImage: "figure.fencing")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityIdentifier("anthology-arena")
                .disabled(!vm.anthologyState.storyZeroComplete)
                Button { vm.openTrainingShop() } label: {
                    Label("Shop", systemImage: "bag.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(Theme.accent)
                }
                .accessibilityIdentifier("anthology-shop")
                .disabled(!vm.anthologyState.storyZeroComplete)
            }

            if vm.product == .soc, vm.socState.inCombat {
                StatusBadge(title: "Combat", systemImage: "bolt.fill", tint: .red)
            }
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
                        Label("\(vm.socState.playerHp)/\(vm.socState.playerMaxHp)", systemImage: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.parchment)
                    }
                    Label("\(vm.socState.gold)", systemImage: "circle.fill")
                        .font(.caption2)
                        .foregroundColor(Theme.accent)
                        .accessibilityLabel("Gold \(vm.socState.gold)")
                    ForEach(socItems, id: \.self) { item in
                        Image(systemName: socIcon(for: item))
                            .foregroundColor(Theme.parchment)
                            .accessibilityLabel(item.displayName)
                    }
                }
            } else if vm.product == .stories, vm.anthologyState.alignment != .none {
                Label(vm.anthologyState.alignment.rawValue, systemImage: "flag.fill")
                    .font(.caption2)
                    .foregroundColor(Theme.accent)
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
                            showsCursor: entry.showsCursor
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
                if metrics.isAccessibilityText {
                    ScrollView {
                        quickActionsGrid(metrics)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .frame(maxHeight: 180)
                } else {
                    quickActionsGrid(metrics)
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
                .onSubmit { vm.submit() }
                .padding(10)
                .frame(minHeight: 44)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.accent.opacity(0.2), lineWidth: 1)
                )
                .foregroundColor(Theme.parchment)
                .accessibilityLabel("Command input")

            Button { vm.submit() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(PressScaleButtonStyle())
            .accessibilityLabel("Send command")
        }
        .padding(metrics.horizontalPadding)
        .padding(.vertical, 8)
        .background(Theme.background.opacity(0.35))
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
                    Image(systemName: "skull")
                        .font(.system(size: 44))
                        .foregroundColor(.red.opacity(0.9))
                        .accessibilityHidden(true)

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
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Theme.accent)
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
        }
        .transition(.opacity)
    }

    // MARK: - Toasts

    private func toastOverlay(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 8) {
            achievementToasts(metrics)
            trophyToasts(metrics)
        }
    }

    private func trophyToasts(_ metrics: LayoutMetrics) -> some View {
        VStack(spacing: 8) {
            ForEach(vm.recentlyUnlockedTrophies, id: \.self) { trophy in
                HStack(spacing: 10) {
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
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
                    Image(systemName: "trophy.fill").foregroundColor(.yellow)
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
