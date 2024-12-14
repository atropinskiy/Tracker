//
//  AnalyticsService.swift
//  Tracker
//
//  Created by alex_tr on 14.12.2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: Constants.appMetrikaKey) else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, screen: String, item: String? = nil) {
        var params: [String: Any] = ["event": event, "screen": screen]
        
        // Если передан item, добавляем его в параметры
        if let item = item {
            params["item"] = item
        }
        
        // Отправляем событие в Яндекс.Метрику
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        
        // Для тестирования выводим в консоль
        print("Event: \(event), Screen: \(screen), Item: \(item ?? "None")")
    }
}
