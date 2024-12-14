//
//  StatResults.swift
//  Tracker
//
//  Created by alex_tr on 13.12.2024.
//

import Foundation

class StatResult {
    var bestPeriod: Int
    var idealDays: Int
    var trackersFinished: Int
    var averageCount: Int
    
    
    init(bestPeriod: Int, idealDays: Int, trackersFinished: Int, averageCount: Int) {
        self.bestPeriod = bestPeriod
        self.idealDays = idealDays
        self.trackersFinished = trackersFinished
        self.averageCount = averageCount
    }
}
