//
//  Tracker.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortDescription: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
struct Tracker {
    let id : UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule:[WeekDay]?
    let date: Date?
}
