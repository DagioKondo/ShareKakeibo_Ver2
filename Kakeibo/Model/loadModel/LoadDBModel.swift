//
//  LoadDBModel.swift
//  Kakeibo
//
//  Created by 都甲裕希 on 2021/10/24.
//
import Foundation
import Firebase
import FirebaseFirestore

@objc protocol LoadOKDelegate {
    
    @objc optional func loadUserInfo_OK(check:Int,userName:String?,profileImage:String?,email:String?,password:String?,profileStoragePath:String?)
    @objc optional func loadUserSearch_OK(check:Int)
    @objc optional func loadJoinGroup_OK(check:Int)
    @objc optional func loadNotJoinGroup_OK(check:Int,groupIDArray:[String]?,notJoinCount:Int)
    @objc optional func loadNotJoinGroupInfo_OK(check:Int)
    @objc optional func loadGroupName_OK(check:Int,groupName:String?,groupImage:String?,groupStoragePath:String?,nextSettlementDay: Date?)
    @objc optional func loadSettlementNotification_OK(check:Int)
    @objc optional func loadSettlementDay_OK(check:Int,settlementDay:String?)
    @objc optional func loadUserIDAndSettlementDic_OK(check:Int,settlementDic:Dictionary<String,Bool>?,userIDArray:[String]?)
    @objc optional func loadGroupMember_OK(check:Int)
    @objc optional func loadMonthDetails_OK(check:Int)
    @objc optional func loadCategoryGraphOfTithMonth_OK(check:Int,categoryDic:Dictionary<String,Int>?)
    @objc optional func loadMonthlyTransition_OK(check:Int,countArray:[Int]?)
    @objc optional func loadMonthPayment_OK(check:Int,groupPaymentOfMonth:Int,paymentAverageOfMonth:Int,userIDArray:[String]?)
    @objc optional func loadMonthSettlement_OK(check:Int)
    
}

class LoadDBModel{
    
    var loadOKDelegate:LoadOKDelegate?
    var db = Firestore.firestore()
    var groupSets:[GroupSets] = []
    var userSearchSets = [UserSearchSets]()
    var notificationSets = [NotificationSets]()
    var monthMyDetailsSets = [MonthMyDetailsSets]()
    var monthGroupDetailsSets = [MonthGroupDetailsSets]()
    var settlementSets = [SettlementSets]()
    let dateFormatter = DateFormatter()
    var countArray = [Int]()
    

    //userの情報を取得するメソッド
    func loadUserInfo(userID:String){
        db.collection("userManagement").document(userID).addSnapshotListener { [self] (snapShot, error) in
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadUserInfo_OK?(check: 0, userName: nil, profileImage: nil, email: nil, password: nil, profileStoragePath: nil)
                return
            }
            let data = snapShot?.data()
            if let userName = data!["userName"] as? String,let profileImage = data!["profileImage"] as? String,let email = data!["email"] as? String,let password = data!["password"] as? String,let profileStoragePath = data!["profileStoragePath"] as? String{
                loadOKDelegate?.loadUserInfo_OK?(check: 1, userName: userName, profileImage: profileImage, email: email, password: password, profileStoragePath: profileStoragePath)
            }
        }
    }
    
    //メールアドレスで検索するメソッド。メールアドレスと一致するユーザー情報を取得。
    func loadUserSearch(email:String){
        db.collection("userManagement").order(by: "email").start(at: [email]).end(at: [email + "\u{f8ff}"]).getDocuments() { [self] (snapShot, error) in
            
            print(email)
            self.userSearchSets = []
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadUserSearch_OK?(check: 0)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let userName = data["userName"] as! String
                    let profileImage = data["profileImage"] as! String
                    let userID = data["userID"] as! String
                    let newData = UserSearchSets(userName: userName, profileImage: profileImage, userID: userID)
                    self.userSearchSets.append(newData)
                }
            }
            loadOKDelegate?.loadUserSearch_OK?(check: 1)
        }
    }
    
    
    //参加しているグループの情報を取得するロード
    func loadJoinGroup(groupID:String,userID:String){
        db.collection("groupManagement").whereField("userIDArray", arrayContains: userID).order(by: "create_at").addSnapshotListener { [self] (snapShot, error) in
            self.groupSets = []
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadJoinGroup_OK?(check: 0)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let groupName = data["groupName"] as! String
                    let groupImage = data["groupImage"] as! String
                    let groupID = data["groupID"] as! String
                    let newData = GroupSets(groupName: groupName, groupImage: groupImage, groupID: groupID, create_at: nil)
                    self.groupSets.append(newData)
                }
            }
            groupSets.reverse()
            loadOKDelegate?.loadJoinGroup_OK?(check: 1)
        }
    }
    
    //招待されているグループの数を取得するロード
    func loadNotJoinGroup(userID:String){
        db.collection("userManagement").document(userID).addSnapshotListener { [self] (snapShot, error) in
            
            var groupIDArray = [String]()
            var notJoinCount = 0
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadNotJoinGroup_OK?(check: 0, groupIDArray: nil, notJoinCount: 0)
                return
            }
            if let data = snapShot?.data(){
                if let joinGroupDic = data["joinGroupDic"] as? Dictionary<String,Bool>{
                    for (key,value) in joinGroupDic{
                        if value == false{
                            groupIDArray.append(key)
                            notJoinCount = notJoinCount + 1
                        }
                    }
                }
            }
            loadOKDelegate?.loadNotJoinGroup_OK?(check: 1, groupIDArray: groupIDArray, notJoinCount: notJoinCount)
        }
    }
    
    //招待されているグループの情報を取得するロード
    func loadNotJoinGroupInfo(groupIDArray:[String],completion:@escaping(GroupSets)->()){
        
        var count = 0

        for groupID in groupIDArray{
            db.collection("groupManagement").document(groupID).getDocument { [self] (sanpShot, error) in
                count += 1
                if error != nil{
                    print(errorMessage(of: error!))
                    loadOKDelegate?.loadNotJoinGroupInfo_OK?(check: 0)
                    return
                }
                if let data = sanpShot?.data(){
                    let groupName = data["groupName"] as! String
                    let groupImage = data["groupImage"] as! String
                    let groupID = data["groupID"] as! String
                    let create_at = data["create_at"] as! Double
                    let newData = GroupSets(groupName: groupName, groupImage: groupImage, groupID: groupID, create_at: create_at)
                    completion(newData)
                }
                if groupIDArray.count == count{
                    loadOKDelegate?.loadNotJoinGroupInfo_OK?(check: 1)
                }
            }
        }
        loadOKDelegate?.loadNotJoinGroupInfo_OK?(check: 1)
        
    }
    
    //グループ名、グループ画像を取得するロード。
    func loadGroupName(groupID:String){
        db.collection("groupManagement").document(groupID).getDocument { [self] (snapShot, error) in
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadGroupName_OK?(check: 0, groupName: nil, groupImage: nil, groupStoragePath: nil, nextSettlementDay: nil)
                return
            }
            if let data = snapShot?.data(){
                let groupName = data["groupName"] as! String
                let groupImage = data["groupImage"] as! String
                let groupStoragePath = data["groupStoragePath"] as! String
                let timestamp = data["nextSettlementDay"] as! Timestamp
                let nextSettlementDay = timestamp.dateValue()
                loadOKDelegate?.loadGroupName_OK?(check: 1, groupName: groupName, groupImage: groupImage, groupStoragePath: groupStoragePath, nextSettlementDay: nextSettlementDay)
            }
        }
    }
    
    //決済日を取得し決済通知するロード
    func loadSettlementNotification(userID:String,day:String){
        db.collection("groupManagement").whereField("userIDArray", arrayContains: userID).addSnapshotListener { [self] (snapShot, error) in
            
            self.notificationSets = []
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadSettlementNotification_OK?(check: 0)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let settlementDay = data["settlementDay"] as! String
                    let groupName = data["groupName"] as! String
                    let groupID = data["groupID"] as! String
                    if settlementDay == day{
                        let newData = NotificationSets(groupName: groupName, groupID: groupID)
                        self.notificationSets.append(newData)
                    }
                }
            }
            loadOKDelegate?.loadSettlementNotification_OK?(check: 1)
        }
    }
    
    //決済日を取得するロード
    func loadSettlementDay(groupID:String){
        db.collection("groupManagement").document(groupID).getDocument { [self] (snapShot, error) in
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadSettlementDay_OK?(check: 0, settlementDay: nil)
                return
            }
            if let data = snapShot?.data(){
                let settlementDay = data["settlementDay"] as! String
                loadOKDelegate?.loadSettlementDay_OK?(check: 1, settlementDay: settlementDay)
            }
        }
    }
    
    //グループに所属する人のuserIDと決済可否を取得するロード
    func loadUserIDAndSettlementDic(groupID:String){
        db.collection("groupManagement").document(groupID).getDocument { [self] (snapShot, error) in
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadUserIDAndSettlementDic_OK?(check: 0, settlementDic: nil, userIDArray: nil)
                return
            }
            if let data = snapShot?.data(){
                let settlementDic = data["settlementDic"] as! Dictionary<String,Bool>
                let userIDArray = data["userIDArray"] as! Array<String>
                loadOKDelegate?.loadUserIDAndSettlementDic_OK?(check: 1, settlementDic: settlementDic, userIDArray: userIDArray)
            }
        }
    }
    
    //グループに所属する人の名前とプロフィール画像を取得するロード
    func loadGroupMember(userIDArray:[String],completion:@escaping(UserSets)->()){
        
        var count = 0
        if userIDArray.count != 0{
            for userID in userIDArray{
                db.collection("userManagement").document(userID).getDocument { [self] (snapShot, error) in
                    count += 1
                    if error != nil{
                        print(errorMessage(of: error!))
                        loadOKDelegate?.loadGroupMember_OK?(check: 0)
                        return
                    }
                    if let data = snapShot?.data(){
                        let profileImage = data["profileImage"] as! String
                        let userName = data["userName"] as! String
                        let newData = UserSets(profileImage: profileImage, userName: userName, userID: userID)
                        completion(newData)
                    }
                    if count == userIDArray.count{
                        loadOKDelegate?.loadGroupMember_OK?(check: 1)
                    }
                }
            }
        }else{
            loadOKDelegate?.loadGroupMember_OK?(check: 1)
        }
        
    }
    
    //全体の明細のロード(月分)
    //自分の明細のロード(月分)
    func loadMonthDetails(groupID:String,startDate:Date,endDate:Date,userID:String?){
        self.dateFormatter.dateFormat = "yyyy/MM/dd"
        self.dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        if userID == nil{
            //全体の明細のロード(月分)
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).order(by: "paymentDay").getDocuments { [self] (snapShot, error) in
                
                self.monthGroupDetailsSets = []
                if error != nil{
                    print(errorMessage(of: error!))
                    loadOKDelegate?.loadMonthDetails_OK?(check: 0)
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let productName = data["productName"] as! String
                        let paymentAmount = data["paymentAmount"] as! Int
                        let timestamp = data["paymentDay"] as! Timestamp
                        let category = data["category"] as! String
                        let userID = data["userID"] as! String
                        let date = timestamp.dateValue()
                        let paymentDay = self.dateFormatter.string(from: date)
                        let groupNewData = MonthGroupDetailsSets(productName: productName, paymentAmount: paymentAmount, paymentDay: paymentDay, category: category, userID: userID)
                        self.monthGroupDetailsSets.append(groupNewData)
                    }
                }
                monthGroupDetailsSets.reverse()
                loadOKDelegate?.loadMonthDetails_OK?(check: 1)
            }
        }else if userID != nil{
            //自分の明細のロード(月分)
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("userID", isEqualTo: userID!).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).order(by: "paymentDay").getDocuments { [self] (snapShot, error) in
                
                self.monthMyDetailsSets = []
                if error != nil{
                    print(errorMessage(of: error!))
                    loadOKDelegate?.loadMonthDetails_OK?(check: 0)
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let documentID = doc.documentID
                        let productName = data["productName"] as! String
                        let paymentAmount = data["paymentAmount"] as! Int
                        let timestamp = data["paymentDay"] as! Timestamp
                        let category = data["category"] as! String
                        let userID = data["userID"] as! String
                        let date = timestamp.dateValue()
                        let paymentDay = self.dateFormatter.string(from: date)
                        let myNewData = MonthMyDetailsSets(productName: productName, paymentAmount: paymentAmount, paymentDay: paymentDay, category: category, userID: userID, documentID: documentID)
                        self.monthMyDetailsSets.append(myNewData)
                    }
                }
                monthMyDetailsSets.reverse()
                loadOKDelegate?.loadMonthDetails_OK?(check: 1)
            }
        }
    }
    
    //カテゴリ別の合計金額金額
    func loadCategoryGraphOfTithMonth(groupID:String,startDate:Date,endDate:Date){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).getDocuments { [self] (snapShot, error) in
            
            var foodCount = 0
            var waterCount = 0
            var electricityCount = 0
            var gasCount = 0
            var communicationCount = 0
            var rentCount = 0
            var othersCount = 0
            
            var categoryDic = [String:Int]()
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadCategoryGraphOfTithMonth_OK?(check: 0, categoryDic: nil)
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let category = data["category"] as! String
                    let paymentAmount = data["paymentAmount"] as! Int
                    switch category {
                    case "食費":
                        foodCount = foodCount + paymentAmount
                        categoryDic.updateValue(foodCount, forKey: "食費")
                    case "水道代":
                        waterCount = waterCount + paymentAmount
                        categoryDic.updateValue(waterCount, forKey: "水道代")
                    case "電気代":
                        electricityCount = electricityCount + paymentAmount
                        categoryDic.updateValue(electricityCount, forKey: "電気代")
                    case "ガス代":
                        gasCount = gasCount + paymentAmount
                        categoryDic.updateValue(gasCount, forKey: "ガス代")
                    case "通信費":
                        communicationCount = communicationCount + paymentAmount
                        categoryDic.updateValue(communicationCount, forKey: "通信費")
                    case "家賃":
                        rentCount = rentCount + paymentAmount
                        categoryDic.updateValue(rentCount, forKey: "家賃")
                    case "その他":
                        othersCount = othersCount + paymentAmount
                        categoryDic.updateValue(othersCount, forKey: "その他")
                    default:
                        break
                    }
                }
                
                for (key,value) in categoryDic{
                    if value == 0{
                        categoryDic.removeValue(forKey: key)
                    }
                }
            }
            loadOKDelegate?.loadCategoryGraphOfTithMonth_OK?(check: 1, categoryDic: categoryDic)
        }
    }
    
    
    //1〜12月の全体の推移
    func loadMonthlyAllTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).getDocuments { [self] (snapShot, error) in
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadMonthlyTransition_OK?(check: 0, countArray: nil)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(check: 1, countArray: countArray)
        }
    }
    
    //1〜12月の項目ごとの光熱費と家賃と通信費の推移
    func loadMonthlyUtilityTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).whereField("category", in: ["水道代","電気代","ガス代","家賃","通信費"]).getDocuments { [self] (snapShot, error) in
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadMonthlyTransition_OK?(check: 0, countArray: nil)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(check: 1, countArray: countArray)
        }
    }
    
    //1〜12月の項目ごとの食費の推移
    func loadMonthlyFoodTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).whereField("category", isEqualTo: "食費").getDocuments { [self] (snapShot, error) in
            
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadMonthlyTransition_OK?(check: 0, countArray: nil)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(check: 1, countArray: countArray)
        }
    }
    
    //1〜12月の項目ごとのその他の推移
    func loadMonthlyOthersTransition(groupID:String,year:String,settlementDay:String,startDate:Date,endDate:Date){
        
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).whereField("category", isEqualTo: "その他").getDocuments { [self] (snapShot, error) in
            
            countArray = []
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let january = dateFormatter.date(from: "\(year)年1月\(settlementDay)日")
            let february = dateFormatter.date(from: "\(year)年2月\(settlementDay)日")
            let march = dateFormatter.date(from: "\(year)年3月\(settlementDay)日")
            let april = dateFormatter.date(from: "\(year)年4月\(settlementDay)日")
            let may = dateFormatter.date(from: "\(year)年5月\(settlementDay)日")
            let june = dateFormatter.date(from: "\(year)年6月\(settlementDay)日")
            let july = dateFormatter.date(from: "\(year)年7月\(settlementDay)日")
            let august = dateFormatter.date(from: "\(year)年8月\(settlementDay)日")
            let september = dateFormatter.date(from: "\(year)年9月\(settlementDay)日")
            let october = dateFormatter.date(from: "\(year)年10月\(settlementDay)日")
            let november = dateFormatter.date(from: "\(year)年11月\(settlementDay)日")
            let december = dateFormatter.date(from: "\(year)年12月\(settlementDay)日")
            
            var januaryCount = 0
            var februaryCount = 0
            var marchCount = 0
            var aprilCount = 0
            var mayCount = 0
            var juneCount = 0
            var julyCount = 0
            var augustCount = 0
            var septemberCount = 0
            var octoberCount = 0
            var novemberCount = 0
            var decemberCount = 0
            
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadMonthlyTransition_OK?(check: 0, countArray: nil)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let paymentDay = timestamp.dateValue()
                    if startDate < paymentDay && paymentDay <= january!{
                        januaryCount = januaryCount + paymentAmount
                    }else if january! < paymentDay && paymentDay <= february!{
                        februaryCount = februaryCount + paymentAmount
                    }else if february! < paymentDay && paymentDay <= march!{
                        marchCount = marchCount + paymentAmount
                    }else if march! < paymentDay && paymentDay <= april!{
                        aprilCount = aprilCount + paymentAmount
                    }else if april! < paymentDay && paymentDay <= may!{
                        mayCount = mayCount + paymentAmount
                    }else if may! < paymentDay && paymentDay <= june!{
                        juneCount = juneCount + paymentAmount
                    }else if june! < paymentDay && paymentDay <= july!{
                        julyCount = julyCount + paymentAmount
                    }else if july! < paymentDay && paymentDay <= august!{
                        augustCount = augustCount + paymentAmount
                    }else if august! < paymentDay && paymentDay <= september!{
                        septemberCount = septemberCount + paymentAmount
                    }else if september! < paymentDay && paymentDay <= october!{
                        octoberCount = octoberCount + paymentAmount
                    }else if october! < paymentDay && paymentDay <= november!{
                        novemberCount = novemberCount + paymentAmount
                    }else if november! < paymentDay && paymentDay <= december!{
                        decemberCount = decemberCount + paymentAmount
                    }
                }
            }
            countArray = [januaryCount,februaryCount,marchCount,aprilCount,mayCount,juneCount,julyCount,augustCount,septemberCount,octoberCount,novemberCount,decemberCount]
            loadOKDelegate?.loadMonthlyTransition_OK?(check: 1, countArray: countArray)
        }
    }
    
    //(グループの合計金額)と(1人当たりの金額)と(支払いに参加したユーザー)をロード
    func loadMonthPayment(groupID:String,userIDArray:[String],startDate:Date,endDate:Date){
        db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).getDocuments { [self] (snapShot, error) in
            
            var groupPaymentOfMonth = 0
            var paymentAverageOfMonth = 0
            if error != nil{
                print(errorMessage(of: error!))
                loadOKDelegate?.loadMonthPayment_OK?(check: 0, groupPaymentOfMonth: 0, paymentAverageOfMonth: 0, userIDArray: nil)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    let paymentAmount = data["paymentAmount"] as! Int
                    groupPaymentOfMonth = groupPaymentOfMonth + paymentAmount
                }
                if userIDArray.count == 0{
                    loadOKDelegate?.loadMonthPayment_OK?(check: 1, groupPaymentOfMonth: groupPaymentOfMonth, paymentAverageOfMonth: paymentAverageOfMonth, userIDArray: userIDArray)
                }else{
                    let numberOfPeople = userIDArray.count
                    paymentAverageOfMonth = groupPaymentOfMonth / numberOfPeople
                    loadOKDelegate?.loadMonthPayment_OK?(check: 1, groupPaymentOfMonth: groupPaymentOfMonth, paymentAverageOfMonth: paymentAverageOfMonth, userIDArray: userIDArray)
                }
                
            }
        }
    }
    
    //グループの支払状況のロード
    //各メンバーの支払い金額を取得するロード
    func loadMonthSettlement(groupID:String,userID:String?,startDate:Date,endDate:Date){
        if userID == nil{
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).getDocuments { [self] (snapShot, error) in
                
                self.settlementSets = []
                if error != nil{
                    print(errorMessage(of: error!))
                    loadOKDelegate?.loadMonthSettlement_OK?(check: 0)
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let paymentAmount = data["paymentAmount"] as! Int
                        let userID = data["userID"] as! String
                        let newData = SettlementSets(paymentAmount: paymentAmount, userID: userID)
                        settlementSets.append(newData)
                    }
                    loadOKDelegate?.loadMonthSettlement_OK?(check: 1)
                }
                loadOKDelegate?.loadMonthSettlement_OK?(check: 1)
            }
        }else{
            db.collection("paymentData").whereField("groupID", isEqualTo: groupID).whereField("userID", isEqualTo: userID!).whereField("paymentDay", isGreaterThanOrEqualTo: startDate).whereField("paymentDay", isLessThan: endDate).getDocuments { [self] (snapShot, error) in
                
                self.settlementSets = []
                var myTotalPay = 0
                if error != nil{
                    print(errorMessage(of: error!))
                    loadOKDelegate?.loadMonthSettlement_OK?(check: 0)
                    return
                }
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        let paymentAmount = data["paymentAmount"] as! Int
                        //自分の支払い合計金額
                        myTotalPay = myTotalPay + paymentAmount
                    }
                    let newData = SettlementSets(paymentAmount: myTotalPay, userID: nil)
                    settlementSets.append(newData)
                    loadOKDelegate?.loadMonthSettlement_OK?(check: 1)
                }
            }
        }
    }
    
    private func errorMessage(of error:Error) -> String{
        var message = "エラーが発生しました"
        guard let errcd = FirestoreErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        
        switch errcd {
        case .OK: message = "操作は正常に完了しました"
        case .aborted: message = "操作が中止されました"
        case .invalidArgument: message = "無効なフィールド名です"
        case .alreadyExists: message = "作成しようとしたドキュメントはすでに存在します"
        case .cancelled: message = "キャンセルされました"
        case .deadlineExceeded: message = "サーバーからの正常な応答はありません"
        case .notFound: message = "リクエストされたドキュメントが見つかりませんでした"
        case .outOfRange: message = "有効範囲を超えて操作を試みました"
        case .permissionDenied: message = "アクセスを拒否されています"
        case .resourceExhausted: message = "一部のリソースが使い果たされているか、ユーザーごとの割り当てが不足しているか、ファイルシステム全体の容量が不足している可能性があります。"
        case .failedPrecondition: message = "操作は拒否されました"
        case .unauthenticated: message = "操作に有効な認証クレデンシャルがありません"
        case .unavailable: message = "このサービスは現在ご利用いただけません"
        case .unimplemented: message = "操作が実装されていないか、サポート/有効化されていません"
        case .unknown: message = "不明なエラーです"
        case .internal: message = "内部エラーです"
        case .dataLoss: message = "回復不能なデータの損失または破損"

        default: break
        }
        return message
        
    }
    
}
