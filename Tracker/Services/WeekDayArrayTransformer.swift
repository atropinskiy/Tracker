//
//  ScheduleTransformer.swift
//  Tracker
//
//  Created by alex_tr on 30.11.2024.
//

import Foundation

public class WeekDayArrayTransformer {
    static func scheduleToString(from days: [WeekDay]) -> String {
        return days.map { $0.rawValue }.joined(separator: ",")
    }
    
    // Преобразование строки в массив WeekDay
    static func stringToSchedule(from scheduleString: String) -> [WeekDay] {
        let days = scheduleString.split(separator: ",").map { String($0) }
        return days.compactMap { WeekDay(rawValue: $0) }
    }
    
}
