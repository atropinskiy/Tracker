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

final class SwipeViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, OnboardingSinglePageViewControllerDelegate {

    weak var swipeDelegate: SwipeViewControllerDelegate?

    private lazy var pages: [OnboardingSinglePageViewController] = {
        return [
            OnboardingSinglePageViewController(pageModel: .bluePage),
            OnboardingSinglePageViewController(pageModel: .redPage)
        ]
    }()

    private let pageControl = UIPageControl()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        pages.forEach { $0.delegate = self }

        // Устанавливаем начальный контроллер
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }

        setupPageControl()
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! OnboardingSinglePageViewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController as! OnboardingSinglePageViewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }

    func didPressButton() {
        let nextViewController = TabBarController()
        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true, completion: nil)
    }

    // MARK: - PageControl Setup

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -115),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func updatePageControl(for pageIndex: Int) {
        pageControl.currentPage = pageIndex
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted: Bool) {
        guard let currentViewController = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController as! OnboardingSinglePageViewController) else {
            return
        }
        updatePageControl(for: currentIndex)
    }
}


