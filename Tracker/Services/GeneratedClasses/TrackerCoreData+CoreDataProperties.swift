//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by alex_tr on 30.11.2024.
//
//

import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var color: String?
    @NSManaged public var date: Date?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: WeekDayArrayTransformer?

}

extension TrackerCoreData : Identifiable {

}
