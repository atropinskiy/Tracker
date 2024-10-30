//
//  MainViewController.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

final class TrackersViewController: UIViewController {
    var categories = [TrackerCategory]()
    var completedTrackers = [TrackerRecord]()
    
    
    
    private lazy var controlView = UIView()
    private lazy var datePicker = UIDatePicker()
    private lazy var dateButton = UIButton(type: .custom)
    private lazy var addButton = UIButton(type: .custom)
    private lazy var searchTextField = UISearchTextField()
    private lazy var headerLabel = UILabel()
    private lazy var contentView = UIView()
    private lazy var stubImg = UIImageView(image: UIImage(named: "StubImg"))
    private lazy var stubLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        addControlView()
//        addStub()
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
        searchTextField.layer.cornerRadius = 10.0
        searchTextField.backgroundColor = UIColor(named: "YP-bg")
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "YP-gray") ?? UIColor.gray]
        )
        if let leftIconView = searchTextField.leftView as? UIImageView {
            leftIconView.tintColor = UIColor(named: "YP-gray") // Установка цвета иконки лупы
        }
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
        
        datePicker.date = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.locale = Locale(identifier: "ru_RU")
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: controlView.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func addStub() {
        stubImg.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stubImg)
        NSLayoutConstraint.activate([
            stubImg.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stubImg.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stubImg.heightAnchor.constraint(equalToConstant: 80), // Установите желаемую высоту
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
            stubLabel.heightAnchor.constraint(equalToConstant: 18), // Установите желаемую высоту
            stubLabel.widthAnchor.constraint(equalToConstant: 343)
        ])
    }
    
    func showTrackers() {
        let collectionLayot = UICollectionViewFlowLayout()
        collectionLayot.scrollDirection = .vertical
        collectionLayot.minimumLineSpacing = 10
        collectionLayot.minimumInteritemSpacing = 9
        collectionLayot.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayot)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        contentView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 430)
        ])
    }
    
    
       
    @objc func addButtonTapped() {
        let addTrackerVC = TypeSelectViewController()
        addTrackerVC.modalPresentationStyle = .pageSheet
        present(addTrackerVC, animated: true, completion: nil)
    }
    
    @objc func datePickerChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let selectedDate = dateFormatter.string(from: datePicker.date) //
        dateButton.setTitle(selectedDate, for: .normal)
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Укажите количество секций
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 // Укажите количество элементов в секции
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionCell else { return UICollectionViewCell() }
        // Настройте ячейку здесь
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            headerView.backgroundColor = UIColor.lightGray // Например, установка цвета фона
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            // Настройте footerView здесь
            footerView.backgroundColor = UIColor.darkGray // Например, установка цвета фона
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 10, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44) // Высота заголовка
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44) // Высота подвала
    }
}

