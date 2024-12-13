//
//  Tracker.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

enum WeekDay: String, CaseIterable, Encodable, Decodable {
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
class Tracker {
    var id: UUID
    var name: String
    var color: UIColor
    var emoji: String
    var schedule: [WeekDay]?
    var date: Date?
    var pinned: Bool = false

    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay]?, date: Date?, pinned: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.date = date
        self.pinned = pinned
    }

    convenience init(from coreDataTracker: TrackerCoreData) {
        let colorString = coreDataTracker.color ?? "#000000" // по умолчанию черный
        let color = UIColor(hex: colorString) ?? UIColor.black // если UIColor(hex:) возвращает nil, используем UIColor.black
        
        // Преобразуем строку расписания в массив WeekDay
        let schedule = WeekDayArrayTransformer.stringToSchedule(from: coreDataTracker.schedule ?? "")
        
        self.init(
            id: coreDataTracker.id ?? UUID(),
            name: coreDataTracker.name ?? "",
            color: color,
            emoji: coreDataTracker.emoji ?? "",
            schedule: schedule,
            date: coreDataTracker.date,
            pinned: coreDataTracker.pinned
        )
    }

}
