//
//  NotificationViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit

class NotificationViewController: UIViewController {
   

    @IBOutlet weak var tableView: UITableView!

    var loadDBModel = LoadDBModel()
    var userID = String()
    var groupID = String()
    var day = Int()
    var notificationArray = [NotificationSets]() //ロードしてきた通知が入る配列
    var activityIndicatorView = UIActivityIndicatorView()
    var alertModel = AlertModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "お知らせ"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() //空白のセルの線を消してるよ
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.day], from: Date())
        day = date.day! + 1
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadOKDelegate = self
        activityIndicatorView.startAnimating()
        loadDBModel.loadSettlementNotification(userID: userID, day: String(day))
    }

    
}

//MARK:- TabelView
extension NotificationViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = notificationArray[indexPath.row].groupName + "の決済が確定されました"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        groupID = notificationArray[indexPath.row].groupID
        UserDefaults.standard.setValue(groupID, forKey: "groupID")
        
        let settlementTabVC = storyboard?.instantiateViewController(identifier: "TabBarContoller") as! UITabBarController
        settlementTabVC.selectedIndex = 1
        navigationController?.pushViewController(settlementTabVC, animated: true)
    }
    
}
//MARK:- LoadOKDelegate
extension NotificationViewController:LoadOKDelegate{
    
    func loadSettlementNotification_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            notificationArray = loadDBModel.notificationSets
            tableView.reloadData()
            activityIndicatorView.stopAnimating()
        }
    }
    
}
