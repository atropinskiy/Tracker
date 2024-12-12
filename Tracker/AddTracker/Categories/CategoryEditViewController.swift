//
//  CategoryEditViewController.swift
//  Tracker
//
//  Created by alex_tr on 12.12.2024.
//

import UIKit

protocol CategoryEditViewControllerDelegate: AnyObject {
    func didEditedCategory(newCategoryName: String)
}

final class CategoryEditViewController: UIViewController {
    var currentName: String?
    weak var delegate: CategoryEditViewControllerDelegate?
    private let viewModel = CategoriesViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        createCanvas()
    }
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Редактирование категории"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor(named: "YP-black")
        header.textAlignment = .center
        return header
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.text = currentName
        textField.backgroundColor = UIColor(named: "YP-categories")
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
        )
        textField.safeSetPadding(left: 16, right: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP-black")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()
    
    private func createCanvas() {
        [header, textField, doneButton].forEach{view.addSubview($0)}
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 150),
            textField.topAnchor.constraint(equalTo: header.topAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func doneTapped() {
        guard let title = textField.text, !title.isEmpty else {
            // Показать alert, если название пустое
            showAlert(message: "Название не может быть пустым.")
            return
        }
        
        guard let currentName = currentName else {
            showAlert(message: "Текущее название не найдено.")
            return
        }
        
        viewModel.editCategory(title: currentName, newTitle: title)
        delegate?.didEditedCategory(newCategoryName: title)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}


