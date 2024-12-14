import UIKit
import Combine

final class StatViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private var stubImg: UIImageView!
    private var stubLabel: UILabel!
    private let statService = StatService()
    private let titleValues = ["Лучший период".localized(), "Идеальные дни".localized(), "Трекеров завершено".localized(), "Среднее значение".localized()]
    private var statValues: [Int] = [] // Инициализация с пустым массивом
    private lazy var header = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(StatCell.self, forCellWithReuseIdentifier: "StatCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP-white")
        statService.statValuesPublisher
            .sink { [weak self] statValues in
                guard let self = self else { return }
                self.statValues = statValues // Обновляем массив локальных данных
                if !statValues.isEmpty {
                    self.updateUI(with: statValues)
                    self.collectionView.reloadData()
                    self.createCanvas()
                    print("Текущие данные:\(statValues)")
                } else {
                    self.showEmptyStat()
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(with values: [Int]) {
        print("Обновленные значения статистики: \(values)")
        
        if values.allSatisfy({ $0 == 0 }) {
            addStub()
        } else {
            stubImg?.isHidden = true
            stubLabel?.isHidden = true
            collectionView.isHidden = false
            
            // Обновляем интерфейс с новыми данными
            collectionView.reloadData()
            createCanvas()
        }
    }
    
    private func showEmptyStat() {
        print("Статистика пуста.")
        addStub()
    }

    
    private func createCanvas() {
        header.text = "Статистика".localized()
        header.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        header.textColor = UIColor(named: "YP-black")
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])
               
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: header.topAnchor, constant: 77),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 4*90+3*12)
        ])
    }
    
    private func addStub() {
        if stubImg == nil {
            stubImg = UIImageView()
            stubLabel = UILabel()
            
            stubImg.image = UIImage(named: "Stat-Stub")
            view.addSubview(stubImg)
            stubImg.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stubImg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stubImg.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            stubLabel.text = "Анализировать пока нечего"
            stubLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            stubLabel.textColor = UIColor(named: "YP-black")
            stubLabel.translatesAutoresizingMaskIntoConstraints = false
            stubLabel.textAlignment = .center
            view.addSubview(stubLabel)
            NSLayoutConstraint.activate([
                stubLabel.topAnchor.constraint(equalTo: stubImg.bottomAnchor, constant: 0),
                stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stubLabel.widthAnchor.constraint(equalToConstant: 343)
            ])
        }
        
        stubImg.isHidden = false
        stubLabel.isHidden = false
        collectionView.isHidden = true
    }

}

extension StatViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("StatViewController: Number of items in section: \(statValues.count)")
        return statValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatCell", for: indexPath) as? StatCell else {
            return UICollectionViewCell()
        }
        
        guard !statValues.isEmpty else {
            return cell
        }
        
        let value = statValues[indexPath.item]
        cell.counterText = value
        cell.titleLabelText = titleValues[safe: indexPath.item] ?? "Неизвестный".localized()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32 // Учитываем отступы
        let height: CGFloat = 90 // Примерная высота для каждой ячейки
        return CGSize(width: width, height: height)
    }
}