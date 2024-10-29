//
//  TypeSelectViewController.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit

class TypeSelectViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        createCanvas()
    }
    
    private func createCanvas() {
        let headLabel = UILabel()
        headLabel.text = "Создание трекера"
        headLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        headLabel.textAlignment = .center
        headLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headLabel)
        
        NSLayoutConstraint.activate([
            headLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            headLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headLabel.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        let unregularButton = UIButton(type: .custom)
        unregularButton.setTitle("Нерегулярное событие", for: .normal)
        unregularButton.layer.cornerRadius = 18
        unregularButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        unregularButton.backgroundColor = UIColor(named: "YP-black")
        unregularButton.translatesAutoresizingMaskIntoConstraints = false
        unregularButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        unregularButton.tag = 1 // Уникальный тег для определения кнопки
        view.addSubview(unregularButton)
        
        NSLayoutConstraint.activate([
            unregularButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -281),
            unregularButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            unregularButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            unregularButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let habbitButton = UIButton(type: .custom)
        habbitButton.setTitle("Привычка", for: .normal)
        habbitButton.layer.cornerRadius = 18
        habbitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habbitButton.backgroundColor = UIColor(named: "YP-black")
        habbitButton.translatesAutoresizingMaskIntoConstraints = false
        habbitButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        habbitButton.tag = 2 // Уникальный тег для определения кнопки
        view.addSubview(habbitButton)
        
        NSLayoutConstraint.activate([
            habbitButton.bottomAnchor.constraint(equalTo: unregularButton.topAnchor, constant: -16),
            habbitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habbitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habbitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let modalVC = AddTrackerViewController()
        modalVC.modalPresentationStyle = .pageSheet // Настраиваем стиль показа (например, pageSheet)
        
        // Передаём параметр в зависимости от кнопки
        modalVC.taskType = sender.tag == 1 ? "Нерегулярное событие" : "Привычка"
        
        present(modalVC, animated: true, completion: nil)
    }
}
