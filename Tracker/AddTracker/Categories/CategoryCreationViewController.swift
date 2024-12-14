//
//  CategoryCreationVC.swift
//  Tracker
//
//  Created by alex_tr on 02.12.2024.
//

import UIKit

protocol CategoryCreationViewControllerDelegate: AnyObject {
    func didCreateCategory(_ category: String)
}


final class CategoryCreationViewController: UIViewController {
    
    weak var delegate: CategoryCreationViewControllerDelegate?
    var onCategoryCreated: ((Category) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private lazy var header: UILabel = {
         let label = UILabel()
        label.text = "Новая категория".localized()
         label.font = .systemFont(ofSize: 16, weight: .medium)
         label.textColor = UIColor(named: "YP-black")
         label.textAlignment = .center
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
    
    private lazy var textField: UITextField = {
         let textField = UITextField()
         textField.layer.cornerRadius = 16
         textField.backgroundColor = UIColor(named: "YP-bg")
         textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории".localized(),
             attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
         )
         textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
         textField.safeSetPadding(left: 16, right: 16)
         textField.translatesAutoresizingMaskIntoConstraints = false
         return textField
     }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово".localized(), for: .normal)
        button.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP-gray")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP-white")
        [header, textField, doneButton].forEach{view.addSubview($0)}

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 150),
            textField.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 38),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func textChanged() {
        let text = textField.text ?? ""
        doneButton.isEnabled = !text.isEmpty
        
        if text.count >= 1 {
            doneButton.backgroundColor = UIColor(named: "YP-black")
        } else {
            doneButton.backgroundColor = UIColor(named: "YP-gray")
        }
    }

    @objc private func doneTapped() {
        guard let title = textField.text, !title.isEmpty else {
            return
        }
        
        if title == "Закрепленные" || title == "Pinned" {
            // Выводим предупреждение, если это название
            let alert = UIAlertController(title: "Ошибка", message: "Категория с названием 'Закрепленные' не может быть создана.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        delegate?.didCreateCategory(title)
        
        dismiss(animated: true, completion: nil)
    }
}
