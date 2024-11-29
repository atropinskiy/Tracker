//
//  PersistentContainer.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData

final class PersistentContainer {
    static let shared = PersistentContainer()
    
    private let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
}

