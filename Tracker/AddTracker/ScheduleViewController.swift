//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by alex_tr on 30.10.2024.
//
import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func saveSchedule (schedule: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    weak var delegate: ScheduleViewControllerDelegate?
    private var selectedDays: [WeekDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        createCanvas()
    }
    
    private func createCanvas() {
        let header = UILabel()
        header.text = "Расписание".localized()
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor(named: "YP-black")
        header.textAlignment = .center
        
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(named: "YP-bg")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor(named: "YP-gray")
        tableView.allowsSelection = false
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
            
        ])
        
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitle("Готово".localized(), for: .normal)
        confirmButton.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        confirmButton.backgroundColor = UIColor(named: "YP-black")
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.layer.cornerRadius = 16
        confirmButton.layer.masksToBounds = true
        confirmButton.addTarget(self, action: #selector(confirmButtonClicked), for: .touchUpInside)
        view.addSubview(confirmButton)
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        
        
    }
    
    @objc private func daySwitchToggled(_ sender: UISwitch) {
        let weekDay = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedDays.append(weekDay)
        } else {
            selectedDays.removeAll { $0 == weekDay }
        }
    }
    
    @objc private func confirmButtonClicked() {
        delegate?.saveSchedule(schedule: selectedDays)
        dismiss(animated: true)
    }
    
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        let weekDay = WeekDay.allCases[indexPath.row]
        cell.textLabel?.text = weekDay.rawValue.localized()
        cell.textLabel?.textColor = UIColor(named: "YP-black")
        cell.backgroundColor = UIColor(named: "YP-bg")
        cell.daySwitch.isOn = selectedDays.contains(weekDay)
        cell.daySwitch.tag = indexPath.row
        cell.daySwitch.addTarget(self, action: #selector(daySwitchToggled(_:)), for: .valueChanged)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
