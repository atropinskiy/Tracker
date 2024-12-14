//
//  TabBarViewController.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = TrackersViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Трекеры".localized(), image: UIImage(named: "TB_main"), tag: 0)
        
        let statVC = StatViewController()
        statVC.tabBarItem = UITabBarItem(title: "Статистика".localized(), image: UIImage(named: "TB_stat"), tag: 1)

        self.viewControllers = [mainVC, statVC]
    }
}
