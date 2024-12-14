//
//  FilterTrackercViewController.swift
//  Tracker
//
//  Created by alex_tr on 12.12.2024.
//

import UIKit

protocol FilterTrackersViewControllerDelegate: AnyObject {
    func didFilteredTrackers(selectedFilter: Int)
}

final class FilterTrackersViewController: UIViewController {
    weak var delegate: FilterTrackersViewControllerDelegate?
    private let filters = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    var selectedFilter: Int?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        createCanvas()
    }
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Фильтры"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor(named: "YP-black")
        header.textAlignment = .center
        return header
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor(named: "YP-bg")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.separatorColor = UIColor(named: "YP-gray")
        return tableView
    }()
    
    private func createCanvas() {
        [header, tableView].forEach{view.addSubview($0)}
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 150),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75*4)
        ])
    }
}

extension FilterTrackersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row]
        cell.textLabel?.textColor = UIColor.label
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor(named: "YP-bg")
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryType = (selectedFilter == indexPath.row) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = indexPath.row
        
        tableView.reloadData()
        
        if let selectedFilter = selectedFilter {
            delegate?.didFilteredTrackers(selectedFilter: selectedFilter)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

