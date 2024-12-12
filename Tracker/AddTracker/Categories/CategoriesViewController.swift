//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by alex_tr on 31.10.2024.
//

import UIKit



protocol CategoriesViewControllerDelegate: AnyObject {
    func didSelectCategory(category: String)
    func didDeleteCategory()
    func didEditedCategory()
}

final class CategoriesViewController: UIViewController {
    
    private let viewModel: CategoriesViewModelProtocol
    weak var delegate: CategoriesViewControllerDelegate?
    private var isStubVisible: Bool = false
    
    init(viewModel: CategoriesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        viewModel.loadCategories() // Загрузка данных через ViewModel
        createCanvas()
        DispatchQueue.main.async {
            self.updateAllRowSeparators(forTableView: self.tableView)
        }
        updateStubVisibility()
    }
    
    private lazy var header: UILabel = {
        let header = UILabel()
        header.text = "Категории"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.textColor = UIColor(named: "YP-black")
        header.textAlignment = .center
        return header
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor(named: "YP-white"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP-black")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonClicked), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = UIColor(named: "YP-categories")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        return tableView
    }()
    
    
    private lazy var stubImg: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "StubImg"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let stubLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "Привчки и события можно объединять по смыслу"
        label.textAlignment = .center
        label.textColor = UIColor(named: "YP-black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func createCanvas() {
        [header, confirmButton, tableView].forEach{view.addSubview($0)}
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.widthAnchor.constraint(equalToConstant: 150),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.75)
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
    
    private func addStub() {
        guard !isStubVisible else { return }
        
        stubImg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubImg)
        NSLayoutConstraint.activate([
            stubImg.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubImg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImg.heightAnchor.constraint(equalToConstant: 80),
            stubImg.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        stubLabel.text = "Привычки и события можно\nобъединить по смыслу"
        stubLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        stubLabel.textAlignment = .center
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        stubLabel.textColor = UIColor(named: "YP-black")
        stubLabel.numberOfLines = 0
        
        view.addSubview(stubLabel)
        NSLayoutConstraint.activate([
            stubLabel.topAnchor.constraint(equalTo: stubImg.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
        
        isStubVisible = true
    }
    
    private func updateStubVisibility() {
        if viewModel.numberOfCategories == 0 { // Если список категорий пуст
            addStub()
            tableView.isHidden = true
        } else {
            stubImg.removeFromSuperview()
            stubLabel.removeFromSuperview()
            isStubVisible = false
            tableView.isHidden = false
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
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        cell.addGestureRecognizer(longPressRecognizer)
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // Получаем объект трекера на основе indexPath
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            
            return UIMenu(children: [
                UIAction(title: "Редактировать") { _ in
                    let category = self.viewModel.category(at: indexPath.row) // Получаем категорию
                    let editCategoryVC = CategoryEditViewController()
                    editCategoryVC.delegate = self
                    editCategoryVC.currentName = category.title // передаем название категории
                    self.present(editCategoryVC, animated: true, completion: nil)
                },
                UIAction(title: "Удалить", attributes: .destructive) { _ in
                    self.viewModel.removeCategory(at: indexPath)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .none)
                    self.tableView.endUpdates()
                    self.tableView.reloadData()
                    self.updateAllRowSeparators(forTableView: tableView)
                    self.updateTableHeight()
                    self.delegate?.didDeleteCategory()
                    self.updateStubVisibility()
                }
            ])
        })
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
        updateStubVisibility()
    }
}

extension CategoriesViewController: CategoryEditViewControllerDelegate {
    func didEditedCategory(newCategoryName: String) {
        viewModel.loadCategories()
        tableView.reloadData()
        delegate?.didEditedCategory()
    }
}



