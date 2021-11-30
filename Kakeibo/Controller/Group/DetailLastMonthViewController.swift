//
//  DetailLastMonthViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Parchment

class DetailLastMonthViewController: UIViewController {
    
    
    @IBOutlet weak var headerView: UIView!
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let DetailAllLastMonthVC = DetailAllLastMonthViewController()
        let DetailMyselfLastMonthVC = DetailMyselfLastMonthViewController()
        
        DetailAllLastMonthVC.title = "グループ全体"
        DetailMyselfLastMonthVC.title = "個人"
        
        let pagingVC = PagingViewController(viewControllers: [
            DetailAllLastMonthVC,
            DetailMyselfLastMonthVC
        ])
        
        self.addChild(pagingVC)
        self.view.addSubview(pagingVC.view)
        pagingVC.didMove(toParent: self)
        pagingVC.contentInteraction = .none
        
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        pagingVC.selectedBackgroundColor = .clear
        pagingVC.indicatorColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        pagingVC.textColor = .darkGray
        pagingVC.selectedTextColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        pagingVC.menuBackgroundColor = .clear
        pagingVC.borderColor = .systemGray3
        pagingVC.borderOptions = .visible(height: 0.8,
                                          zIndex: Int.max - 1,
                                          insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        pagingVC.menuItemSize = .selfSizing(estimatedWidth: 100, height: 40)
        pagingVC.menuItemSpacing = 80
        pagingVC.menuHorizontalAlignment = .center
        pagingVC.select(index: 0)
        
        DetailAllLastMonthVC.tableView.translatesAutoresizingMaskIntoConstraints = false
        DetailAllLastMonthVC.tableView.leadingAnchor.constraint(equalTo: DetailAllLastMonthVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        DetailAllLastMonthVC.tableView.trailingAnchor.constraint(equalTo: DetailAllLastMonthVC.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        DetailAllLastMonthVC.tableView.bottomAnchor.constraint(equalTo: DetailAllLastMonthVC.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        DetailAllLastMonthVC.tableView.topAnchor.constraint(equalTo: DetailAllLastMonthVC.view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        DetailMyselfLastMonthVC.tableView.translatesAutoresizingMaskIntoConstraints = false
        DetailMyselfLastMonthVC.tableView.leadingAnchor.constraint(equalTo: DetailMyselfLastMonthVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        DetailMyselfLastMonthVC.tableView.trailingAnchor.constraint(equalTo: DetailMyselfLastMonthVC.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        DetailMyselfLastMonthVC.tableView.bottomAnchor.constraint(equalTo: DetailMyselfLastMonthVC.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        DetailMyselfLastMonthVC.tableView.topAnchor.constraint(equalTo: DetailMyselfLastMonthVC.view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
 
    
}
