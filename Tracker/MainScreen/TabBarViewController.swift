//
//  TabBarViewController.swift
//  Tracker
//
//  Created by alex_tr on 27.10.2024.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainVC = MainViewController() // Ваш основной контроллер
        mainVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "TB_main"), tag: 0) // Иконка и название
        
        // Другой контроллер
        let otherVC = UIViewController()
        otherVC.view.backgroundColor = .white
        otherVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "TB_stat"), tag: 1)

        self.viewControllers = [mainVC, otherVC] // Добавляем контроллеры в TabBar
    }
}
