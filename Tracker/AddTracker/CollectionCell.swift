//
//  CollectionCell.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeCanvas()
    }
    
    private func makeCanvas() {
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .center
        contentView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
    
    func setColor(color: UIColor) {
        headerLabel.backgroundColor = color
        headerLabel.layer.cornerRadius = 8
        headerLabel.layer.masksToBounds = true
    }
    
    func setText(text: String) {
        headerLabel.text = text
        headerLabel.font = UIFont.systemFont(ofSize: 32)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
