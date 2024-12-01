import UIKit

struct Tracker {
    let trackerId: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [String]
    var isPinned: Bool
}
