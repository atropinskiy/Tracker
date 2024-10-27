//
//  FirstTimeLoadViewControllers.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

class BaseViewController: UIViewController {
    
    func setBg(imageName: String) {
        let bgImage = UIImageView(frame: UIScreen.main.bounds)
        bgImage.image = UIImage(named: imageName)
        bgImage.contentMode = .scaleAspectFill
        view.insertSubview(bgImage, at: 0)
    }
    
    func setLabel() {
        let label = UILabel()
        label.text = "Отслеживайте только то, что хотите"
        label.textColor = UIColor(named: "YP-black")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0 // Позволяет тексту переноситься на несколько строк
        
        view.addSubview(label)
        
        // Отключаем autoresizing mask для работы с Auto Layout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Устанавливаем ограничения
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304)
        ])
    }
}
