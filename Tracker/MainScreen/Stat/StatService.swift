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
    
    // Используем @Published для удобного управления данными
    @Published private(set) var statValues: [Int] = []
    
    // Публичный паблишер для других подписчиков
    var statValuesPublisher: Published<[Int]>.Publisher {
        return $statValues
    }
    
    init() {
        // Подписка на изменения в TrackerRecordStore
        trackerRecordStore.$statValues
            .sink { [weak self] newStatValues in
                self?.statValues = newStatValues ?? []
                print("StatService: Обновлена статистика: \(newStatValues ?? [])")
            }
            .store(in: &cancellables)
        
        // Настройка FetchedResultsController
        trackerRecordStore.setUpFetchedResultsController()
    }
    
    // Метод для получения текущей статистики
    func getStat() -> [Int]? {
        if statValues.isEmpty {
            print("StatService: Данные отсутствуют")
            return nil
        }
        return statValues
    }
    
    // Метод для обновления статистики (если нужно вручную)
    func updateStat(newValues: [Int]) {
        print("StatService: Обновление статистики вручную: \(newValues)")
        statValues = newValues
    }
}


