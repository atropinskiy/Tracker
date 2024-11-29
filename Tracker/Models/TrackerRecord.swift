//
//  TrackerRecord.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import Foundation

struct TrackerRecord {
    let id: UUID
    let date: Date
    
    init(id: UUID, date: Date) {
        self.id = id
        self.date = date
    }
}
