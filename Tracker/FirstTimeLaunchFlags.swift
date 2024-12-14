//
//  FirstTimeLaunchService.swift
//  Tracker
//
//  Created by alex_tr on 02.11.2024.
//

import UIKit
import CoreData


final class FirstTimeLaunchFlags {    
    private lazy var firstTimeLaunch = false
    private lazy var cleanCoreData = false
    
    func startAppWithFlags() {
        if firstTimeLaunch { setFirstTimeLaunch() }
        if cleanCoreData {deleteAllRecords()}
    }
    
    
    private func setFirstTimeLaunch() {
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore") // Для тестирования первого и не первго раза
    }
    
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }
    
    func deleteAllRecords() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
            print("Все записи успешно удалены из Core Data")
        } catch {
            print("Ошибка при удалении всех записей: \(error.localizedDescription)")
        }
    }
}
    
