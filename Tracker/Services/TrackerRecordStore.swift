//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by alex_tr on 29.11.2024.
//
import CoreData
import Combine

final class TrackerRecordStore: NSObject {
    override init() {
        super.init()
        setUpFetchedResultsController()
    }
    
    private var context: NSManagedObjectContext {
        return DatabaseManager.shared.context
    }
    
    var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    private var cancellables = Set<AnyCancellable>()
    
    @Published var statValues: [Int]?
    
    var statValuesPublisher: Published<[Int]?>.Publisher {
        return $statValues
    }
    
    // Метод для настройки fetchedResultsController
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateStatValues() // Обновляем статистику при инициализации
        } catch {
            print("Ошибка при выполнении fetch-запроса: \(error.localizedDescription)")
        }
    }
    
    private func updateStatValues() {
        let completedTrackers = countAllCompletedTrackers()
        statValues = [0, 0, completedTrackers, 0]
    }
    

    func addRecord(id: UUID, date: Date) {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.id = id
        recordEntity.date = date
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let trackerCoreData = results.first {
                recordEntity.tracker = trackerCoreData
            } else {
                print("Трекер с id \(id) не найден.")
            }
            
            try context.save()
            updateStatValues()
            print("Запись успешно добавлена в Core Data")
        } catch {
            print("Ошибка при сохранении записи: \(error.localizedDescription)")
        }
    }

    func deleteRecord(by id: UUID, on date: Date) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@",
                                             id as CVarArg,
                                             startOfDay as NSDate,
                                             endOfDay as NSDate)
        
        do {
            let records = try context.fetch(fetchRequest)
            if records.isEmpty {
                print("Нет записей для удаления с ID \(id) и датой \(date)")
            }
            for record in records {
                context.delete(record)
            }
            try context.save()
            updateStatValues() // Явно обновляем статистику после удаления
            print("Запись с ID \(id) и датой \(date) успешно удалена из Core Data")
        } catch {
            print("Ошибка при удалении записи с ID \(id) и датой \(date): \(error.localizedDescription)")
        }
    }
    
    func countCompletedTrackers(for trackerId: UUID) -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.count
        } catch {
            print("Ошибка при подсчете выполненных трекеров для \(trackerId): \(error.localizedDescription)")
            return 0
        }
    }
    
    func isTrackerCompletedToday(trackerId: UUID, currentDate: Date) -> Bool {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@",
                                             trackerId as CVarArg,
                                             startOfDay as CVarArg,
                                             endOfDay as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Ошибка при запросе в Core Data: \(error)")
            return false
        }
    }
    
    func countAllCompletedTrackers() -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.count
        } catch {
            print("Ошибка при подсчете всех выполненных трекеров: \(error.localizedDescription)")
            return 0
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Данные в Core Data изменены. Обновление статистики.")
        updateStatValues()
    }
}


