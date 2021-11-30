//
//  MonthlyDataViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Parchment

class MonthlyDataViewController: UIViewController {
    
    
    var pagingVC = PagingViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overAllVC = OverAllViewController()
        let utilityVC = UtilityViewController()
        let foodVC = FoodViewController()
        let othersVC = OthersViewController()
        
        overAllVC.title = "全体"
        utilityVC.title = "家賃・光熱費・通信費"
        foodVC.title = "食費"
        othersVC.title = "その他"
        
        pagingVC = PagingViewController(viewControllers: [
            overAllVC,
            utilityVC,
            foodVC,
            othersVC
        ])
        
        self.addChild(pagingVC)
        self.view.addSubview(pagingVC.view)
        pagingVC.didMove(toParent: self)
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        pagingVC.selectedBackgroundColor = .clear
        pagingVC.indicatorColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        pagingVC.textColor = .darkGray
        pagingVC.selectedTextColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        pagingVC.menuBackgroundColor = .clear
        pagingVC.borderColor = .systemGray3
        pagingVC.borderOptions = .visible(height: 0.8,
                                          zIndex: Int.max - 1,
                                          insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        pagingVC.menuItemSize = .selfSizing(estimatedWidth: 80, height: 40)
        pagingVC.menuItemSpacing = 10
        pagingVC.menuHorizontalAlignment = .center
        
        
        foodVC.lineChartsView.translatesAutoresizingMaskIntoConstraints = false
        foodVC.lineChartsView.leadingAnchor.constraint(equalTo: foodVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        foodVC.lineChartsView.trailingAnchor.constraint(equalTo: foodVC.view.safeAreaLayoutGuide.trailingAnchor,constant: -15).isActive = true
        foodVC.lineChartsView.bottomAnchor.constraint(equalTo: foodVC.view.safeAreaLayoutGuide.bottomAnchor,constant: -30).isActive = true
        foodVC.lineChartsView.topAnchor.constraint(equalTo: foodVC.view.safeAreaLayoutGuide.topAnchor,constant: 70).isActive = true
        
        othersVC.lineChartsView.translatesAutoresizingMaskIntoConstraints = false
        othersVC.lineChartsView.leadingAnchor.constraint(equalTo: othersVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        othersVC.lineChartsView.trailingAnchor.constraint(equalTo: othersVC.view.safeAreaLayoutGuide.trailingAnchor,constant: -15).isActive = true
        othersVC.lineChartsView.bottomAnchor.constraint(equalTo: othersVC.view.safeAreaLayoutGuide.bottomAnchor,constant: -30).isActive = true
        othersVC.lineChartsView.topAnchor.constraint(equalTo: othersVC.view.safeAreaLayoutGuide.topAnchor,constant: 70).isActive = true
       
        overAllVC.lineChartsView.translatesAutoresizingMaskIntoConstraints = false
        overAllVC.lineChartsView.leadingAnchor.constraint(equalTo: overAllVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        overAllVC.lineChartsView.trailingAnchor.constraint(equalTo: overAllVC.view.safeAreaLayoutGuide.trailingAnchor,constant: -15).isActive = true
        overAllVC.lineChartsView.bottomAnchor.constraint(equalTo: overAllVC.view.safeAreaLayoutGuide.bottomAnchor,constant: -30).isActive = true
        overAllVC.lineChartsView.topAnchor.constraint(equalTo: overAllVC.view.safeAreaLayoutGuide.topAnchor,constant: 70).isActive = true
        
        utilityVC.lineChartsView.translatesAutoresizingMaskIntoConstraints = false
        utilityVC.lineChartsView.leadingAnchor.constraint(equalTo: utilityVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        utilityVC.lineChartsView.trailingAnchor.constraint(equalTo: utilityVC.view.safeAreaLayoutGuide.trailingAnchor,constant: -15).isActive = true
        utilityVC.lineChartsView.bottomAnchor.constraint(equalTo: utilityVC.view.safeAreaLayoutGuide.bottomAnchor,constant: -30).isActive = true
        utilityVC.lineChartsView.topAnchor.constraint(equalTo: utilityVC.view.safeAreaLayoutGuide.topAnchor,constant: 70).isActive = true
        
        
    }

    
}

