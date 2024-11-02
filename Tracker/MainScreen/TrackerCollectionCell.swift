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
    lazy var isCompleted: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    
    override init(frame: CGRect) {
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
        emojiBackgroundView.backgroundColor = UIColor(named: "YP-bg") //
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        trackerView.addSubview(emojiBackgroundView)
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24) // Ширина и высота равны для круга
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
        nameLabel.textColor = UIColor(named: "YP-white")
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
        counterLabel.textColor = UIColor(named: "YP-black")
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
        button.tintColor = UIColor.white
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
        isCompleted.toggle()
        button.alpha = isCompleted ? 0.3 : 1.0
        let buttonImage = isCompleted ? UIImage(named: "Done-button") : UIImage(systemName: "plus")
        button.setImage(buttonImage, for: .normal)
        if let id = trackerId {
            delegate?.completeTracker(self, id: id, isOn: isCompleted)
        }
    }

    func configure(with tracker: Tracker, completedCount: Int, isCompletedToday: Bool) {
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        trackerView.backgroundColor = tracker.color
        button.backgroundColor = tracker.color
        trackerId = tracker.id
        counterLabel.text = daysText(for: completedCount)
        let buttonImage = isCompletedToday ? UIImage(named: "Done-button") : UIImage(systemName: "plus")
        button.setImage(buttonImage, for: .normal)
        button.alpha = isCompletedToday ? 0.3 : 1.0
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
}

