//
//  DetailAllViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/20.
//
import UIKit
import SDWebImage
import ViewAnimator

class DetailAllViewController: UIViewController{
    
    
    var loadDBModel = LoadDBModel()
    var monthGroupDetailsSets = [MonthGroupDetailsSets]()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    let dateFormatter = DateFormatter()
    var year = String()
    var month = String()
    var startDate = Date()
    var endDate = Date()
    var tableView = UITableView()
    var userIDArray = [String]()
    var profileImage = String()
    var profileImageArray = [String]()
    var userNameArray = [String]()
    
    var settlementDay = String()
    var dateModel = DateModel()
    var changeCommaModel = ChangeCommaModel()
    var alertModel = AlertModel()
    var userInfoDic:[String:UserSets] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.view.addSubview(tableView)
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.isHidden = true
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        settlementDay = UserDefaults.standard.object(forKey: "settlementDay") as! String
        
        //決済日をuserDefaultから取り出し、決済月を求める
        let settlementDayOfInt = Int(settlementDay)!
        loadDBModel.loadOKDelegate = self
        activityIndicatorView.startAnimating()

        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadMonthDetails(groupID: groupID, startDate: minDate, endDate: maxDate, userID: nil)
        }
        
    }
  
    
}

// MARK: - LoadOKDelegate
extension DetailAllViewController:LoadOKDelegate {
    
    
    //全体の明細を取得完了
    func loadMonthDetails_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            monthGroupDetailsSets = []
            monthGroupDetailsSets = loadDBModel.monthGroupDetailsSets
            userIDArray = []
            profileImageArray = []
            userNameArray = []
            if monthGroupDetailsSets.count != 0{
                for i in 0...monthGroupDetailsSets.count - 1{
                    userIDArray.append(monthGroupDetailsSets[i].userID)
                }
            }else{
                tableView.delegate = self
                tableView.dataSource = self
                self.tableView.reloadData()
                tableView.isHidden = false
                let animation = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
                UIView.animate(views: tableView.visibleCells, animations: animation, completion:nil)
                activityIndicatorView.stopAnimating()
            }
            
            //明細に表示するユーザーネームとプロフィール画像取得
            loadDBModel.loadGroupMember(userIDArray: userIDArray) { [self] UserSets in
                self.userInfoDic.updateValue(UserSets, forKey: UserSets.userID)
            }
        }
    }
    
    func loadGroupMember_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            tableView.delegate = self
            tableView.dataSource = self
            self.tableView.reloadData()
            tableView.isHidden = false
            let animation = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
            UIView.animate(views: tableView.visibleCells, animations: animation, completion:nil)
            activityIndicatorView.stopAnimating()
            if tableView.refreshControl?.isRefreshing == true{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    
}

// MARK: - TableView
extension DetailAllViewController:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthGroupDetailsSets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
        
        
            
            let userID = monthGroupDetailsSets[indexPath.row].userID
            
            
            cell.profileImage.sd_setImage(with: URL(string: userInfoDic[userID]!.profileImage), completed: nil)
            cell.paymentLabel.text = changeCommaModel.getComma(num: monthGroupDetailsSets[indexPath.row].paymentAmount) + " 円"
            cell.userNameLabel.text = userInfoDic[userID]?.userName
            cell.dateLabel.text = monthGroupDetailsSets[indexPath.row].paymentDay
            cell.category.text = monthGroupDetailsSets[indexPath.row].category
            cell.productNameLabel.text = monthGroupDetailsSets[indexPath.row].productName
            
            
            cell.view.layer.cornerRadius = 5
            cell.view.layer.masksToBounds = false
            cell.view.layer.shadowOffset = CGSize(width: 1, height: 3)
            cell.view.layer.shadowOpacity = 0.2
            cell.view.layer.shadowRadius = 3
            
            return cell

    }
    
    @objc func refresh() {
        let settlementDayOfInt = Int(settlementDay)!

        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadMonthDetails(groupID: groupID, startDate: minDate, endDate: maxDate, userID: nil)
        }
    }
    
}
