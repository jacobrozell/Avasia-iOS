import Foundation
import AvasiaEngine

/// Locations in anthology stories.
public enum AnthologyRoomID: String, Codable, CaseIterable, Sendable {
    case storyHub = "story_hub"

    // Story #0 — Scout Patrol
    case patrolCamp = "scout_patrol_camp"
    case scoutRidge = "scout_ridge"
    case scoutWithdraw = "scout_withdraw"
    case scoutSignal = "scout_signal"
    case scoutPicket = "scout_picket"
    case vashirrParley = "vashirr_parley"
    case scoutFork = "scout_fork"
    case scoutCampExit = "scout_camp_exit"
    case scoutEpilogue = "scout_epilogue"

    // Good #1 — Oceandale Warning
    case goodOneSilvarium = "good_one_silvarium"
    case goodOneSplitpath = "good_one_splitpath"
    case goodOneOceandale = "good_one_oceandale"
    case goodOnePier = "good_one_pier"
    case goodOneEpilogue = "good_one_epilogue"

    // Good #2 — Nascastrum Courier
    case goodTwoSilvarium = "good_two_silvarium"
    case goodTwoWesternRoad = "good_two_western_road"
    case goodTwoNacastrumGate = "good_two_nacastrum_gate"
    case goodTwoEpilogue = "good_two_epilogue"

    // Bad #1 — Walking with Vashirr
    case badOneColumn = "bad_one_column"
    case badOneTraining = "bad_one_training"
    case badOneAudience = "bad_one_audience"
    case badOneRecon = "bad_one_recon"
    case badOneEpilogue = "bad_one_epilogue"

    // Bad #2 — Cataracta Periphery
    case badTwoPeriphery = "bad_two_periphery"
    case badTwoOverlook = "bad_two_overlook"
    case badTwoBriefing = "bad_two_briefing"
    case badTwoEpilogue = "bad_two_epilogue"

    // Elk Feast
    case elkSplitpath = "elk_splitpath"
    case elkHoldfast = "elk_holdfast"
    case elkFeast = "elk_feast"
    case elkEpilogue = "elk_epilogue"

    // Neutral #2 — Cave Record
    case caveRecordTrail = "cave_record_trail"
    case caveRecordEntrance = "cave_record_entrance"
    case caveRecordCavern = "cave_record_cavern"
    case caveRecordArchive = "cave_record_archive"
    case caveRecordEpilogue = "cave_record_epilogue"

    // Arena training
    case arenaPit = "arena_pit"
    case trainingShop = "training_shop"

    // Good #3 — Council Under Glass
    case goodThreeLanding = "good_three_landing"
    case goodThreeAntechamber = "good_three_antechamber"
    case goodThreeWitnessPrep = "good_three_witness_prep"
    case goodThreeNacastrum = "good_three_nacastrum"
    case goodThreeCouncil = "good_three_council"
    case goodThreeVerdict = "good_three_verdict"
    case goodThreeAftermath = "good_three_aftermath"
    case goodThreeEpilogue = "good_three_epilogue"

    // Bad #3 — Many Hands Oath
    case badThreeMarch = "bad_three_march"
    case badThreeCamp = "bad_three_camp"
    case badThreeVashirrTent = "bad_three_vashirr_tent"
    case badThreeRite = "bad_three_rite"
    case badThreeOath = "bad_three_oath"
    case badThreeAfterOath = "bad_three_after_oath"
    case badThreeEpilogue = "bad_three_epilogue"

    // Neutral #3 — Two Hands Market
    case neutralThreeMarket = "neutral_three_market"
    case neutralThreeTraderRow = "neutral_three_trader_row"
    case neutralThreeSchismStall = "neutral_three_schism_stall"
    case neutralThreeAftermath = "neutral_three_aftermath"
    case neutralThreeEpilogue = "neutral_three_epilogue"
}

public extension AnthologyRoomID {
    var region: Region {
        switch self {
        case .storyHub, .scoutEpilogue, .goodOneSplitpath, .goodOneEpilogue,
             .goodTwoWesternRoad, .goodTwoEpilogue, .goodThreeEpilogue,
             .caveRecordTrail, .caveRecordEpilogue,
             .neutralThreeMarket, .neutralThreeTraderRow, .neutralThreeSchismStall,
             .neutralThreeAftermath, .neutralThreeEpilogue,
             .badOneEpilogue, .badTwoEpilogue, .badThreeEpilogue, .elkSplitpath, .elkEpilogue:
            return .splitpath
        case .patrolCamp, .elkHoldfast, .elkFeast, .badTwoPeriphery, .badTwoOverlook,
             .badThreeCamp, .badThreeMarch:
            return .forest
        case .scoutRidge, .scoutWithdraw, .scoutSignal, .scoutPicket,
             .vashirrParley, .scoutFork, .scoutCampExit, .badOneTraining, .badTwoBriefing,
             .badThreeRite, .badThreeOath, .badThreeAfterOath, .badThreeVashirrTent:
            return .mountain
        case .goodOneOceandale, .goodOnePier, .badOneColumn, .badOneAudience, .badOneRecon,
             .arenaPit, .trainingShop, .goodThreeLanding:
            return .shore
        case .goodOneSilvarium, .goodTwoSilvarium:
            return .tree
        case .goodTwoNacastrumGate, .goodThreeNacastrum, .goodThreeCouncil, .goodThreeVerdict,
             .goodThreeAntechamber, .goodThreeWitnessPrep, .goodThreeAftermath:
            return .nacastrum
        case .caveRecordEntrance, .caveRecordCavern, .caveRecordArchive:
            return .cave
        }
    }
}
