//
//  DetailThisMonthViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Parchment


class DetailThisMonthViewController: UIViewController {
    
    
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var detailThisMonthLabel: UILabel!
    
    var pagingVC = PagingViewController()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var dateModel = DateModel()
    var alertModel = AlertModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let DetailAllVC = DetailAllViewController()
        let DetailMyselfVC = DetailMyselfViewController()
        
        DetailAllVC.title = "グループ全体"
        DetailMyselfVC.title = "個人"
        
        pagingVC = PagingViewController(viewControllers: [
            DetailAllVC,
            DetailMyselfVC
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
        
        DetailAllVC.tableView.translatesAutoresizingMaskIntoConstraints = false
        DetailAllVC.tableView.leadingAnchor.constraint(equalTo: DetailAllVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        DetailAllVC.tableView.trailingAnchor.constraint(equalTo: DetailAllVC.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        DetailAllVC.tableView.bottomAnchor.constraint(equalTo: DetailAllVC.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        DetailAllVC.tableView.topAnchor.constraint(equalTo: DetailAllVC.view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        DetailMyselfVC.tableView.translatesAutoresizingMaskIntoConstraints = false
        DetailMyselfVC.tableView.leadingAnchor.constraint(equalTo: DetailMyselfVC.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        DetailMyselfVC.tableView.trailingAnchor.constraint(equalTo: DetailMyselfVC.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        DetailMyselfVC.tableView.bottomAnchor.constraint(equalTo: DetailMyselfVC.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        DetailMyselfVC.tableView.topAnchor.constraint(equalTo: DetailMyselfVC.view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        addPaymentButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addPaymentButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        addPaymentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addPaymentButton.layer.shadowOpacity = 0.5
        addPaymentButton.layer.shadowRadius = 1
        
        self.view.bringSubviewToFront(addPaymentButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let settlementDay = UserDefaults.standard.object(forKey: "settlementDay") as! String
        
        dateModel.getPeriodOfThisMonth(settelemtDay: Int(settlementDay)!) { maxDate, minDate in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let maxdd = Calendar.current.date(byAdding: .day, value: -1, to: maxDate)
            let maxDateFormatter = dateFormatter.string(from: maxdd!)
            let minDateFormatter = dateFormatter.string(from: minDate)
            detailThisMonthLabel.text = "\(minDateFormatter)〜\(maxDateFormatter)の明細"
        }
        
    }
    
    
    
    @IBAction func addPaymentButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        performSegue(withIdentifier: "paymentVC", sender: nil)
        addPaymentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addPaymentButton.layer.shadowOpacity = 0.5
        addPaymentButton.layer.shadowRadius = 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let paymentVC = segue.destination as! PaymentViewController
        paymentVC.presentationController?.delegate = self
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
        addPaymentButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addPaymentButton.layer.shadowOpacity = 0
        addPaymentButton.layer.shadowRadius = 0
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        addPaymentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addPaymentButton.layer.shadowOpacity = 0.5
        addPaymentButton.layer.shadowRadius = 1
    }
    
}

//MARK:- UIAdaptivePresentationControllerDelegate

extension  DetailThisMonthViewController: UIAdaptivePresentationControllerDelegate{
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        pagingVC.reloadData()
    }
    
}
