//
//  GraphModel.swift
//  kakeiboApp
//
//  Created by nishimaru on 2021/10/23.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import Foundation
import UIKit
import Charts


class ChartFormatter: NSObject, IAxisValueFormatter {
    let xAxisValues = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        return xAxisValues[index]
    }
}

class GraphModel: ChartViewDelegate{
    
    @IBInspectable var animationDuration: Double = 0.8
    
    let shokuhiColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
    let suidouColor = UIColor(red: 218 / 255, green: 251 / 255, blue: 255 / 255, alpha: 1.0)
    let denkiColor = UIColor(red: 250 / 255, green: 255 / 255, blue: 140 / 255, alpha: 1.0)
    let gasColor = UIColor(red: 255 / 255, green: 149 / 255, blue: 97 / 255, alpha: 1.0)
    let tushinColor = UIColor(red: 146 / 255, green: 255 / 255, blue: 151 / 255, alpha: 1.0)
    let yachinColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 177 / 255, alpha: 1.0)
    let sonotaColor = UIColor.systemGray3
    
    var pieChartDataSet = PieChartDataSet()
    var categoryDic = [Dictionary<String, Int>.Element]()
    var changeCommaModel = ChangeCommaModel()
    
    func setLineCht(linechart: LineChartView,yAxisValues: [Int],thisMonth: Int) {
        
        var dataSets = [LineChartDataSet]()
        
        let entries = yAxisValues.enumerated().map{ ChartDataEntry(x: Double($0.offset), y: Double($0.element)) }
        let dataSet = LineChartDataSet(entries: entries, label: "月毎の合計支出(円)")
        dataSets.append(dataSet)
        linechart.data = LineChartData(dataSets: dataSets as [IChartDataSet])
        
        let formatter = ChartFormatter()
        linechart.xAxis.valueFormatter = formatter
        linechart.extraRightOffset = 30
        linechart.xAxis.labelCount = 12
        linechart.xAxis.granularity = 1.0
        linechart.xAxis.gridColor = .clear
        linechart.rightAxis.enabled = false
        linechart.leftAxis.drawZeroLineEnabled = true
        linechart.leftAxis.axisMinimum = 0
        linechart.leftAxis.gridLineWidth = 0.1
        linechart.leftAxis.gridColor = .darkGray
        linechart.zoom(scaleX: 2, scaleY: 1, xValue: Double(thisMonth), yValue: 1, axis: .right)
        
        linechart.legend.enabled = false
        linechart.animate(xAxisDuration: 0.8, easingOption: .easeInBack)
        
        linechart.layer.masksToBounds = false
        linechart.layer.cornerRadius = 5
        linechart.layer.shadowOffset = CGSize(width: 0, height: 5)
        linechart.layer.shadowOpacity = 0.3
        linechart.layer.shadowRadius = 4
        
        dataSet.lineWidth = 3
        dataSet.setColor(shokuhiColor)
        dataSet.circleColors = [shokuhiColor]
        dataSet.formSize = 15
        
    }
    
    
    
    func setPieCht(piecht: PieChartView,categoryDic: [Dictionary<String, Int>.Element]){
        
        self.categoryDic = categoryDic
        let categoryColors = ["食費":shokuhiColor,"水道代":suidouColor,"電気代":denkiColor,"ガス代":gasColor,"通信費":tushinColor,"家賃":yachinColor,"その他":sonotaColor]
        var colors = [UIColor]()
        var dataEntries: [ChartDataEntry] = []
        
        for category in categoryDic {
            colors.append(categoryColors[category.key]!)
            let price = changeCommaModel.getComma(num: category.value)
            dataEntries.append(PieChartDataEntry(value: Double(category.value), label: "\(category.key) :\(price)", data: Double(category.value)))
        }
        
        pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "カテゴリー別支出(円)")
        
        pieChartDataSet.colors = colors
        pieChartDataSet.valueColors = [.clear,.clear,.clear,.clear,.clear,.clear,.clear]
        pieChartDataSet.entryLabelColor = .clear
        pieChartDataSet.valueLineColor = .clear
        pieChartDataSet.valueLinePart1Length = 0.5
        pieChartDataSet.selectionShift = 6
        pieChartDataSet.sliceSpace = 1.5
        pieChartDataSet.automaticallyDisableSliceSpacing = true
        
        piecht.layer.masksToBounds = false
        piecht.layer.cornerRadius = 5
        piecht.layer.shadowOffset = CGSize(width: 1, height: 5)
        piecht.layer.shadowOpacity = 0.3
        piecht.layer.shadowRadius = 4
        
        piecht.delegate = self
        piecht.legend.formSize = 15
        piecht.legend.formToTextSpace = 7
        piecht.legend.yEntrySpace = 10
        piecht.legend.font = UIFont(descriptor: UIFontDescriptor(), size: 14)
        piecht.legend.textColor = .darkGray
        piecht.data = PieChartData(dataSet: pieChartDataSet)
        piecht.animate(yAxisDuration: 2)
        piecht.rotationEnabled = false
        piecht.highlightPerTapEnabled = true
        piecht.centerText = "今月の支出"
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        pieChartDataSet.valueColors = [.clear,.clear,.clear,.clear,.clear,.clear,.clear]
        var index = Int()
        index = categoryDic.firstIndex(where: { $0.value == entry.data as! Int })!
        pieChartDataSet.valueColors[index] = .darkGray
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        pieChartDataSet.valueColors = [.clear,.clear,.clear,.clear,.clear,.clear,.clear]
    }
    
}
