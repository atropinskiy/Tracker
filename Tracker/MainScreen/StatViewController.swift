//
//  StatViewController.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

class StatViewController: UIViewController {
    private lazy var header = UILabel()
    private lazy var contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        createCanvas()
        addStub()
    }
    
    private func createCanvas() {
        header.text = "Статистика"
        header.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        header.textColor = UIColor(named: "YP-black")
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
    }
    
    private func addStub() {
        
        lazy var stubImg = UIImageView()
        lazy var stubLabel = UILabel()
        
        stubImg.image = UIImage(named: "Stat-Stub")
        contentView.addSubview(stubImg)
        stubImg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stubImg.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stubImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        stubLabel.text = "Анализировать пока нечего"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = UIColor(named: "YP-black")
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        stubLabel.textAlignment = .center
        contentView.addSubview(stubLabel)
        NSLayoutConstraint.activate([
            stubLabel.topAnchor.constraint(equalTo: stubImg.bottomAnchor, constant: 0),
            stubLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stubLabel.widthAnchor.constraint(equalToConstant: 343)
        ])
    }
    
}
