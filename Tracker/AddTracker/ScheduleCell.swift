//
//  ScheduleCell.swift
//  Tracker
//
//  Created by alex_tr on 30.10.2024.
//

import UIKit

final class ScheduleCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    let daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.tintColor = UIColor(named: "YP-lightgray")
        daySwitch.onTintColor = UIColor(named: "YP-blue")
        return daySwitch
    }()

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
