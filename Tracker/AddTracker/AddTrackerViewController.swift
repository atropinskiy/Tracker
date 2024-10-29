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
        
        if taskType == "Привычка" {
            createCanvas()
        }
    }
    
    private func createCanvas() {
        let headLabel = UILabel()
        headLabel.text = "Новая привычка"
        headLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        headLabel.textAlignment = .center
        headLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headLabel)
        
        NSLayoutConstraint.activate([
            headLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            headLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headLabel.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 500) // Вместо фиксированной высоты
        ])
        
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "YP-lightgray")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.masksToBounds = true
        textField.enablesReturnKeyAutomatically = true
        textField.smartInsertDeleteType = .no
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.setPadding(left: 16, right: 16)
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        let buttonsTable = UITableView()
        buttonsTable.translatesAutoresizingMaskIntoConstraints = false
        buttonsTable.layer.cornerRadius = 16
        buttonsTable.layer.masksToBounds = true
        buttonsTable.register(ButtonsCell.self, forCellReuseIdentifier: "ButtonsCell")
        buttonsTable.delegate = self
        buttonsTable.dataSource = self
        contentView.addSubview(buttonsTable)
        NSLayoutConstraint.activate([
            buttonsTable.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            buttonsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsTable.heightAnchor.constraint(equalToConstant: 150)
            
        ])
        
    }
}

extension AddTrackerViewController: TypeSelectDelegate {
    func didSelectType(_ type: String) {
        self.taskType = type
    }
}

extension AddTrackerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 38
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.becomeFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // У нас 2 кнопки
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonsCell", for: indexPath) as? ButtonsCell else {
            return UITableViewCell()
        }
        let buttonTitles = ["Категория", "Расписание"]
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = buttonTitles[indexPath.row]
        cell.backgroundColor = UIColor(named: "YP-lightgray")
        cell.buttonLabel.tag = indexPath.row // Устанавливаем тег для идентификации кнопки
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let buttonIndex = sender.tag
        print("Кнопка \(buttonIndex + 1) нажата")
        // Здесь добавьте логику, которая должна выполняться при нажатии на кнопку
    }
}
