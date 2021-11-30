//
//  DateModel.swift
//  Kakeibo
//
//  Created by 山口誠士 on 2021/11/20.
//
import Foundation
import SwiftUI
import FirebaseFirestore

class DateModel{
    
    var today = Int()
    var month = Int()
    var year = Int()
    
    
    func getPeriodOfTextField(settelemtDay: Int,completion:(Date,Date) -> ()){
        
        getThisDete()
        
        var minimumDate = Date()
        var maximumDate = Date()
        var minDateStr = String()
        var maxDateStr = String()
        if today < settelemtDay{
            maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 1{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 1)月\(settelemtDay - 1)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }else if today >= settelemtDay{
            minDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 12{
                maxDateStr = "\(year + 1)年1月\(settelemtDay - 1)日"
            }else{
                maxDateStr = "\(year)年\(month + 1)月\(settelemtDay - 1)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }
    }
    
    func getPeriodOfThisMonth(settelemtDay: Int,completion:(Date,Date) -> ()){
        
        getThisDete()
        
        var minimumDate = Date()
        var maximumDate = Date()
        var minDateStr = String()
        var maxDateStr = String()
        if today < settelemtDay{
            maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 1{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 1)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }else if today >= settelemtDay{
            minDateStr = "\(year)年\(month)月\(settelemtDay)日"
            if month == 12{
                maxDateStr = "\(year + 1)年1月\(settelemtDay)日"
            }else{
                maxDateStr = "\(year)年\(month + 1)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }
    }
    
    func getPeriodOfLastMonth(settelemtDay: Int,completion:(Date,Date) -> ()){
        
        getThisDete()
        
        var minimumDate = Date()
        var maximumDate = Date()
        var minDateStr = String()
        var maxDateStr = String()
        if today < settelemtDay{
            if month == 2{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
                maxDateStr = "\(year)年01月\(settelemtDay)日"
            }else if month == 1{
                minDateStr = "\(year - 1)年11月\(settelemtDay)日"
                maxDateStr = "\(year - 1)年12月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 2)月\(settelemtDay)日"
                maxDateStr = "\(year)年\(month - 1)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }else if today >= settelemtDay{
            if month == 1{
                minDateStr = "\(year - 1)年12月\(settelemtDay)日"
                maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            }else{
                minDateStr = "\(year)年\(month - 1)月\(settelemtDay)日"
                maxDateStr = "\(year)年\(month)月\(settelemtDay)日"
            }
            maximumDate = changeDate(dateString: maxDateStr)
            minimumDate = changeDate(dateString: minDateStr)
            completion(maximumDate,minimumDate)
        }
    }
    
//変更①＜start＞------------------------------------------
    
    //設定されたsettlementから次の決済年月日を取得する
    func getNextSettlement(settlement: String) -> Date{
        getThisDete()
        let settlementOfInt = Int(settlement)!
        if today >= settlementOfInt{
            if month == 12{
                let dateOfString = "\(year + 1)年01月\(settlement)日"
                return changeDate(dateString: dateOfString)
            }else{
                let dateOfString = "\(year)年\(month + 1)月\(settlement)日"
                return changeDate(dateString: dateOfString)
            }
        }else{
            let dateOfString = "\(year)年\(month)月\(settlement)日"
            return changeDate(dateString: dateOfString)
        }
    }
    
    //グループのホーム画面（MonthDataViewController）で現在の日付と次の決済年月日を比較し、過ぎているようなら諸々処理を実装
    func checkOfNextsettlement(nextSettlement:Date,groupID:String,settlementDic:Dictionary<String, Bool>){
        //本日の日付を取得
        getThisDete()
        let thisDate = changeDate(dateString: "\(year)年\(month)月\(today)日")
        //日付を比較、処理の実装
        if thisDate >= nextSettlement{
            //newNextSettlementを取得
            let settlementDay = UserDefaults.standard.object(forKey: "settlementDay") as? String
            let newNextsettlement = getNextSettlement(settlement: settlementDay!)
            //グループ情報のsettlementDicとnextSettlementを更新
            changeOfNextSettlement(groupID: groupID, newNextSettlement: newNextsettlement, settlementDic: settlementDic)
        }
    }
    
    //決済日を過ぎた後のsettlementDicとnextSettlementを更新
    func changeOfNextSettlement(groupID:String,newNextSettlement:Date,settlementDic:Dictionary<String, Bool>){
        let db = Firestore.firestore().collection("groupManagement").document(groupID)
        //次の決済年月日を更新
        db.updateData(["nextSettlementDay" :newNextSettlement])
        //settlementDicを更新
        for (key,_) in settlementDic{
            db.setData(["settlementDic" : [key : false]],merge: true)
        }
    }
//変更①＜end＞--------------------------------------------

    
    func getThisDete(){
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month,.day], from: Date())
        today = date.day!
        year = date.year!
        month = date.month!
    }
    
    func changeDate(dateString:String) -> Date{
        var date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        date = dateFormatter.date(from: dateString)!
        
        return date
    }
    
    func changeString(date:Date) -> String{

        var string = String()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        string = dateFormatter.string(from: date)
        
        return string
    }

    
}
