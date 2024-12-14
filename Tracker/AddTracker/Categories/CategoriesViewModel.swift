//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by alex_tr on 02.12.2024.
//

import Foundation
import Combine

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
    func selectCategory(at index: Int)
}

final class CategoriesViewModel: CategoriesViewModelProtocol {

    func category(at index: Int) -> TrackerCategoryCoreData {
        return categories[index]
    }
    var pinnedTrackers: [Tracker] = []
    
    static let shared = CategoriesViewModel()
    private init() {
        loadCategories()
        subscribeToCategoryUpdates()
    }
    
    var categories: [TrackerCategoryCoreData] = []
    var selectedCategory: String?
    private var trackerCategoryStore = TrackerCategoryStore()
    private var trackerStore = TrackerStore()
    private var cancellables = Set<AnyCancellable>()

    var numberOfCategories: Int {
        return categories.count
    }

    func loadCategories() {
        categories = trackerCategoryStore.fetchAllCategories()

    }
    
    func getCategoriesAsTrackerCategory() -> [TrackerCategory] {
    
        return categories.map { categoryCoreData in
            let trackersCoreData = trackerStore.fetchTrackers(forCategory: categoryCoreData)
            let trackers = trackersCoreData.map { coreDataTracker in
                return Tracker(from: coreDataTracker)
            }
            return TrackerCategory(title: categoryCoreData.title ?? "", trackers: trackers)
        }
    }
    
    func getCategoryTitles() -> [String] {
        return categories.compactMap { $0.title }
    }
    
    func getPinnedTrackers() -> [Tracker] {
        return categories.flatMap { category in
            let trackersCoreData = trackerStore.fetchTrackers(forCategory: category)
            return trackersCoreData
                .filter { $0.pinned }
                .map { Tracker(from: $0) }
        }
    }
    
    func addCategory(title: String) {
        if let _ = trackerCategoryStore.fetchCategoryByTitle(title) {
            print("Категория с таким названием уже существует.")
            return
        }
        trackerCategoryStore.addCategory(title: title)
        loadCategories()
    }
    
    func editCategory(title: String, newTitle: String) {
        if let _ = trackerCategoryStore.fetchCategoryByTitle(newTitle) {
            print("Категория с таким новым названием уже существует.")
            return
        }
        
        if let categoryToEdit = trackerCategoryStore.fetchCategoryByTitle(title) {
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
        if selectedCategory == categoryTitle {
            selectedCategory = nil
        } else {
            selectedCategory = categoryTitle
        }
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index].title
    }
    
    func removeCategory(at indexPath: IndexPath) {
        trackerCategoryStore.deleteCategory(at: indexPath)
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        let category = categories[index]
        return category.title == selectedCategory
    }
    
    func assignCategoryToTracker(categoryTitle: String, trackerId: UUID) {
        guard let selectedCategory = trackerCategoryStore.fetchCategoryByTitle(categoryTitle) else {
            print("Категория с названием \(categoryTitle) не найдена.")
            return
        }

        trackerStore.assignCategoryToTracker(trackerId: trackerId, category: selectedCategory)
        print("Трекер с ID \(trackerId) был успешно назначен на категорию \(categoryTitle).")
        
    }
    
    private func subscribeToCategoryUpdates() {
        trackerCategoryStore.categoriesUpdated
            .sink { [weak self] updatedCategories in
                self?.categories = updatedCategories
                print("Категории обновлены в ViewModel")
            }
            .store(in: &cancellables)
    }
}



