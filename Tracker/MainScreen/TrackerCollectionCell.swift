//
//  CollectionViewCell.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

class TrackerCollectionCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}

