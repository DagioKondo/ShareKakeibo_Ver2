//
//  OthersViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/22.
//

import UIKit
import Charts

class OthersViewController: UIViewController {
    
    
    var graphModel = GraphModel()
    var yAxisValues = [Int]()
    var loadDBModel = LoadDBModel()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var year = String()
    var month = Int()
    let dateFormatter = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    
    let lineChartsView = LineChartView()
    let yearLabel = UILabel()
    let nextYearButton = UIButton()
    let lastYearButton = UIButton()
    var settlementDay = String()
    var yearCount = 0
    
    var alertModel = AlertModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        
        nextYearButton.addTarget(self, action: #selector(nextYear(_:)), for: .touchUpInside)
        nextYearButton.frame = CGRect(x: view.frame.width - 50, y: 15, width: 50, height: 50)
        nextYearButton.setImage(UIImage(systemName: "arrowtriangle.right"), for: .normal)
        nextYearButton.layer.masksToBounds = false
        nextYearButton.layer.cornerRadius = 5
        nextYearButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        nextYearButton.layer.shadowOpacity = 0.3
        nextYearButton.layer.shadowRadius = 4
        
        lastYearButton.addTarget(self, action: #selector(lastYear(_:)), for: .touchUpInside)
        lastYearButton.frame = CGRect(x: 0, y: 15, width: 50, height: 50)
        lastYearButton.setImage(UIImage(systemName: "arrowtriangle.left"), for: .normal)
        lastYearButton.layer.masksToBounds = false
        lastYearButton.layer.cornerRadius = 5
        lastYearButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        lastYearButton.layer.shadowOpacity = 0.3
        lastYearButton.layer.shadowRadius = 4
        
        yearLabel.frame = CGRect(x: view.frame.midX - 75, y: 10, width: 150, height: 50)
        yearLabel.textAlignment = .center
        yearLabel.layer.masksToBounds = false
        yearLabel.layer.cornerRadius = 5
        yearLabel.layer.shadowOffset = CGSize(width: 0, height: 5)
        yearLabel.layer.shadowOpacity = 0.4
        yearLabel.layer.shadowRadius = 4
        yearLabel.textColor = .darkGray
        yearLabel.font = .boldSystemFont(ofSize: 20)
        
        view.addSubview(activityIndicatorView)
        view.addSubview(lineChartsView)
        view.addSubview(yearLabel)
        view.addSubview(nextYearButton)
        view.addSubview(lastYearButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        yearCount = 0
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = date.month!
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        loadDBModel.loadOKDelegate = self
        
        activityIndicatorView.startAnimating()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        self.settlementDay = UserDefaults.standard.object(forKey: "settlementDay") as! String
        startDate = dateFormatter.date(from: "\(Int(year)! - 1)年\("12")月\(settlementDay)日")!
        endDate = dateFormatter.date(from: "\(year)年\("12")月\(settlementDay)日")!
        yearLabel.text = "\(year)年"
        loadDBModel.loadMonthlyOthersTransition(groupID: groupID, year: year, settlementDay: settlementDay, startDate: startDate, endDate: endDate)
    }
    
    
    @objc func nextYear(_ sender: UIButton){
        yearCount = yearCount + 1
        month = 0
        yearLabel.text = "\(Int(year)! + yearCount)年"
        startDate = dateFormatter.date(from: "\(Int(year)! - 1 + yearCount)年\("12")月\(settlementDay)日")!
        endDate = dateFormatter.date(from: "\(Int(year)! + yearCount)年\("12")月\(settlementDay)日")!
        loadDBModel.loadMonthlyOthersTransition(groupID: groupID, year: year, settlementDay: settlementDay, startDate: startDate, endDate: endDate)
    }
    
    @objc func lastYear(_ sender: UIButton){
        yearCount = yearCount - 1
        month = 0
        yearLabel.text = "\(Int(year)! + yearCount)年"
        startDate = dateFormatter.date(from: "\(Int(year)! - 1 + yearCount)年\("12")月\(settlementDay)日")!
        endDate = dateFormatter.date(from: "\(Int(year)! + yearCount)年\("12")月\(settlementDay)日")!
        loadDBModel.loadMonthlyOthersTransition(groupID: groupID, year: year, settlementDay: settlementDay, startDate: startDate, endDate: endDate)
    }
    
    
}

// MARK: - LoadOKDelegate

extension OthersViewController: LoadOKDelegate{
    
    //１〜１２月のその他の推移を取得完了
    func loadMonthlyTransition_OK(check: Int, countArray: [Int]?) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            yAxisValues = countArray!
            lineChartsView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            graphModel.setLineCht(linechart: lineChartsView, yAxisValues: yAxisValues,thisMonth: month)
            activityIndicatorView.stopAnimating()
        }
    }
    
}
