//
//  GroupDetailViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit


protocol GoToVcDelegate {
    func goToVC(segueID:String)
}

class GroupDetailViewController: UIViewController {
    
    
    var goToVcDelegate:GoToVcDelegate?
    var editDBModel = EditDBModel()
    
    var groupID = String()
    var userID = String()
    var activityIndicatorView = UIActivityIndicatorView()
    
    var alertModel = AlertModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editDBModel.editOKDelegate = self
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func groupConfigurationButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        goToVcDelegate?.goToVC(segueID: "GroupConfigurationVC")
    }
    
    @IBAction func memberButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        goToVcDelegate?.goToVC(segueID: "MemberVC")
    }
    
    @IBAction func invitationButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        goToVcDelegate?.goToVC(segueID: "AdditionVC")
    }
    
    @IBAction func exitButton(_ sender: Any) {
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        alertModel.exitAlert(viewController: self, groupID: groupID, userID: userID, activityIndicatorView: activityIndicatorView)
    }
    
    
}

// MARK: - EditOKDelegate
extension GroupDetailViewController: EditOKDelegate{
    
    
    func editUserDelete_OK() {
        editDBModel.editUserDelete2(groupID: groupID, userID: userID, activityIndicatorView: activityIndicatorView)
    }
    
    func editUserDelete2_OK() {
        goToVcDelegate?.goToVC(segueID: "")
    }
    
    
}
