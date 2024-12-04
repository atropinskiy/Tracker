//
//  TrackerStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = TrackerStore()
    private override init() {}
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?

    // Настройка NSFetchedResultsController
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // Добавьте сортировку

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            print("NSFetchedResultsController успешно настроен")
        } catch {
            print("Ошибка при настройке NSFetchedResultsController: \(error.localizedDescription)")
        }
    }

    // Добавление трекера в Core Data
    func addTracker(id: UUID, name: String, color: UIColor, emoji: String, schedule: [WeekDay]? = nil, date: Date? = nil) {
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = id
        trackerEntity.name = name
        trackerEntity.color = color.toHex()
        trackerEntity.emoji = emoji
        trackerEntity.schedule = schedule != nil ? WeekDayArrayTransformer.scheduleToString(from: schedule!) : nil
        trackerEntity.date = date

        do {
            try context.save()
            print("Трекер успешно добавлен в Core Data")
        } catch {
            print("Ошибка при сохранении трекера: \(error.localizedDescription)")
        }
    }

    // Получение всех трекеров через NSFetchedResultsController
    func fetchAllTrackers() -> [TrackerCoreData] {
        setupFetchedResultsController()
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchTrackers(forCategory category: TrackerCategoryCoreData) -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()

        // Фильтрация по связанной категории
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)

        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers
        } catch {
            print("Ошибка при загрузке трекеров по категории: \(error.localizedDescription)")
            return []
        }
    }
    
    func removeTrackers(forCategory category: TrackerCategoryCoreData) {
        let trackersToDelete = fetchTrackers(forCategory: category)
        
        trackersToDelete.forEach { tracker in
            deleteTracker(tracker)
        }
    }
    
    func removeCategoryAndAssociatedTrackers(category: TrackerCategoryCoreData) {
        // Удаляем все трекеры, относящиеся к категории
        removeTrackers(forCategory: category)
        
        // Удаляем саму категорию
        context.delete(category)
        
        do {
            try context.save()
            print("Категория \(category.title ?? "без названия") и все связанные трекеры успешно удалены.")
        } catch {
            print("Ошибка при удалении категории и трекеров: \(error.localizedDescription)")
        }
    }

    
    private func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        
        do {
            try context.save()
            print("Трекер с ID \(tracker.id ?? UUID()) был удален.")
        } catch {
            print("Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }
    
    // Функция для назначения категории трекеру
    func assignCategoryToTracker(trackerId: UUID, category: TrackerCategoryCoreData) {
        // Получаем трекер по его ID
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            
            // Проверяем, что трекер найден
            guard let tracker = trackers.first else {
                print("Трекер с ID \(trackerId) не найден.")
                return
            }
            
            // Назначаем категорию трекеру
            tracker.category = category
            
            // Сохраняем изменения в Core Data
            try context.save()
            print("Категория успешно назначена трекеру.")
            
        } catch {
            print("Ошибка при назначении категории трекеру: \(error.localizedDescription)")
        }
    }
    

}



