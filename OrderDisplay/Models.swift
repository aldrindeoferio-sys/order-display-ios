import Foundation

struct Order: Identifiable, Codable, Equatable {
    enum Source: String, Codable, CaseIterable { case wolt = "Wolt", foodora = "Foodora", pickup = "Pickup" }
    enum Status: String, Codable { case preparing = "Preparing", ready = "Ready", collected = "Collected" }

    let id: UUID
    var number: String
    var source: Source
    var status: Status
    var receivedAt: Date
    var collectedAt: Date?

    init(number: String, source: Source) {
        id = UUID()
        self.number = number
        self.source = source
        status = .preparing
        receivedAt = Date()
    }
}

enum DisplayBackground: String, CaseIterable, Identifiable {
    case everyday = "Everyday"
    case christmas = "Christmas"
    case winter = "Winter"
    case spring = "Spring"
    case easter = "Easter"
    case summer = "Summer"
    case halloween = "Halloween"
    case newYear = "New Year"

    var id: String { rawValue }
    var isFree: Bool { self == .everyday || self == .christmas }
}
