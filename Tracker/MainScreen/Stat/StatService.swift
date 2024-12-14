//
//  StatService.swift
//  Tracker
//
//  Created by alex_tr on 13.12.2024.
//
import Combine

final class StatService {
    private var cancellables = Set<AnyCancellable>()
    private let trackerRecordStore = TrackerRecordStore()
    
    @Published private(set) var statValues: [Int] = []
    
    var statValuesPublisher: Published<[Int]>.Publisher {
        return $statValues
    }
    
    init() {
        trackerRecordStore.$statValues
            .sink { [weak self] newStatValues in
                self?.statValues = newStatValues ?? []
                print("StatService: Обновлена статистика: \(newStatValues ?? [])")
            }
            .store(in: &cancellables)
        trackerRecordStore.setUpFetchedResultsController()
    }
    
    func getStat() -> [Int]? {
        if statValues.isEmpty {
            print("StatService: Данные отсутствуют")
            return nil
        }
        return statValues
    }
    
    func updateStat(newValues: [Int]) {
        print("StatService: Обновление статистики вручную: \(newValues)")
        statValues = newValues
    }
}


