import Foundation

public enum SagaXPCategory: String, Codable, Sendable {
    case exploration
    case choice
    case secret
    case milestone
    case completion
    case death
    case achievementClaim
    case runBonus
    case migration
}

public struct SagaXPEntry: Codable, Identifiable, Sendable, Equatable {
    public var id: UUID
    public var date: Date
    public var product: AvasiaProduct?
    public var runID: UUID?
    public var label: String
    public var amount: Int
    public var modifierNote: String?
    public var category: SagaXPCategory

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        product: AvasiaProduct? = nil,
        runID: UUID? = nil,
        label: String,
        amount: Int,
        modifierNote: String? = nil,
        category: SagaXPCategory
    ) {
        self.id = id
        self.date = date
        self.product = product
        self.runID = runID
        self.label = label
        self.amount = amount
        self.modifierNote = modifierNote
        self.category = category
    }
}
