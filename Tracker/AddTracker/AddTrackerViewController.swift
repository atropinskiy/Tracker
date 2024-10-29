//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit

class AddTrackerViewController: UIViewController {
    var taskType: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let taskType = taskType {
            print("Полученный параметр: \(taskType)")
        }
    }
}
