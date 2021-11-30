//
//  GroupMemberViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class GroupMemberViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var db = Firestore.firestore()
    var loadDBModel = LoadDBModel()
    var groupID = String()
    var profileImageArray = [String]()
    var userNameArray = [String]()
    var userIDArray = [String]()
    var userID = String()
    var userName = String()
    var profileImage = String()
    var activityIndicatorView = UIActivityIndicatorView()
    var alertModel = AlertModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        
        activityIndicatorView.startAnimating()
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - LoadOKDelegate
extension GroupMemberViewController:LoadOKDelegate{
    
    
    //userID取得完了
    func loadUserIDAndSettlementDic_OK(check: Int, settlementDic: Dictionary<String, Bool>?, userIDArray: [String]?) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            profileImageArray = []
            userNameArray = []
            self.userIDArray = userIDArray!
            
            self.userIDArray.removeAll(where: {$0 == userID})
            //ユーザーネームとプロフィール画像取得完了
            loadDBModel.loadGroupMember(userIDArray: self.userIDArray) { [self] UserSets in
                profileImageArray.append(UserSets.profileImage)
                userNameArray.append(UserSets.userName)
            }
        }

    }
    
    func loadGroupMember_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            tableView.reloadData()
            activityIndicatorView.stopAnimating()
        }
    }
    
    
}

// MARK: - TableView
extension GroupMemberViewController:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return userNameArray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let cellView = cell.contentView.viewWithTag(1)
            let profileImage = cell.contentView.viewWithTag(2) as! UIImageView
            let userNameLabel = cell.contentView.viewWithTag(3) as! UILabel
            
            cell.selectionStyle = .none
            
            self.profileImage = UserDefaults.standard.object(forKey: "profileImage") as! String
            self.userName = UserDefaults.standard.object(forKey: "userName") as! String
            
            profileImage.sd_setImage(with: URL(string: self.profileImage), completed: nil)
            profileImage.layer.cornerRadius = 30
            userNameLabel.text = userName
            
            cellView!.layer.cornerRadius = 5
            cellView!.layer.masksToBounds = false
            cellView!.layer.cornerRadius = 5
            cellView!.layer.shadowOffset = CGSize(width: 1, height: 1)
            cellView!.layer.shadowOpacity = 0.2
            cellView!.layer.shadowRadius = 1
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let cellView = cell.contentView.viewWithTag(1)
            let profileImage = cell.contentView.viewWithTag(2) as! UIImageView
            let userNameLabel = cell.contentView.viewWithTag(3) as! UILabel
            
            cell.selectionStyle = .none
            
            profileImage.sd_setImage(with: URL(string: profileImageArray[indexPath.row]), completed: nil)
            profileImage.layer.cornerRadius = 30
            userNameLabel.text = userNameArray[indexPath.row]
            
            cellView!.layer.cornerRadius = 5
            cellView!.layer.masksToBounds = false
            cellView!.layer.cornerRadius = 5
            cellView!.layer.shadowOffset = CGSize(width: 1, height: 1)
            cellView!.layer.shadowOpacity = 0.2
            cellView!.layer.shadowRadius = 1
            
            return cell
        }
    }
    
    
}
