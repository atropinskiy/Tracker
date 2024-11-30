//
//  TrackerStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData
import UIKit

final class TrackerStore {
    
    static let shared = TrackerStore()
    private init() {}
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }

    // Добавление трекера в Core Data с опциональными значениями schedule (массив дней недели) и date
    func addTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay]? = nil, date: Date? = nil) {
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = id
        trackerEntity.name = name
        trackerEntity.color = color.toHex()
        trackerEntity.emoji = emoji
        
        let transformer = WeekDayArrayTransformer()
        if let transformedSchedule = transformer.transformedValue(schedule) as? Data {
            trackerEntity.schedule = transformedSchedule as NSData
        } else {
            print("Ошибка преобразования расписания в Data.")
            trackerEntity.schedule = nil  // Если преобразование не удалось, устанавливаем nil
        }
        trackerEntity.date = date
        
        // Логируем перед сохранением
        print("Содержимое объекта перед сохранением:")
        print("ID: \(trackerEntity.id ?? UUID())")
        print("Name: \(trackerEntity.name ?? "")")
        print("Color: \(trackerEntity.color ?? "")")
        print("Emoji: \(trackerEntity.emoji ?? "")")
        print("Schedule: \(String(describing: trackerEntity.schedule))")
        print("Date: \(String(describing: trackerEntity.date))")

        do {
            try context.save()
            print("Трекер успешно добавлен в Core Data")
        } catch {
            print("Ошибка при сохранении трекера: \(error.localizedDescription)")
        }
    }

    
    // Пример получения всех трекеров
    func fetchAllTrackers() -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers
        } catch {
            print("Ошибка при извлечении трекеров: \(error.localizedDescription)")
            return []
        }
    }

    // Пример получения трекеров по расписанию (массив дней недели)
    func fetchTrackers(withSchedule schedule: [WeekDay]?) -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        // Если schedule передано, добавляем предикат
        if let schedule = schedule {
            fetchRequest.predicate = NSPredicate(format: "schedule == %@", schedule.map { $0.rawValue } as NSArray)
        }
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers
        } catch {
            print("Ошибка при извлечении трекеров по расписанию: \(error.localizedDescription)")
            return []
        }
    }

    // Пример получения трекеров по дате
    func fetchTrackers(withDate date: Date?) -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        // Если date передано, добавляем предикат для даты
        if let date = date {
            fetchRequest.predicate = NSPredicate(format: "date == %@", date as NSDate)
        }
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers
        } catch {
            print("Ошибка при извлечении трекеров по дате: \(error.localizedDescription)")
            return []
        }
    }
}


