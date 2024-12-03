//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by alex_tr on 31.10.2024.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(category: String)
}

final class CategoriesViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    private let viewModel = CategoriesViewModel() // Инициализация ViewModel
    weak var delegate: CategoriesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        viewModel.loadCategories() // Загрузка данных через ViewModel
        createCanvas()
        DispatchQueue.main.async {
            self.updateAllRowSeparators(forTableView: self.tableView)
        }
    }
    
    private func createCanvas() {
        let header = UILabel()
        header.text = "Категории"
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
        
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitle("Добавить категорию", for: .normal)
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
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor(named: "YP-categories")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
        updateTableHeight()
        
    }
    
    @objc private func confirmButtonClicked() {
        let typeSelectVC = CategoryCreationViewController()
        typeSelectVC.delegate = self
        present(typeSelectVC, animated: true, completion: nil)
    }
    
    private func updateTableHeight() {
        let tableViewHeight = CGFloat(viewModel.numberOfCategories) * 75 // 75 - высота одной ячейки
        
        // Удаляем старые ограничения для высоты, если они есть
        tableView.constraints.filter { $0.firstAttribute == .height }.forEach { $0.isActive = false }
        
        // Добавляем или обновляем ограничение на высоту
        tableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
    }
    
    func updateAllRowSeparators(forTableView tableView: UITableView) {
        for row in 0..<viewModel.numberOfCategories {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                // Задаем отступы для разделителя
                let leftInset: CGFloat = 16 // Отступ слева
                let rightInset: CGFloat = 16 // Отступ справа
                
                if row == viewModel.numberOfCategories - 1 {
                    // Для последней строки скрываем разделитель
                    cell.separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
                } else {
                    // Для всех остальных строк показываем разделитель с отступами
                    cell.separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
                }
            }
        }
    }
    
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            guard let cell = gesture.view as? UITableViewCell,
                  let indexPath = tableView.indexPath(for: cell) else {
                return
            }

            let alertController = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)

            let deleteAction = UIAlertAction(title: "Удалить категорию", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.removeCategory(at: indexPath)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .none)
                self.tableView.endUpdates()
                self.tableView.reloadData()
                self.updateAllRowSeparators(forTableView: self.tableView)
                self.updateTableHeight()
                
            }

            // Кнопка "Отмена"
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

            // Добавляем действия в контроллер
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            // Показываем action sheet
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = gesture.view
                popoverController.sourceRect = gesture.view?.bounds ?? CGRect.zero
            }
            
            present(alertController, animated: true, completion: nil)
        }
    }

}

extension CategoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = viewModel.category(at: indexPath.row)
        cell.textLabel?.text = category.title // Здесь мы получаем строку из объекта категории
        cell.textLabel?.textColor = UIColor(named: "YP-black")
        cell.backgroundColor = UIColor(named: "YP-bg")
        cell.selectionStyle = .none
        cell.accessoryType = viewModel.isCategorySelected(at: indexPath.row) ? .checkmark : .none
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressRecognizer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row) // Получаем категорию из ViewModel
        
        // Проверяем, что title не nil, прежде чем передавать его делегату
        if let categoryTitle = category.title {
            delegate?.didSelectCategory(category: categoryTitle) // Передаем развернутое значение
        }
        
        viewModel.toggleSelection(for: indexPath.row)
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension CategoriesViewController: CategoryCreationViewControllerDelegate {
    func didCreateCategory(_ category: String) {
        if viewModel.categories.contains(where: { $0.title == category }) {
            // Показываем алерт
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка",
                                              message: "Категория с таким названием уже существует.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self.present(alert, animated: true)
            }
            print("Категория уже существует")
            return
        }
        viewModel.addCategory(title: category)
        let newIndexPath = IndexPath(row: viewModel.numberOfCategories - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        tableView.endUpdates()
        updateTableHeight()
        self.updateAllRowSeparators(forTableView: self.tableView)
        tableView.reloadData()
    }
}


