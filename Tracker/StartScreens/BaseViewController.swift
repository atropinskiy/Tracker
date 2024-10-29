//
//  FirstTimeLoadViewControllers.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

class BaseViewController: UIViewController {
    private lazy var button = UIButton(type: .custom)
    func setBg(imageName: String) {
        let bgImage = UIImageView(frame: UIScreen.main.bounds)
        bgImage.image = UIImage(named: imageName)
        bgImage.contentMode = .scaleAspectFill
        view.insertSubview(bgImage, at: 0)
    }
    
    func setLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "YP-black")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304)
        ])
    }
    
    func addButton() {
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "YP-black")
        button.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        button.layer.cornerRadius = 16
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func buttonTapped() {
        let nextViewController = TabBarController()
        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true, completion: nil)
    }
}