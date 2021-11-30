//
//  EditDBModel.swift
//  Kakeibo
//
//  Created by 都甲裕希 on 2021/11/04.
//

import Foundation
import Firebase
import FirebaseFirestore

@objc protocol EditOKDelegate {
    @objc optional func editGroupInfoDelete_OK()
    @objc optional func editUserDelete_OK()
    @objc optional func editUserDelete2_OK()
}

class EditDBModel{
    
    var editOKDelegate:EditOKDelegate?
    var db = Firestore.firestore()
    var monthMyDetailsSets:[MonthMyDetailsSets] = []
    let dateFormatter = DateFormatter()
    

    func editGroupInfoDelete(groupID:String,userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("userManagement").document(userID).getDocument { (snapShot, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                var joinGroupDic = data["joinGroupDic"] as! Dictionary<String,Bool>
                joinGroupDic.removeValue(forKey: groupID)
                self.db.collection("userManagement").document(userID).updateData(["joinGroupDic" : joinGroupDic])
                self.editOKDelegate?.editGroupInfoDelete_OK?()
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //ユーザーが退会したときのロード
    func editUserDelete(groupID:String,userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("groupManagement").document(groupID).getDocument { (snapShot, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                var settlementDic = data["settlementDic"] as! Dictionary<String,Bool>
                var userIDArray = data["userIDArray"] as! Array<String>
                userIDArray.removeAll(where: {$0 == userID})
                settlementDic.removeValue(forKey: userID)
                self.db.collection("groupManagement").document(groupID).updateData(["settlementDic" : settlementDic,"userIDArray" : userIDArray])
                self.editOKDelegate?.editUserDelete_OK?()
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //ユーザーが退会したときのロード２
    func editUserDelete2(groupID:String,userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("userManagement").document(userID).getDocument { (snapShot, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                var joinGroupDic = data["joinGroupDic"] as! Dictionary<String,Bool>
                joinGroupDic.removeValue(forKey: groupID)
                self.db.collection("userManagement").document(userID).updateData(["joinGroupDic" : joinGroupDic])
                self.editOKDelegate?.editUserDelete2_OK?()
            }
            activityIndicatorView.stopAnimating()
        }
    }
}
