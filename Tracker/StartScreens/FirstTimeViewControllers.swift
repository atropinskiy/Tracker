//
//  BlueViewController.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

final class BlueViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setBg(imageName: "StartBgBlue")
        setLabel(text: "Отслеживайте только то, что хотите")
        addButton()
    }
    
    
}

import UIKit

final class RedViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        setBg(imageName: "StartBgRed")
        setLabel(text: "Даже если это не литры воды и йога")
        addButton()
    }
    
    
}
