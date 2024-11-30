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

    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay]?, date: Date?) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.date = date
    }

    // Функция для создания Tracker из TrackerCoreData
    static func fromCoreData(_ coreData: TrackerCoreData) -> Tracker {
        // Преобразуем строку HEX в UIColor
        let color: UIColor
        if let hexColor = coreData.color {
            color = UIColor(hex: hexColor) ?? UIColor.black  // Если конвертация не удалась, используем дефолтный цвет
        } else {
            color = UIColor.black  // Если color == nil, используем дефолтный цвет
        }

        // Преобразуем schedule из Data в [WeekDay]
        let schedule: [WeekDay]?
        if let scheduleData = coreData.schedule as? Data {
            let transformer = WeekDayArrayTransformer()  // Используем ваш трансформер
            if let decodedSchedule = transformer.reverseTransformedValue(scheduleData) as? [WeekDay] {
                schedule = decodedSchedule
            } else {
                print("Ошибка декодирования schedule")
                schedule = nil
            }
        } else {
            schedule = nil
        }

        return Tracker(
            id: coreData.id ?? UUID(),
            name: coreData.name ?? "",
            color: color,
            emoji: coreData.emoji ?? "",
            schedule: schedule,  // Используем декодированное расписание
            date: coreData.date
        )
    }
}
