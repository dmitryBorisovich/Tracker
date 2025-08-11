import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

        func testLightTheme() {
            let vc = TrackersViewController()
            
            assertSnapshot(
                of: vc,
                as: .image(
                    traits: UITraitCollection(userInterfaceStyle: .light)
                ),
                named: "LightTheme",
                record: false
            )
        }
        
        func testDarkTheme() {
            let vc = TrackersViewController()
            
            assertSnapshot(
                of: vc,
                as: .image(
                    traits: UITraitCollection(userInterfaceStyle: .dark)
                ),
                named: "DarkTheme",
                record: false
            )
        }
}
