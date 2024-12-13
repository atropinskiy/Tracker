//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by alex_tr on 02.12.2024.
//

import Foundation

protocol CategoriesViewModelProtocol {
    
    
    var categories: [TrackerCategoryCoreData] { get }
    var selectedCategory: String? { get set }
    var numberOfCategories: Int { get }
    
    func loadCategories()
    func getCategoriesAsTrackerCategory() -> [TrackerCategory]
    func category(at index: Int) -> TrackerCategoryCoreData
    func getCategoryTitles() -> [String]
    func removeCategory(at indexPath: IndexPath)
    func addCategory(title: String)
    func toggleSelection(for index: Int)
    func isCategorySelected(at index: Int) -> Bool
    func assignCategoryToTracker(categoryTitle: String, trackerId: UUID)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    static let shared = CategoriesViewModel()
    private init() {
        loadCategories()
    }
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


    func addCategory(title: String) {
        // Проверка, существует ли категория с таким названием
        if let _ = trackerCategoryStore.fetchCategoryByTitle(title) {
            print("Категория с таким названием уже существует.")
            // Можно отобразить alert о том, что категория уже существует
            return
        }
        
        // Добавляем категорию через TrackerCategoryStore
        trackerCategoryStore.addCategory(title: title)
        loadCategories() // Перезагружаем список категорий
    }
    
    func editCategory(title: String, newTitle: String) {
        // Проверяем, существует ли категория с новым названием
        if let _ = trackerCategoryStore.fetchCategoryByTitle(newTitle) {
            print("Категория с таким новым названием уже существует.")
            return
        }
        
        // Находим категорию по старому названию
        if let categoryToEdit = trackerCategoryStore.fetchCategoryByTitle(title) {
            // Изменяем её название
            categoryToEdit.title = newTitle
            do {
                try trackerCategoryStore.context.save() // Сохраняем изменения
                loadCategories() // Перезагружаем список категорий
                print("Категория успешно обновлена.")
            } catch {
                print("Ошибка при сохранении изменений: \(error.localizedDescription)")
            }
        } else {
            print("Категория с названием \(title) не найдена.")
        }
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
    
    func removeCategory(at indexPath: IndexPath) {
        categories.remove(at: indexPath.row)
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



