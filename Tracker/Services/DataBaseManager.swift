//
//  DataBaseManager.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//

import CoreData
import UIKit

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    // Контейнер для работы с Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")  // Укажите название вашего .xcdatamodeld файла
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Не удалось загрузить хранилище: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Контекст для работы с Core Data
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Сохранение контекста
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Не удалось сохранить контекст: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

