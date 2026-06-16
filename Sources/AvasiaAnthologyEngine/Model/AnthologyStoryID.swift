import Foundation

/// Playable anthology story identifiers (meta-progression).
public enum AnthologyStoryID: String, Codable, CaseIterable, Sendable {
    case storyZero = "story_zero"
    case goodOne = "good_one"
    case goodTwo = "good_two"
    case badOne = "bad_one"
    case badTwo = "bad_two"
    case elkFeast = "elk_feast"
    case caveRecord = "cave_record"
    case goodThree = "good_three"
    case badThree = "bad_three"
    case neutralThree = "neutral_three"
}
