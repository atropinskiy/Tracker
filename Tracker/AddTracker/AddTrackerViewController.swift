//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit

class AddTrackerViewController: UIViewController {
    var taskType: String?
    private var schedule: [WeekDay] = []

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
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let textField = UITextField()
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
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "EmojiAndColorCell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: buttonsTable.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 430)
        ])
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.layer.cornerRadius = 18
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.backgroundColor = UIColor(named: "YP-white")
        cancelButton.setTitleColor(UIColor(named: "YP-red"), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.borderColor = UIColor(named: "YP-red")?.cgColor
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let createButton = UIButton(type: .custom)
        createButton.setTitle("Создать", for: .normal)
        createButton.layer.borderWidth = 1
        createButton.layer.cornerRadius = 18
        createButton.layer.masksToBounds = true
        createButton.backgroundColor = UIColor(named: "YP-gray")
        createButton.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.layer.borderColor = UIColor(named: "YP-gray")?.cgColor
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    private func tapScheduleCell(){
        lazy var scheduleViewController = ScheduleViewController()
        scheduleViewController.delegate = self
        present(scheduleViewController, animated: true)
    }
}

extension AddTrackerViewController: TypeSelectDelegate {
    func didSelectType(_ type: String) {
        self.taskType = type
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 { // Вторая кнопка
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true, completion: nil)
        }
    }
}

extension AddTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Одна для эмодзи и одна для цветов
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return collectionEmojies.count // Количество эмодзи
        } else {
            return collectionColors.count // Количество цветов
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiAndColorCell", for: indexPath) as? CollectionCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            // Настраиваем ячейку для эмодзи
            cell.setText(text: collectionEmojies[indexPath.row])
        } else {
            // Настраиваем ячейку для цвета
            cell.setColor(color: collectionColors[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50) // Размер ячейки
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40) // Высота заголовка
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            
            // Удалите все предыдущие подписи из заголовка, если они есть
            header.subviews.forEach { $0.removeFromSuperview() }
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            label.textColor = UIColor(named: "YP-black")
            
            if indexPath.section == 0 {
                label.text = "Эмодзи"
            } else {
                label.text = "Цвета"
            }
            
            header.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: header.topAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
                label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16)
            ])
            
            return header
        }
        return UICollectionReusableView()
    }
}

extension AddTrackerViewController: ScheduleViewControllerDelegate {
    func createSchedule(schedule: [WeekDay]) {
        self.schedule = schedule
    }
}

