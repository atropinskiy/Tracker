//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addRecord(for tracker: Tracker, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.tracker = tracker.coreDataReference
        saveContext()
    }
    
    func fetchRecords(for tracker: Tracker) -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tracker == %@", tracker.coreDataReference)
        let records = (try? context.fetch(fetchRequest)) ?? []
        return records.map { TrackerRecord(coreData: $0) }
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
