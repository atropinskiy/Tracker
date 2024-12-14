//
//  FirstTimeLoadViewControllers.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

protocol OnboardingSinglePageViewControllerDelegate: AnyObject {
    func didPressButton()
}

final class OnboardingSinglePageViewController: UIViewController {
    
    weak var delegate: OnboardingSinglePageViewControllerDelegate?
    private lazy var button = UIButton(type: .custom)
    
    private let pageModel: OnboardingPage
    
    init(pageModel: OnboardingPage) {
        self.pageModel = pageModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBg(imageName: pageModel.imageName)
        setLabel(text: pageModel.labelText)
        addButton()
    }
    
    private func setBg(imageName: String) {
        let bgImage = UIImageView(frame: UIScreen.main.bounds)
        bgImage.image = UIImage(named: imageName)
        bgImage.contentMode = .scaleAspectFill
        view.insertSubview(bgImage, at: 0)
    }
    
    private func setLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -304)
        ])
    }
    
    private func addButton() {
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func buttonTapped() {
        delegate?.didPressButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

