import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testViewController() {
        let vc = TrackersViewController()
        assertSnapshot(of: vc, as: .image)
    }
}
