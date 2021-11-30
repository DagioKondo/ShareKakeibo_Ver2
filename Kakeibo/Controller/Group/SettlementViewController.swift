//
//  SettlementViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//
import UIKit
import ViewAnimator
import SDWebImage
import FirebaseFirestore


class SettlementViewController: UIViewController{
    
    
    @IBOutlet weak var userPaymentOfLastMonth: UILabel!
    @IBOutlet weak var settlementCompletionButton: UIButton!
    @IBOutlet weak var checkDetailButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lastMonthLabel: UILabel!
    
    var loadDBModel = LoadDBModel()
    var db = Firestore.firestore()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var userID = String()
    var year = String()
    var month = String()
    let dateFormatter = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    var userNameDic = Dictionary<String,String>()
    var profileImageDic = Dictionary<String,String>()
    var howMuchArray = [Int]()
    var paymentDic = Dictionary<String,Int>()
    var userIDArray = [String]()
    var paymentAverageOfMonth = Int()
    
    var settlementDic = [String:Bool]()
    var settlementDay = String()
    var sortedSettlementDic = [Dictionary<String,Bool>.Element]()
    var sortedProfileImageDic = [Dictionary<String,String>.Element]()
    var sortedUserNameDic = [Dictionary<String,String>.Element]()
    var sortedPaymentDic = [Dictionary<String,Int>.Element]()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var dateModel = DateModel()
    var settlementDayOfInt = Int()
    var changeCommaModel = ChangeCommaModel()
    var alertModel = AlertModel()
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settlementCompletionButton.layer.cornerRadius = 5
        settlementCompletionButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        settlementCompletionButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        checkDetailButton.layer.cornerRadius = 5
        checkDetailButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        checkDetailButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.separatorStyle = .none
        tableView.isHidden = true
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        settlementDay = UserDefaults.standard.object(forKey: "settlementDay") as! String
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        loadDBModel.loadOKDelegate = self
        activityIndicatorView.startAnimating()
        settlementDayOfInt = Int(settlementDay)!
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID)
    }
    
    
    @objc func touchDown(_ sender:UIButton){
        if settlementDic[userID] == false{
            buttonAnimatedModel.startAnimation(sender: sender)
        }
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    @IBAction func settlementCompletionButton(_ sender: Any) {
        settlementCompletionButton.backgroundColor = .red
        
        db.collection("groupManagement").document(groupID).setData(["settlementDic" : [userID:true]],merge: true)
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID)
    }
    
    @IBAction func checkDetailButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        performSegue(withIdentifier: "lastMonthDataVC", sender: nil)
    }
    
    
}

// MARK: - LoadOKDelegate
extension SettlementViewController: LoadOKDelegate{
    
    
    //メンバーの決済可否を取得完了
    func loadUserIDAndSettlementDic_OK(check: Int, settlementDic: Dictionary<String, Bool>?, userIDArray: [String]?) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            self.settlementDic = settlementDic!
            if settlementDic![userID] == true{
                buttonAnimatedModel.startAnimation(sender: settlementCompletionButton)
                settlementCompletionButton.backgroundColor = .red
                settlementCompletionButton.setTitle("支払いor受け取り済み", for: .normal)
            }else{
                buttonAnimatedModel.endAnimation(sender: settlementCompletionButton)
                settlementCompletionButton.backgroundColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
                settlementCompletionButton.setTitle("支払いor受け取り済みにする", for: .normal)
            }
            
            sortedSettlementDic = settlementDic!.sorted(by: {$0.key < $1.key})
            dateModel.getPeriodOfLastMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
                dateFormatter.dateFormat = "MM/dd"
                dateFormatter.locale = Locale(identifier: "ja_JP")
                dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                let maxdd = Calendar.current.date(byAdding: .day, value: -1, to: maxDate)
                let maxDateFormatter = dateFormatter.string(from: maxdd!)
                let minDateFormatter = dateFormatter.string(from: minDate)
                lastMonthLabel.text = "\(minDateFormatter)〜\(maxDateFormatter)の\n決済が確定しました"
                loadDBModel.loadMonthPayment(groupID: groupID, userIDArray: userIDArray!, startDate: minDate, endDate: maxDate)
            }
        }
    }
    
    //(グループの合計金額)と(1人当たりの金額)と(支払いに参加したユーザーの数)取得完了
    func loadMonthPayment_OK(check: Int, groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]?) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            profileImageDic = [:]
            userNameDic = [:]
            self.userIDArray = userIDArray!.sorted()
            self.paymentAverageOfMonth = paymentAverageOfMonth
            
            //各メンバーのプロフィール画像、名前取得完了
            loadDBModel.loadGroupMember(userIDArray: userIDArray!) { [self] UserSets in
                profileImageDic.updateValue(UserSets.profileImage, forKey: UserSets.userID)
                userNameDic.updateValue(UserSets.userName, forKey: UserSets.userID)
                sortedProfileImageDic = profileImageDic.sorted(by: {$0.key < $1.key})
                sortedUserNameDic = userNameDic.sorted(by: {$0.key < $1.key})
            }
        }
    }

    func loadGroupMember_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            dateModel.getPeriodOfLastMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
                loadDBModel.loadMonthSettlement(groupID: groupID, userID: nil, startDate: minDate, endDate: maxDate)
            }
        }
    }
    
    //グループの支払い状況の取得完了
    func loadMonthSettlement_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            paymentDic = [:]
            
            for ID in userIDArray{
                var totalPay = 0
                if (loadDBModel.settlementSets.count != 0){
                    for count in 0...loadDBModel.settlementSets.count - 1{
                        if ID == loadDBModel.settlementSets[count].userID{
                            totalPay = totalPay + loadDBModel.settlementSets[count].paymentAmount!
                        }
                    }
                }else{
                    activityIndicatorView.stopAnimating()
                    return
                }
                //各メンバーの支払金額の配列
                paymentDic.updateValue(totalPay, forKey: ID)
            }
            sortedPaymentDic = paymentDic.sorted(by: {$0.key < $1.key})
            
            //各メンバーの決済額の配列
            howMuchArray = sortedPaymentDic.map{($1 - paymentAverageOfMonth) * -1}
            
            //自分の決済額
            var userPayment = paymentDic[userID]!
            userPayment = paymentAverageOfMonth - userPayment
            if userPayment < 0{
                let receivePrice = changeCommaModel.getComma(num: userPayment * -1) + "円"
                userPaymentOfLastMonth.text = "あなたは " + receivePrice + " の受け取りがあります"
            }else{
                let paymentPrice = changeCommaModel.getComma(num: userPayment) + "円"
                userPaymentOfLastMonth.text = "あなたは " + paymentPrice + " の支払いがあります"
            }
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            tableView.isHidden = false
            let animation = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
            UIView.animate(views: tableView.visibleCells, animations: animation, completion:nil)
            activityIndicatorView.stopAnimating()
        }
    }
    
    
}

// MARK: - TableView
extension SettlementViewController: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedSettlementDic.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let cellView = cell?.contentView.viewWithTag(1)!
        let profileImage = cell?.contentView.viewWithTag(2) as! UIImageView
        let userNameLabel = cell?.contentView.viewWithTag(3) as! UILabel
        let checkSettlementLabel = cell?.contentView.viewWithTag(4) as! UILabel
        let howMuchLabel = cell?.contentView.viewWithTag(5) as! UILabel
        
        cell?.selectionStyle = .none
        
        profileImage.layer.cornerRadius = 30
        profileImage.sd_setImage(with: URL(string: sortedProfileImageDic[indexPath.row].value), completed: nil)
        userNameLabel.text = sortedUserNameDic[indexPath.row].value
        
        checkSettlementLabel.layer.masksToBounds = false
        checkSettlementLabel.clipsToBounds = true
        checkSettlementLabel.layer.cornerRadius = 5
        
        if sortedSettlementDic[indexPath.row].value == true{
            checkSettlementLabel.text = "決済済み"
            checkSettlementLabel.backgroundColor = .systemGreen
        }else{
            checkSettlementLabel.text = "未決済"
            checkSettlementLabel.backgroundColor = .systemRed
        }
        
        if howMuchArray[indexPath.row] < 0{
            howMuchLabel.text = changeCommaModel.getComma(num: howMuchArray[indexPath.row] * -1) + "　円" + "の受取"
        }else{
            howMuchLabel.text = changeCommaModel.getComma(num: howMuchArray[indexPath.row]) + "　円" + "の支払"
        }
        cellView!.layer.cornerRadius = 5
        cellView!.layer.masksToBounds = false
        cellView!.layer.cornerRadius = 5
        cellView!.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView!.layer.shadowOpacity = 0.2
        cellView!.layer.shadowRadius = 1
        
        return cell!
    }
    
    
}
