//
//  TrackerStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createTracker(name: String, color: String, category: TrackerCategory) {
        let tracker = TrackerCoreData(context: context)
        tracker.name = name
        tracker.color = color
        tracker.category = category
        saveContext()
    }
    
    func fetchTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackers = (try? context.fetch(fetchRequest)) ?? []
        return trackers.map { Tracker(coreData: $0) }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        if let objectID = tracker.coreDataObjectID,
           let object = try? context.existingObject(with: objectID) {
            context.delete(object)
            saveContext()
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

