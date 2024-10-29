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
    
    private lazy var datePicker = UIDatePicker()
    private lazy var dateButton = UIButton(type: .custom)
    private lazy var addButton = UIButton(type: .custom)
    private lazy var searchTextField = UISearchTextField()
    private lazy var headerLabel = UILabel()
    private lazy var contentView = UIView()
    private lazy var stubImg = UIImageView(image: UIImage(named: "StubImg"))
    private lazy var stubLabel = UILabel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let letters = [ "🍇", "🍈", "🍉", "🍊", "🍋", "🍌", "🍍", "🥭", "🍎", "🍏", "🍐", "🍒", "🍓", "🫐", "🥝", "🍅", "🫒", "🥥", "🥑", "🍆", "🥔", "🥕", "🌽", "🌶️", "🫑", "🥒", "🥬", "🥦", "🧄", "🧅", "🍄"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        addControlView()
        //        addStub()
        addCollectionView()
    }
    
    private func addControlView() {
        let controlView = UIView()
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
        
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: 103),
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
    
    func addCollectionView() {
        collectionView.allowsMultipleSelection = false
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func makeBold(indexPath: IndexPath) {
            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
            cell?.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
        
    private func makeItalic(indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        cell?.titleLabel.font = UIFont.italicSystemFont(ofSize: 17)
    }
    
    @objc func buttonTapped() {
        datePicker.isHidden.toggle()
        if !datePicker.isHidden {
            datePicker.becomeFirstResponder()
        }
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

extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return letters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell
        cell?.titleLabel.text = letters[indexPath.row]
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String                                      // 1
        switch kind {                                       // 2
        case UICollectionView.elementKindSectionHeader:     // 3
            id = "header"
        case UICollectionView.elementKindSectionFooter:     // 4
            id = "footer"
        default:
            id = ""                                         // 5
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView // 6
        view.titleLabel.text = "Здесь находится Supplementary view"
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)                   //
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                         withHorizontalFittingPriority: .required,
                                                         verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let footerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at: indexPath)
        
        return footerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                    withHorizontalFittingPriority: .required,
                                                    verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { // 1
        return CGSize(width: collectionView.bounds.width / 2, height: 50)   // 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { // 2
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell // 3
        cell?.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)                         // 4
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
        cell?.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {   // 1
        guard indexPaths.count > 0 else {                                 // 2
            return nil
        }
        
        let indexPath = indexPaths[0]                                     // 3
        
        return UIContextMenuConfiguration(actionProvider: { actions in    // 4
            return UIMenu(children: [                                     // 5
                UIAction(title: "Bold") { [weak self] _ in                // 6
                    self?.makeBold(indexPath: indexPath)
                },
                UIAction(title: "Italic") { [weak self] _ in              // 7
                    self?.makeItalic(indexPath: indexPath)
                },
            ])
        })
    }
}
