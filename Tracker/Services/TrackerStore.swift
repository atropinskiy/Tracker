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
}



