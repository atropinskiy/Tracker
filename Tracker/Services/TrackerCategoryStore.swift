//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createCategory(name: String) -> TrackerCategory {
        let category = TrackerCategoryCoreData(context: context)
        category.name = name
        saveContext()
        return TrackerCategory(coreData: category)
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categories = (try? context.fetch(fetchRequest)) ?? []
        return categories.map { TrackerCategory(coreData: $0) }
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

