import Foundation

struct EscrowtrackItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var title: String
    var amount: Double
}
