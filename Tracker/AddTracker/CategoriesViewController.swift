//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by alex_tr on 31.10.2024.
//

//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by alex_tr on 31.10.2024.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func saveCategory (categories: [String])
}

final class CategoriesViewController: UIViewController {
    
    private let tableView = UITableView()
    private var selectedCategories = [String]()
    weak var delegate: CategoriesViewControllerDelegate?
    
    let testCategories = ["Категория 1", "Категория 2", "Категория 3", "Категория 4", "Категория 5", "Категория 6", "Категория 7", "Категория 8", "Категория 9", "Категория 10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        createCanvas()
    }
    
    private func createCanvas() {
        let header = UILabel()
        header.text = "Категории"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor(named: "YP-black")
        header.textAlignment = .center
        
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitle("Добавить категорию", for: .normal)
        confirmButton.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        confirmButton.backgroundColor = UIColor(named: "YP-black")
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.layer.cornerRadius = 16
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(self, action: #selector(confirmButtonClicked), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        view.addSubview(tableView)
        
        // Устанавливаем ограничения для tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -16) // Убираем фиксированную высоту
        ])
    }
    
    @objc func confirmButtonClicked() {
        delegate?.saveCategory(categories: selectedCategories)
        dismiss(animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testCategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = testCategories[indexPath.row]
        cell.textLabel?.text = category
        cell.textLabel?.textColor = UIColor(named: "YP-black")
        cell.backgroundColor = UIColor(named: "YP-bg")
        if indexPath.row == testCategories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
        } else {
            cell.separatorInset = .zero
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = testCategories[indexPath.row]
        if let index = selectedCategories.firstIndex(of: category) {
            selectedCategories.remove(at: index) // Удалить, если уже выбрано
        } else {
            selectedCategories.append(category) // Добавить, если не выбрано
        }
    }

}
