//
//  SwipeViewController.swift
//  Tracker
//
//  Created by alex_tr on 28.10.2024.
//

import UIKit

class SwipeViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // Массив контроллеров, которые будут свайпаться
    private lazy var pages: [UIViewController] = {
        return [BlueViewController(), RedViewController()]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // Устанавливаем начальный контроллер
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}
