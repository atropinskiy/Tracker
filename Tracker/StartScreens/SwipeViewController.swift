//
//  SwipeViewController.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

protocol SwipeViewControllerDelegate: AnyObject {
    func didPressButton()
}

final class SwipeViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var swipeDelegate: SwipeViewControllerDelegate?
    
    private lazy var pages: [BaseViewController] = {
        return [
            BaseViewController(imageName: "StartBgBlue", labelText: "Отслеживайте только то, что хотите"),
            BaseViewController(imageName: "StartBgRed", labelText: "Даже если это не литры воды и йога")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        pages.forEach { $0.delegate = self }
        
        // Устанавливаем начальный контроллер
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! BaseViewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! BaseViewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}

extension SwipeViewController: BaseViewControllerDelegate {
    func didPressButton() {
        let nextViewController = TabBarController()
        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true, completion: nil)
    }
}
