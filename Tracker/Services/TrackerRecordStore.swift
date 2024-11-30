//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData

final class TrackerRecordStore {
    // MARK: - Singleton
    static let shared = TrackerRecordStore()
    private init() {} // Закрываем инициализацию для внешнего использования

    // Контекст для работы с Core Data
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }

    // MARK: - Добавление записи
    func addRecord(id: UUID, date: Date) {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.id = id
        recordEntity.date = date

        do {
            try context.save()
            print("Запись успешно добавлена в Core Data")
        } catch {
            print("Ошибка при сохранении записи: \(error.localizedDescription)")
        }
    }

    // MARK: - Удаление записи по ID
    func deleteRecord(by id: UUID, on date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        // Устанавливаем предикат для удаления записи с конкретным ID и датой
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@",
                                             id as CVarArg,
                                             startOfDay as NSDate,
                                             endOfDay as NSDate)

        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
            print("Запись с ID \(id) и датой \(date) успешно удалена из Core Data")
        } catch {
            print("Ошибка при удалении записи с ID \(id) и датой \(date): \(error.localizedDescription)")
        }
    }
    
    func countCompletedTrackers(for trackerId: UUID) -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.count
        } catch {
            print("Ошибка при подсчете выполненных трекеров для \(trackerId): \(error.localizedDescription)")
            return 0
        }
    }
    
    func isTrackerCompletedToday(trackerId: UUID, currentDate: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()

        // Получаем текущую дату с обнулённым временем для сравнения только даты
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Настроим фильтр запроса: ищем запись с trackerId и датой выполнения на текущий день
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@",
                                             trackerId as CVarArg,
                                             startOfDay as CVarArg,
                                             endOfDay as CVarArg)

        do {
            // Выполняем запрос
            let results = try context.fetch(fetchRequest)
            // Если результаты не пусты, значит, трекер был завершён на текущую дату
            return !results.isEmpty
        } catch {
            print("Ошибка при запросе в Core Data: \(error)")
            return false
        }
    }
}

