//
//  FirstTimeLaunchService.swift
//  Tracker
//
//  Created by alex_tr on 02.11.2024.
//

import UIKit



final class FirstTimeLaunchFlags {    
    private lazy var firstTimeLaunch = false
    
    func startAppWithFlags() {
        if firstTimeLaunch { setFirstTimeLaunch() }
    }
    
    
    private func setFirstTimeLaunch() {
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore") // Для тестирования первого и не первго раза
    }
}
    
