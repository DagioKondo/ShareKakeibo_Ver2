//
//  getCommaModel.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/11/22.
//

import Foundation

class ChangeCommaModel {
    
    func getComma(num: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.groupingSize = 3
            let number = "\(formatter.string(from: NSNumber(value: num)) ?? "")"
            
            return number
        }

}
