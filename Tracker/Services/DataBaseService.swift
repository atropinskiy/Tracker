//
//  PersistentContainer.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData

@objc(TrackerCoreData)
public class TrackerCoreData: NSManagedObject {
}

extension TrackerCoreData {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
}
