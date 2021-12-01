//
//  NotificationModel.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/11/29.
//

import Foundation
import UserNotifications


class NotificationModel{
    
    func registerNotificarionOfSettlement(groupName:String,groupID:String,settlementDay:String){
        
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "シェア家計簿"
        content.subtitle = "決済日通知"
        content.body = "今日は【\(groupName)】グループの決済日です！"
        content.userInfo = ["groupID":groupID]
        
        let date = DateComponents(day:Int(settlementDay),hour: 12)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: groupID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request){ (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteNotification(identifier:String){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
