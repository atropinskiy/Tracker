//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData
import UIKit

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    static let shared = TrackerCategoryStore()
    private override init() {}
    
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?

    // MARK: - Настройка NSFetchedResultsController
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

    // MARK: - Добавление категории
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

    // MARK: - Удаление категории
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

    // MARK: - Получение всех категорий через NSFetchedResultsController
    func fetchAllCategories() -> [TrackerCategoryCoreData] {
        setupFetchedResultsController()
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func fetchCategoryByTitle(_ title: String) -> TrackerCategoryCoreData? {
        // Получаем все категории через fetchedResultsController
        return fetchedResultsController?.fetchedObjects?.first { $0.title == title }
    }

    // MARK: - NSFetchedResultsControllerDelegate (опционально)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Данные в NSFetchedResultsController изменились")
        // Здесь можно обновить UI, если требуется
    }
}
