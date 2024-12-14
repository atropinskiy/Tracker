//
//  CollectionViewCell.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(_ trackerCell: TrackerCollectionCell, id: UUID, isOn: Bool)
}

final class TrackerCollectionCell: UICollectionViewCell {
    
    weak var delegate: TrackerCellDelegate?
    
    private lazy var emojiLabel = UILabel()
    private lazy var nameLabel = UILabel()
    private lazy var counterLabel = UILabel()
    private lazy var trackerView = UIView()
    private lazy var button = UIButton()
    private lazy var pinImg = UIImageView()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    lazy var isCompleted: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    var currentDate: Date
    var trackerPinned: Bool?
    
    override init(frame: CGRect) {
        self.currentDate = Date()
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    private func setupViews() {
        trackerView.translatesAutoresizingMaskIntoConstraints = false
        trackerView.layer.cornerRadius = 16
        trackerView.layer.masksToBounds = true
        contentView.addSubview(trackerView)
        
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        let emojiBackgroundView = UIView()
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.backgroundColor = UIColor(named: "YP-iconsBg") //
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        trackerView.addSubview(emojiBackgroundView)
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24) // Ширина и высота равны для круга
        ])
        
        
        pinImg.image = UIImage(named: "pinImg")
        pinImg.tintColor = .white
        pinImg.translatesAutoresizingMaskIntoConstraints = false
        trackerView.addSubview(pinImg)
        
        NSLayoutConstraint.activate([
            pinImg.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 18),
            pinImg.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            pinImg.heightAnchor.constraint(equalToConstant: 12),
            pinImg.widthAnchor.constraint(equalToConstant: 8)
        
        ])
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        emojiBackgroundView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor)
        ])
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textColor = UIColor.label
        nameLabel.numberOfLines = 0
        trackerView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
        ])
        
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        counterLabel.text = "1 день"
        counterLabel.font = .systemFont(ofSize: 12, weight: .medium)
        counterLabel.textColor = UIColor.label
        contentView.addSubview(counterLabel)
        NSLayoutConstraint.activate([
            counterLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12),
            counterLabel.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 16)
        ])
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        let buttonDisabledColor = UIColor { (traits: UITraitCollection) -> UIColor in
            if traits.userInterfaceStyle == .light {
                return UIColor.white                                    // светлый режим
            } else {
                return UIColor.black  // тёмный режим
            }
        }
        button.tintColor = buttonDisabledColor
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            button.topAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: 8),
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34)
        ])
        
    }
    
    @objc private func buttonTapped() {
        guard let id = trackerId else { return }
        
        let today = Date()
        if currentDate > today {
            print("Кнопка недоступна для дат в будущем.")
            return
        }
        // Переключаем состояние
        isCompleted.toggle()

        // Обновляем внешний вид кнопки
        button.alpha = isCompleted ? 0.3 : 1.0
        let buttonImage = isCompleted ? UIImage(named: "Done-button") : UIImage(systemName: "plus")
        button.setImage(buttonImage, for: .normal)

        // Добавление или удаление записи
        if isCompleted {
            trackerRecordStore.addRecord(id: id, date: currentDate)
        } else {
            trackerRecordStore.deleteRecord(by: id, on: currentDate)
        }

        // Подсчитываем количество выполненных трекеров для данного id
        let completedCount = trackerRecordStore.countCompletedTrackers(for: id)
        counterLabel.text = daysText(for: completedCount)
    }

    func configure(with tracker: Tracker, isCompletedToday: Bool, isPinned: Bool) {
        print(tracker)
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        trackerView.backgroundColor = tracker.color
        button.backgroundColor = tracker.color
        trackerId = tracker.id

        // Устанавливаем начальное состояние кнопки
        isCompleted = isCompletedToday
        let buttonImage = isCompleted ? UIImage(named: "Done-button") : UIImage(systemName: "plus")
        button.setImage(buttonImage, for: .normal)
        button.alpha = isCompleted ? 0.3 : 1.0
        trackerPinned = isPinned
        
        if isPinned == false{
            pinImg.isHidden = true
        } else {
            pinImg.isHidden = false
        }
        
        // Используем переданную дату для подсчета количества выполненных трекеров
        let completedCount = trackerRecordStore.countCompletedTrackers(for: tracker.id)
        counterLabel.text = daysText(for: completedCount)
    }
       
    private func daysText(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(count) "+"дней".localized()
        } else if lastDigit == 1 {
            return "\(count) " + "день".localized()
        } else if lastDigit >= 2 && lastDigit <= 4 {
            return "\(count) " + "дня".localized()
        } else {
            return "\(count) " + "дней".localized()
        }
    }
}

