//
//  ButtonsCell.swift
//  Tracker
//
//  Created by alex_tr on 29.10.2024.
//

import UIKit

class ButtonsCell: UITableViewCell {
    let buttonLabel: UILabel = {
        let buttonLabel = UILabel()
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLabel.font = UIFont.systemFont(ofSize: 17)
        return buttonLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createCanvas()

    }
    
    func createCanvas() {
        contentView.addSubview(buttonLabel)
        NSLayoutConstraint.activate([
            buttonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCornerRadius(for corners: CACornerMask, radius: CGFloat) {
        contentView.layer.cornerRadius = radius
        contentView.layer.maskedCorners = corners
    }
}
