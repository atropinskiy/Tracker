//
//  MainViewController.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var categories = [TrackerCategory]()
    private var filteredCategories = [(category: TrackerCategory, trackers: [Tracker])]()
    private var currentTrackers = [Tracker]()
    private let trackerStore = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let viewModel = CategoriesViewModel.shared
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIDs = Set<UUID>()
    private var filteredTrackers: [Tracker] = []
    private var isStubVisible: Bool = false
    private var currentDate: Date = Date()
    private var currentSelectedFilter: Int = 0
    private var filtersApplyed: Bool = false
    
    private lazy var controlView: UIView = {
        let controlView = UIView()
        controlView.translatesAutoresizingMaskIntoConstraints = false
        return controlView
    }()
    
    
    
    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(searchFieldEditingDidEnd), for: .editingDidEndOnExit)
        searchTextField.layer.cornerRadius = 10.0
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.label]
        )
        if let leftIconView = searchTextField.leftView as? UIImageView {
            leftIconView.tintColor = UIColor(named: "YP-gray") // Установка цвета иконки лупы
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        searchTextField.addTarget(self, action: #selector(searchFieldTextChanged), for: .editingChanged)
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        return searchTextField
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "plusImg")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.label
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentView: UIView = {
        let controlView = UIView()
        controlView.translatesAutoresizingMaskIntoConstraints = false
        return controlView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = currentDate
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return collectionView
    }()
    
    private lazy var stubImg: UIImageView = {
        var img: UIImage?
        if filtersApplyed {
            img = UIImage(named: "emptyFilters")
        } else {
            img = UIImage(named: "StubImg")
        }

        let imgView = UIImageView(image: img)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    func updateStub() {
        if filtersApplyed {
            stubImg.image = UIImage(named: "emptyFilters")
            stubLabel.text = "Ничего не найдено"
        } else {
            stubImg.image = UIImage(named: "StubImg")
            stubLabel.text = "Что будем отслеживать?"
        }
    }
    
    
    private lazy var stubLabel: UILabel = {
        let stubLabel = UILabel()
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = UIColor.label
        stubLabel.textAlignment = .center
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        return stubLabel
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Фильтры", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP-blue")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        setupView()
        trackerStore.setupFetchedResultsController()
        viewModel.loadCategories()
        categories = viewModel.getCategoriesAsTrackerCategory()
        searchTextField.delegate = self
        filterTrackers()
        showTrackers()
    }
    
    private func setupView() {
        [controlView, contentView, filterButton].forEach{view.addSubview($0)}
        [searchTextField, headerLabel, addButton, datePicker].forEach{controlView.addSubview($0)}
        
        NSLayoutConstraint.activate([
            controlView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlView.heightAnchor.constraint(equalToConstant: 182),
            
            searchTextField.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -10),
            searchTextField.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            headerLabel.bottomAnchor.constraint(equalTo: searchTextField.topAnchor, constant: -7),
            headerLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 254),
            headerLabel.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 16),
            headerLabel.heightAnchor.constraint(equalToConstant: 41),
            
            addButton.bottomAnchor.constraint(equalTo: headerLabel.topAnchor, constant: 1),
            addButton.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 5),
            addButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42),
            
            contentView.topAnchor.constraint(equalTo: controlView.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            datePicker.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 127),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
        
    }
    
    private func addStub() {
        guard !isStubVisible else { return }
        [stubImg, stubLabel].forEach{contentView.addSubview($0)}
        
        
        NSLayoutConstraint.activate([
            stubImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stubImg.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stubImg.heightAnchor.constraint(equalToConstant: 80),
            stubImg.widthAnchor.constraint(equalToConstant: 80),
            
            stubLabel.topAnchor.constraint(equalTo: stubImg.bottomAnchor),
            stubLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stubLabel.heightAnchor.constraint(equalToConstant: 18),
            stubLabel.widthAnchor.constraint(equalToConstant: 343)
        ])
    }
    
    
    
    private func showTrackers() {
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        updateStubVisibility()
    }
    
    @objc private func searchFieldTextChanged() {
        filterTrackers()
    }

    private func filterTrackers() {
        let searchText = searchTextField.text?.lowercased(with: Locale.current) ?? "" // получаем текст из поля поиска и приводим к нижнему регистру
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        var weekday = calendar.component(.weekday, from: startOfDay)
        weekday = (weekday + 5) % 7 // Понедельник — это 0, воскресенье — 6
        guard weekday >= 0 && weekday < WeekDay.allCases.count else {
            return // Если индекс выходит за пределы, выходим из функции
        }
        let selectedWeekday = WeekDay.allCases[weekday]
        filteredTrackers.removeAll()
        filteredCategories.removeAll()
        

        for category in categories {
            if let categoryTrackers = category.trackers {
                let filteredCategoryTrackers = categoryTrackers.filter { tracker in
                    // Обнуляем время у даты трекера для корректного сравнения
                    let trackerDate = calendar.startOfDay(for: tracker.date ?? Date())
                    let isCompletedToday = TrackerRecordStore.shared.isTrackerCompletedToday(trackerId: tracker.id, currentDate: startOfDay)
                    let isDateMatch = calendar.isDate(trackerDate, inSameDayAs: startOfDay)
                    let isWeekdayMatch = tracker.schedule?.contains(selectedWeekday) ?? false
                    let isNameMatch = !searchText.isEmpty ? tracker.name.lowercased().contains(searchText) : true
                    let isTrackerPinned = tracker.pinned

                    switch currentSelectedFilter {
                    case 1:
                        return isDateMatch && isNameMatch || isTrackerPinned
                    case 2:
                        return (isDateMatch || isWeekdayMatch || isTrackerPinned) && isCompletedToday && isNameMatch
                    case 3:
                        return (isDateMatch || isWeekdayMatch || isTrackerPinned) && !isCompletedToday && isNameMatch
                    default:
                        return (isDateMatch || isWeekdayMatch || isTrackerPinned) && isNameMatch
                    }
                }
                
                if !filteredCategoryTrackers.isEmpty {
                    filteredCategories.append((category: category, trackers: filteredCategoryTrackers)) // Добавляем категорию с отфильтрованными трекерами
                }
            }
        }

        // Убираем дубликаты из filteredTrackers по ID
        filteredTrackers = Array(filteredTrackers.reduce(into: [UUID: Tracker]()) { $0[$1.id] = $1 }.values)

        // Перезагружаем данные в collectionView
        collectionView.reloadData()

        // Обновляем видимость заглушки
        updateStubVisibility()
    }

    
    private func updateStubVisibility() {
        updateStub() // Обновляем изображение
        if filteredCategories.allSatisfy({ $0.trackers.isEmpty }) { // Все категории пусты
            addStub() // Добавление "заглушки"
            isStubVisible = true
            collectionView.isHidden = true // Скрыть коллекцию
            if filtersApplyed {
                filterButton.backgroundColor = .red // Красный при активных фильтрах
            } else {
                filterButton.isHidden = true // Скрыть кнопку, если фильтры не применены
            }
        } else {
            // Убираем заглушку, если категории не пусты
            stubImg.removeFromSuperview()
            stubLabel.removeFromSuperview()
            isStubVisible = false
            collectionView.isHidden = false // Показать коллекцию
            if filtersApplyed {
                filterButton.isHidden = false
                filterButton.backgroundColor = UIColor(named: "YP-red") // Красный при активных фильтрах
            } else {
                filterButton.backgroundColor = UIColor(named: "YP-blue") // Синий, если фильтры не активированы
                filterButton.isHidden = false // Показать кнопку
            }
        }
    }

    
    func showDeleteConfirmationAlert(for tracker: Tracker) {
        print("Вызов функции удаления")
        let alertController = UIAlertController(
            title: nil,
            message: "Вы уверены, что хотите удалить этот трекер?",
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.trackerStore.deleteTrackerWithTrackerObj(tracker)
            self.viewModel.loadCategories()
            self.categories = self.viewModel.getCategoriesAsTrackerCategory()
            self.filterTrackers()
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // Показываем алерт
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterTrackers()
    }
    
    @objc private func addButtonTapped() {
        let typeSelectVC = TypeSelectViewController()
        typeSelectVC.delegate = self
        present(typeSelectVC, animated: true, completion: nil)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterTrackersViewController()
        filterVC.selectedFilter = currentSelectedFilter
        filterVC.delegate = self
        present(filterVC, animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func searchFieldEditingDidEnd() {
        searchTextField.resignFirstResponder()
    }
    
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionCell else {
            return UICollectionViewCell()
        }
        
        // Получаем трекер для текущей ячейки
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompletedToday = TrackerRecordStore.shared.isTrackerCompletedToday(trackerId: tracker.id, currentDate: currentDate)
        
        cell.isCompleted = isCompletedToday
        cell.currentDate = currentDate
        cell.configure(with: tracker, isCompletedToday: isCompletedToday, isPinned: tracker.pinned)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected element kind")
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else {
            fatalError("Unable to dequeue header")
        }
        
        headerView.titleLabel.text = categories[indexPath.section].title
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 9)/2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0) // Отступ сверху для секции
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: 30), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func completedCount(for trackerID: UUID) -> Int {
        return completedTrackers.filter { $0.id == trackerID }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {   // 1
        guard indexPaths.count > 0 else {
            return nil
        }
        
        
        let indexPath = indexPaths[0]
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            let pinActionTitle = tracker.pinned ? "Открепить" : "Закрепить"
            let pinAction = UIAction(title: pinActionTitle) { _ in
                if tracker.pinned {
                    self.trackerStore.unpinTracker(tracker: tracker)
                } else {
                    self.trackerStore.pinTracker(tracker: tracker)
                }
                self.viewModel.loadCategories()
                self.categories = self.viewModel.getCategoriesAsTrackerCategory()
                self.filterTrackers()
                self.collectionView.reloadData()
            }

            return UIMenu(children: [
                pinAction,
                UIAction(title: "Редактировать") { _ in
                    let editTrackerVC = TrackerEditViewController(viewModel: self.viewModel, editedTracker: tracker)
                    let category = self.filteredCategories[indexPath.section].category
                    
                    editTrackerVC.selectedCategory = category.title
                    editTrackerVC.delegate = self
                    if let schedule = tracker.schedule, !schedule.isEmpty {
                        // Если schedule не nil и не пустой
                        editTrackerVC.taskType = "Привычка"
                        editTrackerVC.selectedSchedule = daysToString(days: schedule)
                        editTrackerVC.schedule = schedule
                    } else {
                        // Если schedule nil или пустой
                        editTrackerVC.taskType = "Регулярное событие"
                        editTrackerVC.currentDate = self.currentDate
                    }
                    
                    self.present(editTrackerVC, animated: true, completion: nil)
                    
                    func daysToString(days: [WeekDay]) -> String {
                        let dayStrings = days.map { $0.shortDescription }
                        return dayStrings.joined(separator: ", ")
                    }
                },
                UIAction(title: "Удалить", attributes: .destructive) { _ in
                    self.showDeleteConfirmationAlert(for: tracker)
                }
            ])
        })
    }
    
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(_ trackerCell: TrackerCollectionCell, id: UUID, isOn: Bool) {
        let calendar = Calendar.current
        let currentDateWithoutTime = calendar.startOfDay(for: Date())
        let selectedDateWithoutTime = calendar.startOfDay(for: datePicker.date)
        
        if isOn && selectedDateWithoutTime <= currentDateWithoutTime {
            // Добавляем запись в Core Data
            TrackerRecordStore.shared.addRecord(id: id, date: selectedDateWithoutTime)
            
            completedTrackerIDs.insert(id)
            collectionView.reloadData()
            print("Трекер \(id) завершён")
        } else {
            // Удаляем запись из Core Data
            TrackerRecordStore.shared.deleteRecord(by: id, on: selectedDateWithoutTime)
            
            completedTrackerIDs.remove(id)
            collectionView.reloadData()
            print("Трекер \(id) отменён")
        }
    }
}

extension TrackersViewController: AddTrackerViewControllerDelegate {
    func didDeleteTracker() {
        categories = viewModel.getCategoriesAsTrackerCategory()
        filterTrackers()
        collectionView.reloadData()
    }
    
    func didCreateTracker (tracker: Tracker) {
        categories = viewModel.getCategoriesAsTrackerCategory()
        filterTrackers()
        collectionView.reloadData()
    }
    
    func didEditedCategory() {
        categories = viewModel.getCategoriesAsTrackerCategory()
        filterTrackers()
        collectionView.reloadData()
    }
}

extension TrackersViewController: TypeSelectDelegate {
    func didSelectType(_ type: String) {
        let addTrackerVC = AddTrackerViewController(viewModel: viewModel)
        addTrackerVC.delegate = self
        addTrackerVC.taskType = type
        addTrackerVC.currentDate = currentDate
        addTrackerVC.modalPresentationStyle = .pageSheet
        present(addTrackerVC, animated: true, completion: nil)
    }
}

extension TrackersViewController: FilterTrackersViewControllerDelegate {
    func didFilteredTrackers(selectedFilter: Int) {
        let filter = selectedFilter
        let calendar = Calendar.current
        let startOfTheDay = calendar.startOfDay(for: Date())
        
        if filter == 1 {
            datePicker.date = startOfTheDay
            currentSelectedFilter = 0
            categories = viewModel.getCategoriesAsTrackerCategory()
            filtersApplyed = false
            
            
        } else if filter == 0 {
            print("Возвращаем и снимаем фильтры")
            categories = viewModel.getCategoriesAsTrackerCategory()
            currentSelectedFilter = 0
            filtersApplyed = false
        }
        else {
            currentSelectedFilter = selectedFilter
            filtersApplyed = true
        }
        
        updateStubVisibility()
        filterTrackers()
        showTrackers()
        collectionView.reloadData()
        
    }
}

extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        filterTrackers()
        print(123)
        return true
    }
}

extension TrackersViewController: TrackerEditViewControllerDelegate {
    func didEditTracker(tracker: Tracker) {
        categories = viewModel.getCategoriesAsTrackerCategory()
        filterTrackers()
        showTrackers()
        collectionView.reloadData()
    }

    
}
