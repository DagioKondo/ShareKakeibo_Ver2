//
//  NewGroupViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import ViewAnimator

class NewGroupViewController: UIViewController {
    
    
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var indexPath = IndexPath()
    var loadDBModel = LoadDBModel()
    var editDBModel = EditDBModel()
    var db = Firestore.firestore()
    var userID = String()
    var userName = String()
    var profileImage = String()
    var groupID = String()
    var groupName = String()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var groupNotJoinArray = [GroupSets]()
    var sortedGroupNotJoinArray = [GroupSets]()
    var activityIndicatorView = UIActivityIndicatorView()
    var alertModel = AlertModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "招待を受けているグループ"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        createGroupButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        createGroupButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        createGroupButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        createGroupButton.layer.shadowOpacity = 0.5
        createGroupButton.layer.shadowRadius = 1
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        userName = UserDefaults.standard.object(forKey: "userName") as! String
        profileImage = UserDefaults.standard.object(forKey: "profileImage") as! String
        loadDBModel.loadOKDelegate = self
        activityIndicatorView.startAnimating()
        loadDBModel.loadNotJoinGroup(userID: userID)
        
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
        createGroupButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        createGroupButton.layer.shadowOpacity = 0
        createGroupButton.layer.shadowRadius = 0
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        createGroupButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        createGroupButton.layer.shadowOpacity = 0.5
        createGroupButton.layer.shadowRadius = 1
    }
    
    @IBAction func createGroupButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        let createGroupVC = storyboard?.instantiateViewController(identifier: "CreateGroupVC") as! CreateGroupViewController
        navigationController?.pushViewController(createGroupVC, animated: true)
        createGroupButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        createGroupButton.layer.shadowOpacity = 0.5
        createGroupButton.layer.shadowRadius = 1
    }
  
    
    @objc func joinButton(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        indexPath = tableView.indexPath(for: cell)!
        groupID = groupNotJoinArray[indexPath.row].groupID
//        groupName = groupNotJoinArray[indexPath.row].groupName
        UserDefaults.standard.setValue(groupID, forKey: "groupID")
        db.collection("userManagement").document(userID).setData([
            "joinGroupDic": [groupID: true],
        ], merge: true)
        db.collection("groupManagement").document(groupID).setData([
            "settlementDic": [userID: false],
            "userIDArray": FieldValue.arrayUnion([userID])
        ],merge: true)
        loadDBModel.loadSettlementDay(groupID: groupID)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rejectButton(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        
        let cell = sender.superview?.superview?.superview as! UITableViewCell
        indexPath = tableView.indexPath(for: cell)!
        
        editDBModel.editOKDelegate = self
        groupID = groupNotJoinArray[indexPath.row].groupID
        editDBModel.editGroupInfoDelete(groupID: groupID, userID: userID, activityIndicatorView: activityIndicatorView)
    }
 
    
}
//MARK:- TabeleView
extension NewGroupViewController:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupNotJoinArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let invitationView = cell.contentView.viewWithTag(1)!
        let groupNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let joinButton = cell.contentView.viewWithTag(3) as! UIButton
        let rejectButton = cell.contentView.viewWithTag(4) as! UIButton
        let groupImageView = cell.contentView.viewWithTag(5) as! UIImageView
        
        cell.selectionStyle = .none 
        
        invitationView.layer.cornerRadius = 5
        invitationView.layer.masksToBounds = false
        invitationView.layer.shadowOffset = CGSize(width: 1, height: 3)
        invitationView.layer.shadowOpacity = 0.2
        invitationView.layer.shadowRadius = 3
        
        groupNameLabel.text = groupNotJoinArray[indexPath.row].groupName
        groupImageView.sd_setImage(with: URL(string: groupNotJoinArray[indexPath.row].groupImage), completed: nil)
        groupImageView.layer.cornerRadius = 30
        
        joinButton.layer.cornerRadius = 3
        joinButton.addTarget(self, action: #selector(joinButton(_:)), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        joinButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        rejectButton.layer.cornerRadius = 3
        rejectButton.addTarget(self, action: #selector(rejectButton(_:)), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        rejectButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        return cell
    }
    
    
}

//MARK:- LoadOKDelegate,EditOKDelegate
extension NewGroupViewController:LoadOKDelegate, EditOKDelegate{
    
    //どのグループに参加しているか招待されているかを取得完了
    func loadNotJoinGroup_OK(check: Int, groupIDArray: [String]?, notJoinCount: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            groupNotJoinArray = []
            //招待されているグループの情報を取得完了
            loadDBModel.loadNotJoinGroupInfo(groupIDArray: groupIDArray!) { JoinGroupSets in
                self.groupNotJoinArray.append(JoinGroupSets)
                self.sortedGroupNotJoinArray = self.groupNotJoinArray.sorted(by: {($0.create_at! > $1.create_at!)})
            }
        }
    }
    
    func loadNotJoinGroupInfo_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            self.tableView.reloadData()
            let animation = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
            UIView.animate(views: tableView.visibleCells, animations: animation, completion:nil)
            activityIndicatorView.stopAnimating()
        }
    }
    
    func editGroupInfoDelete_OK() {
        groupNotJoinArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
        activityIndicatorView.stopAnimating()
    }
    
    func loadSettlementDay_OK(check: Int, settlementDay: String?) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            let notificatinModel = NotificationModel()
            notificatinModel.registerNotificarionOfSettlement(groupName:groupName,groupID: groupID, settlementDay: settlementDay!)
        }
    }
}
