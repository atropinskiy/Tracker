//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by alex_tr on 13.12.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }
    func testTrackersViewControllerLightSnapshot() {
        let vc = TrackersViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))                        // 2
    }
}

