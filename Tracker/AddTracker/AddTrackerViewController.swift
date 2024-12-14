//
//  AddTrackerViewController.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit
protocol AddTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(tracker: Tracker)
    func didDeleteTracker()
    func didEditedCategory()
}

final class AddTrackerViewController: UIViewController {
    var taskType: String?
    var currentDate: Date?
    
    
    weak var delegate: AddTrackerViewControllerDelegate?
    private lazy var headerTextField = UITextField()
    private var schedule: [WeekDay] = []
    private lazy var buttonTitles: [String] = []
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategory: String?
    private var selectedSchedule: String?
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var buttonsTable = UITableView()
    private var viewModel = CategoriesViewModel.shared
    lazy var createButton = UIButton(type: .custom)
    private let trackerStore = TrackerStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Не отменяем касания для других элементов
        view.addGestureRecognizer(tapGesture)
        headerTextField.delegate = self
        
        if taskType == "Привычка" {
            buttonTitles = ["Категория".localized(), "Расписание".localized()]
        } else {
            buttonTitles = ["Категория".localized()]
        }
        updateCollectionViewHeight()
        createCanvas()
    }
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCollectionViewHeight() {
        let totalItems = collectionEmojies.count + collectionColors.count
        let numberOfRows = ceil(Double(totalItems) / Double(6))
        let collectionHeight = CGFloat(numberOfRows) * 52 + CGFloat(4) * 24 + CGFloat(2) * 18 // Высота коллекции с учетом отступов
        
        // Обновите высоту коллекции
        collectionView.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        collectionView.layoutIfNeeded() // Перерисовать коллекцию
    }
    
    private func createCanvas() {
        let headLabel = UILabel()
        headLabel.text = "Новая привычка".localized()
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
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        headerTextField.layer.cornerRadius = 16
        headerTextField.font = UIFont.systemFont(ofSize: 17)
        headerTextField.backgroundColor = UIColor(named: "YP-bg")
        headerTextField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера".localized(),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
        )
        headerTextField.safeSetPadding(left: 16, right: 16)
        headerTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerTextField)
        NSLayoutConstraint.activate([
            headerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        buttonsTable.translatesAutoresizingMaskIntoConstraints = false
        buttonsTable.layer.cornerRadius = 16
        buttonsTable.layer.masksToBounds = true
        buttonsTable.register(ButtonsCell.self, forCellReuseIdentifier: "ButtonsCell")
        buttonsTable.backgroundColor = UIColor(named: "YP-bg")
        buttonsTable.delegate = self
        buttonsTable.dataSource = self
        buttonsTable.separatorColor = UIColor(named: "YP-gray")
        contentView.addSubview(buttonsTable)
        NSLayoutConstraint.activate([
            buttonsTable.topAnchor.constraint(equalTo: headerTextField.bottomAnchor, constant: 24),
            buttonsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsTable.heightAnchor.constraint(equalToConstant: CGFloat(buttonTitles.count) * 75)
            
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        collectionView.isScrollEnabled = false
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: buttonsTable.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отменить".localized(), for: .normal)
        cancelButton.layer.cornerRadius = 18
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.backgroundColor = UIColor(named: "YP-white")
        cancelButton.setTitleColor(UIColor(named: "YP-red"), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.borderColor = UIColor(named: "YP-red")?.cgColor
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        
        createButton.setTitle("Создать".localized(), for: .normal)
        createButton.layer.borderWidth = 1
        createButton.layer.cornerRadius = 18
        createButton.layer.masksToBounds = true
        createButton.backgroundColor = UIColor(named: "YP-gray")
        createButton.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.layer.borderColor = UIColor(named: "YP-gray")?.cgColor
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(createButtonClicked), for: .touchUpInside)
        
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
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка".localized(), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCreateButtonState() {
        let isAllFieldsFilled = !headerTextField.text!.isEmpty &&
        selectedCategory != "" &&
        (taskType == "Привычка" ? !schedule.isEmpty : currentDate != nil) &&
        selectedEmoji != "" &&
        selectedColor != nil
        print(isAllFieldsFilled)
        
        createButton.isEnabled = isAllFieldsFilled
        if isAllFieldsFilled {
            createButton.backgroundColor = isAllFieldsFilled ? UIColor(named: "YP-black") : .black
        }
        
    }
    
    @objc private func cancelButtonClicked(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonClicked() {
        guard let trackerName = headerTextField.text, !trackerName.isEmpty else {
            return
        }
        guard let color = selectedColor, let emoji = selectedEmoji else {
            return
        }
        
        guard let categoryTitle = selectedCategory else {
                print("Категория не выбрана.")
                return
            }
        
        let id = UUID()
        let new_schedule = taskType == "Привычка" ? schedule : nil
        let date: Date? = taskType == "Привычка" ? nil : currentDate
        let tracker = Tracker(id: id, name: trackerName, color: color, emoji: emoji, schedule: new_schedule, date: date, pinned: false)
        trackerStore.addTracker(id: id, name: trackerName, color: color, emoji: emoji, schedule: new_schedule, date: date)
        viewModel.assignCategoryToTracker(categoryTitle: categoryTitle, trackerId: id)
        delegate?.didCreateTracker(tracker: tracker)
        // Закрываем экран после добавления
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddTrackerViewController: TypeSelectDelegate {
    func didSelectType(_ type: String) {
        self.taskType = type
    }
}

extension AddTrackerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonsCell", for: indexPath) as? ButtonsCell else {
            return UITableViewCell()
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "YP-bg")
        cell.selectionStyle = .none
        
        let rowCount = tableView.numberOfRows(inSection: indexPath.section)
        
        if rowCount == 1 {
            // Если в таблице только одна ячейка, убираем разделитель
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            let categoryText = selectedCategory ?? ""
            cell.set(mainText: "Категория".localized(), additionalText: categoryText)
            cell.layoutMargins = .zero
        } else {
            // Здесь ваш текущий код для настройки ячеек
            if indexPath.row == 0 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                let categoryText = selectedCategory ?? ""
                cell.set(mainText: "Категория".localized(), additionalText: categoryText)
            } else if indexPath.row == 1 {
                let scheduleText = selectedSchedule ?? ""
                cell.set(mainText: "Расписание".localized(), additionalText: scheduleText)
                
                if indexPath.row == rowCount - 1 {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                    cell.layoutMargins = .zero
                } else {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                    cell.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true, completion: nil)
        }
        else {
            let categoryViewController = CategoriesViewController(viewModel: viewModel)
            categoryViewController.delegate = self
            present(categoryViewController, animated: true, completion: nil)
        }
    }
    
    
}

extension AddTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Одна для эмодзи и одна для цветов
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return collectionEmojies.count
        } else {
            return collectionColors.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.setText(text: "")
        cell.setColor(color: .clear)
        
        if indexPath.section == 0 {
            let emoji = collectionEmojies[indexPath.item]
            cell.setText(text: emoji)
            if selectedEmojiIndex == indexPath {
                cell.contentView.backgroundColor = UIColor(named: "YP-lightgray")
                cell.contentView.layer.cornerRadius = 16
            } else {
                cell.contentView.backgroundColor = UIColor.clear
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
        } else {
            let color = collectionColors[indexPath.item]
            cell.setColor(color: color)
            
            if selectedColorIndex == indexPath {
                cell.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                cell.layer.cornerRadius = 8
            } else {
                cell.contentView.backgroundColor = UIColor.clear
                cell.layer.borderWidth = 0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52) // Размер ячейки
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // Вертикальный отступ между строками
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5 // Горизонтальный отступ между элементами в строке
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19) // Задайте нужные отступы
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18) // Высота заголовка
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            
            header.subviews.forEach { $0.removeFromSuperview() }
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            label.textColor = UIColor(named: "YP-black")
            
            label.text = indexPath.section == 0 ? "Emojii" : "Цвет".localized()
            
            header.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: header.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 28)
            ])
            
            
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmojiIndex = indexPath
            selectedEmoji = collectionEmojies[indexPath.item]
            collectionView.reloadData()
            updateCreateButtonState()
            
        } else { // Цвет
            selectedColorIndex = indexPath
            selectedColor = collectionColors[indexPath.item]
            collectionView.reloadData()
            updateCreateButtonState()
            
        }
    }

}

extension AddTrackerViewController: ScheduleViewControllerDelegate {
    func saveSchedule(schedule: [WeekDay]) {
        self.schedule = schedule
        selectedSchedule = daysToString(days: schedule)
        updateCreateButtonState()
        buttonsTable.reloadData()
    }
    
    func daysToString(days: [WeekDay]) -> String {
        let dayStrings = days.map { $0.shortDescription }
        return dayStrings.joined(separator: ", ")
    }
}

extension AddTrackerViewController: CategoriesViewControllerDelegate {
    func didSelectCategory(category: String) {
        selectedCategory = category
        updateCreateButtonState()
        buttonsTable.reloadData()
        print("Сохраненная категория: \(category)")
    }
    func didDeleteCategory() {
        delegate?.didDeleteTracker()
    }
    
    func didEditedCategory() {
        delegate?.didEditedCategory()
    }
}

extension AddTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Скрыть клавиатуру
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textField {
            print(textField)
        }
        updateCreateButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        // Вызываем функцию при каждом изменении текста
        updateCreateButtonState()
        
        return true
    }
}
