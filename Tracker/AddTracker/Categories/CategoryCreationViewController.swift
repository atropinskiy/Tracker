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
    private lazy var header = UILabel()
    private lazy var textField = UITextField()
    private lazy var doneButton = UIButton(type: .system)
    var onCategoryCreated: ((Category) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        header.text = "Новая категория"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor(named: "YP-black")
        header.textAlignment = .center
        
        textField.placeholder = "Название категории"
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "YP-categories")
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название категории",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
        )
        textField.safeSetPadding(left: 16, right: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false


        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(named: "YP-gray")
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        view.addSubview(doneButton)
        view.addSubview(header)
        view.addSubview(textField)
        view.addSubview(doneButton)
        

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
        
        // Меняем цвет кнопки при введении 3 или более символов
        if text.count >= 1 {
            doneButton.backgroundColor = UIColor(named: "YP-black")
        } else {
            doneButton.backgroundColor = UIColor(named: "YP-gray")
        }
    }

    @objc private func doneTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
        delegate?.didCreateCategory(title)
        // Возвращаемся на предыдущий экран
        dismiss(animated: true, completion: nil)
    }
}
