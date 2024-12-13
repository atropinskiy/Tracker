//
//  TrackerEditViewController.swift
//  Tracker
//
//  Created by alex_tr on 13.12.2024.
//

import UIKit
protocol TrackerEditViewControllerDelegate: AnyObject {
    func didEditTracker(tracker: Tracker)
    func didDeleteTracker()
    func didEditedCategory()
}


final class TrackerEditViewController: UIViewController {
    var taskType: String?
    var currentDate: Date?
    
    private var editedTracker: Tracker
    
    weak var delegate: TrackerEditViewControllerDelegate?
    var schedule: [WeekDay] = []
    private lazy var buttonTitles: [String] = []
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    var selectedCategory: String?
    var selectedSchedule: String?
    private let trackerRecordStore = TrackerRecordStore.shared
    private let trackerStore = TrackerStore.shared
    
    
    
    private var viewModel = CategoriesViewModel.shared
    
    
    init(viewModel: CategoriesViewModel, editedTracker: Tracker) {
        self.viewModel = viewModel
        self.editedTracker = editedTracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Не отменяем касания для других элементов
        view.addGestureRecognizer(tapGesture)
        headerTextField.delegate = self
        
        if taskType == "Привычка" {
            buttonTitles = ["Категория", "Расписание"]
        } else {
            buttonTitles = ["Категория"]
        }
        updateCollectionViewHeight()
        
        if let emojiIndex = collectionEmojies.firstIndex(of: editedTracker.emoji) {
            selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
            collectionView.selectItem(at: selectedEmojiIndex, animated: false, scrollPosition: [])
            selectedEmoji = collectionEmojies[emojiIndex]
        }
        
        // Установка начального выбранного цвета
        if let colorIndex = collectionColors.firstIndex(of: editedTracker.color) {
            selectedColorIndex = IndexPath(item: colorIndex, section: 1)
            collectionView.selectItem(at: selectedColorIndex, animated: false, scrollPosition: [])
            selectedColor = collectionColors[colorIndex]
        }
        
        collectionView.reloadData()
        
        createCanvas()
        updateCreateButtonState()
    }
    
    private lazy var headLabel: UILabel = {
        let label = UILabel()
        if taskType == "Привычка" {
            label.text = "Редактирование привычки"
        } else {
            label.text = "Редактировние нерегулярного события"
        }
        
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let count = trackerRecordStore.countCompletedTrackers(for: editedTracker.id)
        let label = UILabel()
        label.text = "\(daysText(for: count))"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private lazy var headerTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.backgroundColor = UIColor(named: "YP-categories")
        textField.text = editedTracker.name
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
        )
        textField.safeSetPadding(left: 16, right: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var buttonsTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        table.register(ButtonsCell.self, forCellReuseIdentifier: "ButtonsCell")
        table.backgroundColor = UIColor(named: "YP-categories")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: "CollectionCell")
        collectionView.isScrollEnabled = false
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        return collectionView
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Отменить", for: .normal)
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.backgroundColor = UIColor(named: "YP-white")
        button.setTitleColor(UIColor(named: "YP-red"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor(named: "YP-red")?.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Сохранить", for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 18
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(named: "YP-gray")
        button.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor(named: "YP-gray")?.cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(saveButtonClicked), for: .touchUpInside)
        return button
    }()

    
    func updateCollectionViewHeight() {
        let totalItems = collectionEmojies.count + collectionColors.count
        let numberOfRows = ceil(Double(totalItems) / Double(6))
        let collectionHeight = CGFloat(numberOfRows) * 52 + CGFloat(4) * 24 + CGFloat(2) * 18 // Высота коллекции с учетом отступов
        
        // Обновите высоту коллекции
        collectionView.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        collectionView.layoutIfNeeded() // Перерисовать коллекцию
    }
    
    private func createCanvas() {
        [headLabel, scrollView].forEach{view.addSubview($0)}
        [contentView].forEach{scrollView.addSubview($0)}
        [counterLabel, headerTextField, buttonsTable, collectionView, buttonStackView].forEach{contentView.addSubview($0)}
        NSLayoutConstraint.activate([
            headLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            headLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: headLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            counterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            counterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            counterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            headerTextField.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 40),
            headerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            buttonsTable.topAnchor.constraint(equalTo: headerTextField.bottomAnchor, constant: 24),
            buttonsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonsTable.heightAnchor.constraint(equalToConstant: CGFloat(buttonTitles.count) * 75),
            
            collectionView.topAnchor.constraint(equalTo: buttonsTable.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func daysText(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(count) дней"
        } else if lastDigit == 1 {
            return "\(count) день"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCreateButtonState() {
        let isAllFieldsFilled = !headerTextField.text!.isEmpty &&
        selectedCategory != "" &&
        selectedSchedule != "" &&
        (taskType == "Привычка" ? !schedule.isEmpty : currentDate != nil) &&
        selectedEmoji != "" &&
        selectedColor != nil

        
        createButton.isEnabled = isAllFieldsFilled
        if isAllFieldsFilled {
            createButton.backgroundColor = isAllFieldsFilled ? UIColor(named: "YP-black") : .black
        }
        
    }
    
    @objc private func cancelButtonClicked(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonClicked() {
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
        
        let id = editedTracker.id

        let new_schedule = taskType == "Привычка" ? schedule : nil
        let date: Date? = taskType == "Привычка" ? nil : currentDate
        let tracker = Tracker(id: id, name: trackerName, color: color, emoji: emoji, schedule: new_schedule, date: date, pinned: editedTracker.pinned)
        trackerStore.editTracker(id: id, name: trackerName, color: color, emoji: emoji, schedule: new_schedule, date: date)
        viewModel.assignCategoryToTracker(categoryTitle: categoryTitle, trackerId: id)
        delegate?.didEditTracker(tracker: tracker)
        // Закрываем экран после добавления
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension TrackerEditViewController: TypeSelectDelegate {
    func didSelectType(_ type: String) {
        self.taskType = type
    }
}

extension TrackerEditViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            cell.set(mainText: "Категория", additionalText: categoryText)
            cell.layoutMargins = .zero
        } else {
            // Здесь ваш текущий код для настройки ячеек
            if indexPath.row == 0 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                let categoryText = selectedCategory ?? ""
                cell.set(mainText: "Категория", additionalText: categoryText)
            } else if indexPath.row == 1 {
                let scheduleText = selectedSchedule ?? ""
                cell.set(mainText: "Расписание", additionalText: scheduleText)
                
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

extension TrackerEditViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            
            label.text = indexPath.section == 0 ? "Emojii" : "Цвет"
            
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

extension TrackerEditViewController: ScheduleViewControllerDelegate {
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

extension TrackerEditViewController: CategoriesViewControllerDelegate {
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

extension TrackerEditViewController: UITextFieldDelegate {
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
}

