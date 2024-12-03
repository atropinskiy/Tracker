//
//  OboardingPage.swift
//  Tracker
//
//  Created by alex_tr on 03.12.2024.
//

import UIKit

enum OnboardingPage {
    case bluePage
    case redPage
    
    var imageName: String {
        switch self {
        case .bluePage:
            return "StartBgBlue"
        case .redPage:
            return "StartBgRed"
        }
    }
    
    var labelText: String {
        switch self {
        case .bluePage:
            return "Отслеживайте только то, что хотите"
        case .redPage:
            return "Даже если это не литры воды и йога"
        }
    }
}

