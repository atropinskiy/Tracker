//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by alex_tr on 02.12.2024.
//

import Foundation

class CategoriesViewModel {
    var categories: [TrackerCategoryCoreData] = []
    var selectedCategory: String?
    private var trackerCategoryStore = TrackerCategoryStore.shared
    private var trackerStore = TrackerStore.shared 

    var numberOfCategories: Int {
        return categories.count
    }

    // Загрузка категорий через синглтон TrackerCategoryStore
    func loadCategories() {
        categories = TrackerCategoryStore.shared.fetchAllCategories()

    }
    
    func getCategoriesAsTrackerCategory() -> [TrackerCategory] {
        return categories.map { categoryCoreData in
            // Получаем все трекеры для данной категории
            let trackersCoreData = trackerStore.fetchTrackers(forCategory: categoryCoreData)

            // Преобразуем TrackerCoreData в Tracker с использованием convenience инициализатора
            let trackers = trackersCoreData.map { coreDataTracker in
                return Tracker(from: coreDataTracker)
            }
            
            // Создаем новый объект TrackerCategory с использованием title и списка trackers
            return TrackerCategory(title: categoryCoreData.title ?? "", trackers: trackers)
        }
    }

    
    func category(at index: Int) -> TrackerCategoryCoreData {
            return categories[index]
        }
    
    func getCategoryTitles() -> [String] {
        return categories.compactMap { $0.title }
    }

    func removeCategory(at indexPath: IndexPath) {
        // Удаляем категорию из Core Data по IndexPath
        TrackerCategoryStore.shared.deleteCategory(at: indexPath)
        
        // Удаляем категорию из локального списка
        categories.remove(at: indexPath.row)
    }


    func addCategory(title: String) {
        TrackerCategoryStore.shared.addCategory(title: title)
        loadCategories() // После добавления перезагружаем список категорий
    }
    
    func toggleSelection(for index: Int) {
        let categoryTitle = categories[index].title ?? ""
        
        // Если выбранная категория уже выбрана, сбрасываем выбор
        if selectedCategory == categoryTitle {
            selectedCategory = nil
        } else {
            // Иначе выбираем новую категорию
            selectedCategory = categoryTitle
        }
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        let category = categories[index]
        return category.title == selectedCategory // Сравниваем название категории с выбранной категорией
    }
    
    func assignCategoryToTracker(categoryTitle: String, trackerId: UUID) {
        // Находим категорию по названию
        guard let selectedCategory = TrackerCategoryStore.shared.fetchCategoryByTitle(categoryTitle) else {
            print("Категория с названием \(categoryTitle) не найдена.")
            return
        }
        
        // Назначаем найденную категорию трекеру через TrackerStore
        trackerStore.assignCategoryToTracker(trackerId: trackerId, category: selectedCategory)
        print("Трекер с ID \(trackerId) был успешно назначен на категорию \(categoryTitle).")
        
    }
}



