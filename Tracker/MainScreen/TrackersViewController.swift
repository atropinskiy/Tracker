//
//  MainViewController.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    private var categories = [TrackerCategory]()
    private var currentTrackers = [Tracker]()
    
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIDs = Set<UUID>()
    private var filteredTrackers: [Tracker] = []
    private var isStubVisible: Bool = false
    private var currentDate: Date = Date()
    
    
    private lazy var controlView = UIView()
    private lazy var datePicker = UIDatePicker()
    private lazy var addButton = UIButton(type: .custom)
    private lazy var searchTextField = UISearchTextField()
    lazy var headerLabel = UILabel()
    private lazy var contentView = UIView()
    private lazy var stubImg = UIImageView(image: UIImage(named: "StubImg"))
    private lazy var stubLabel = UILabel()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: "TrackerCell")
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        addControlView()
        //        addStub()
        let testCategory = TrackerCategory(title: "Тестовая категория", trackers: testTrackers)
        categories.append(testCategory)
        currentTrackers = testTrackers
        filterTrackers()
        showTrackers()
    }
    
    private func addControlView() {
        controlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlView)
        NSLayoutConstraint.activate([
            controlView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlView.heightAnchor.constraint(equalToConstant: 182)
        ])
        
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(searchFieldEditingDidEnd), for: .editingDidEndOnExit)
        searchTextField.layer.cornerRadius = 10.0
        searchTextField.backgroundColor = UIColor(named: "YP-searchfieldbg")
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
        )
        if let leftIconView = searchTextField.leftView as? UIImageView {
            leftIconView.tintColor = UIColor(named: "YP-gray") // Установка цвета иконки лупы
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        controlView.addSubview(searchTextField)
        NSLayoutConstraint.activate([
            searchTextField.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -10),
            searchTextField.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        headerLabel.text = "Трекеры"
        headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        controlView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.bottomAnchor.constraint(equalTo: searchTextField.topAnchor, constant: -7),
            headerLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 254),
            headerLabel.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 16),
            headerLabel.heightAnchor.constraint(equalToConstant: 41)
        ])
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(named: "plusImg"), for: .normal)
        addButton.tintColor = .black
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        controlView.addSubview(addButton)
        
        // Устанавливаем размеры кнопки
        NSLayoutConstraint.activate([
            addButton.bottomAnchor.constraint(equalTo: headerLabel.topAnchor, constant: 1),
            addButton.leadingAnchor.constraint(equalTo: controlView.leadingAnchor, constant: 5),
            addButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42)// Положение кнопки
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: controlView.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        datePicker.date = currentDate
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        controlView.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 127)
        ])
    }
    
    private func addStub() {
        guard !isStubVisible else { return }
        
        stubImg.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stubImg)
        NSLayoutConstraint.activate([
            stubImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stubImg.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stubImg.heightAnchor.constraint(equalToConstant: 80),
            stubImg.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        stubLabel.text = "Что будем отслеживать?"
        stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        stubLabel.textAlignment = .center
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        stubLabel.textColor = UIColor(named: "YP-black")
        
        contentView.addSubview(stubLabel)
        NSLayoutConstraint.activate([
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
    
    private func filterTrackers() {
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        var weekday = calendar.component(.weekday, from: selectedDate)
        weekday = (weekday + 5) % 7
        filteredTrackers.removeAll()
        
        for category in categories {
            for tracker in category.trackers where (tracker.schedule?.contains(WeekDay.allCases[weekday]) ?? false) || tracker.date == currentDate {
                filteredTrackers.append(tracker)
            }
        }
        
        let completedTrackersForToday = completedTrackers.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        for trackerRecord in completedTrackersForToday {
            if let tracker = categories.flatMap({ $0.trackers }).first(where: { $0.id == trackerRecord.id }) {
                filteredTrackers.append(tracker)
            }
        }
        
        filteredTrackers = Array(filteredTrackers.reduce(into: [UUID: Tracker]()) { $0[$1.id] = $1 }.values)
        
        collectionView.reloadData()
        updateStubVisibility()
    }
    
    
    private func updateStubVisibility() {
        if filteredTrackers.isEmpty {
            addStub()
            isStubVisible = true
            collectionView.isHidden = true
        } else {
            stubImg.removeFromSuperview()
            stubLabel.removeFromSuperview()
            isStubVisible = false
            collectionView.isHidden = false
        }
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func searchFieldEditingDidEnd() {
        searchTextField.resignFirstResponder()
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredTrackers[indexPath.item]
        let isCompletedToday = completedTrackers.contains {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        cell.isCompleted = isCompletedToday
        
        let completedCount = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configure(with: tracker, completedCount: completedCount, isCompletedToday: isCompletedToday)
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
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(_ trackerCell: TrackerCollectionCell, id: UUID, isOn: Bool) {
        let calendar = Calendar.current
        let currentDateWithoutTime = calendar.startOfDay(for: Date())
        let selectedDateWithoutTime = calendar.startOfDay(for: datePicker.date)
        
        if isOn && selectedDateWithoutTime <= currentDateWithoutTime{
            completedTrackerIDs.insert(id)
            let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
            completedTrackers.append(trackerRecord)
            collectionView.reloadData()
            if !completedTrackers.contains(where: { $0.id == id && calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                completedTrackers.append(trackerRecord)
            }
            print(completedTrackers)
            
        } else {
            completedTrackerIDs.remove(id)
            if let index = completedTrackers.firstIndex(where: { $0.id == id && calendar.isDate($0.date, inSameDayAs: currentDate) }) {
                completedTrackers.remove(at: index)
                print(completedTrackerIDs)
            }
            collectionView.reloadData()
        }
    }
}

extension TrackersViewController: AddTrackerViewControllerDelegate {
    func didSelectEmoji(_ emoji: String) {
    }
    
    func didSelectColor(_ color: UIColor) {
    }
    
    func didCreateTracker (tracker: Tracker) {
        print(tracker)
        currentTrackers.append(tracker)
        let newCategory = TrackerCategory(title: "Новая категория", trackers: currentTrackers)
        self.categories = [newCategory]
        filterTrackers()
        collectionView.reloadData()
        
        
    }
}

extension TrackersViewController: TypeSelectDelegate {
    func didSelectType(_ type: String) {
        let addTrackerVC = AddTrackerViewController()
        addTrackerVC.delegate = self
        addTrackerVC.taskType = type
        addTrackerVC.currentDate = currentDate
        addTrackerVC.modalPresentationStyle = .pageSheet
        present(addTrackerVC, animated: true, completion: nil)
    }
}


