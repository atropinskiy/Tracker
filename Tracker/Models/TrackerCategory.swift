//
//  TrackerCategory.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]?
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
