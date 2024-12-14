//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData
import Combine

final class TrackerCategoryStore: NSObject {
    
    var categoriesUpdated = PassthroughSubject<[TrackerCategoryCoreData], Never>()
    
    override init() {
        super.init()
        setupFetchedResultsController()
    }
    
    var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?

    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] // Сортировка по названию категории

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            print("NSFetchedResultsController для TrackerCategory успешно настроен")
        } catch {
            print("Ошибка при настройке NSFetchedResultsController для TrackerCategory: \(error.localizedDescription)")
        }
    }

    func addCategory(title: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title

        do {
            try context.save()
            print("Категория успешно добавлена")
        } catch {
            print("Ошибка при сохранении категории: \(error.localizedDescription)")
        }
    }

    func deleteCategory(at indexPath: IndexPath) {
        guard let category = fetchedResultsController?.object(at: indexPath) else {
            print("Категория не найдена для удаления")
            return
        }
        context.delete(category)

        do {
            try context.save()
            print("Категория успешно удалена")
        } catch {
            print("Ошибка при удалении категории: \(error.localizedDescription)")
        }
    }

    func fetchAllCategories() -> [TrackerCategoryCoreData] {
        setupFetchedResultsController()
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchCategoryByTitle(_ title: String) -> TrackerCategoryCoreData? {
        return fetchedResultsController?.fetchedObjects?.first { $0.title == title }
    }
    
    private func notifyCategoryUpdate() {
        categoriesUpdated.send(fetchAllCategories())
        print("Отправляем сообщения слушателям")
    }
    
    func fetchCategoryTitleByTrackerId(_ trackerId: UUID) -> String? {
        // Запросим все трекеры с данным id
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg) // Используем UUID напрямую

        do {
            let trackers = try context.fetch(fetchRequest)
            guard let tracker = trackers.first else { return nil } // Если трекер не найден

            // Получаем категорию, с которой связан этот трекер
            if let category = tracker.category {
                return category.title // Возвращаем название категории
            }
        } catch {
            print("Ошибка при получении категории по id трекера: \(error.localizedDescription)")
        }

        return nil
    }



}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        notifyCategoryUpdate()
    }
}
