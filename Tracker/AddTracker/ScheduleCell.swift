//
//  ScheduleCell.swift
//  Tracker
//
//  Created by alex_tr on 30.10.2024.
//

import UIKit

class ScheduleCell: UITableViewCell {
    let daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = UIColor(named: "YP-blue")
        return daySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    private func setupCell() {
        contentView.addSubview(daySwitch)

        NSLayoutConstraint.activate([
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
