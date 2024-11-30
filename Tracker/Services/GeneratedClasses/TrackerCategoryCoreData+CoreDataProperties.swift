//
//  TrackerCategoryCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by alex_tr on 30.11.2024.
//
//

import Foundation
import CoreData


extension TrackerCategoryCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }

    @NSManaged public var title: String?

}

extension TrackerCategoryCoreData : Identifiable {

}
