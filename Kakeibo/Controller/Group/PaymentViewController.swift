//
//  PaymentViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import FirebaseFirestore

class PaymentViewController: UIViewController{
    
    
    @IBOutlet weak var paymentConfirmedButton: UIButton!
    @IBOutlet weak var paymentNameTextField: UITextField!
    @IBOutlet weak var paymentDayTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var db = Firestore.firestore()
    var groupID = String()
    var userID = String()
    let dateFormatter = DateFormatter()
    var paymentDay = Date()
    var year = String()
    var month = String()
    var textFieldCalcArray = [Int]()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var pickerViewOfPaymentDay = UIDatePicker()
    var pickerViewOfCategory = UIPickerView()
    let categoryArray = ["食費", "水道代", "電気代", "ガス代", "通信費","家賃","その他"]
    var valueOfCategory = String()
    var valueOfPaymentDay = String()
    var today = Int()
    
    var dateModel = DateModel()
    var changeCommaModel = ChangeCommaModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceTextField.delegate = self
        
        paymentConfirmedButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        paymentConfirmedButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        paymentConfirmedButton.layer.shadowOpacity = 0.5
        paymentConfirmedButton.layer.shadowRadius = 1
        paymentConfirmedButton.layer.cornerRadius = 5
        
        resetButton.layer.cornerRadius = 5
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        //金額入力を数字のみに指定
        let toolberOfPrice = UIToolbar()
        toolberOfPrice.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let buttonItemOfPrice = UIBarButtonItem(title: "合計金額に反映する", style: .done, target: self, action: #selector(self.doneButtonOfPrice))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,target: nil, action: nil)
        
        toolberOfPrice.setItems([flexibleItem,buttonItemOfPrice,flexibleItem], animated: true)
        priceTextField.inputAccessoryView = toolberOfPrice
        priceTextField.keyboardType = UIKeyboardType.numberPad
        makePickerView()
        paymentDayTextField.text = dateModel.changeString(date: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        super.viewWillAppear(animated)
        
        priceLabel.text = ""
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 13.0, *) {
            
            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        paymentConfirmedButton.layer.shadowOpacity = 0
        paymentConfirmedButton.layer.shadowRadius = 0
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        paymentConfirmedButton.layer.shadowOpacity = 0.5
        paymentConfirmedButton.layer.shadowRadius = 1
    }
    
    @IBAction func paymentConfirmedButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        paymentConfirmedButton.layer.shadowOpacity = 0.5
        paymentConfirmedButton.layer.shadowRadius = 1
        
        paymentDay = (dateModel.changeDate(dateString: "\(paymentDayTextField.text!)"))
        
        if priceLabel.text != "" && paymentDayTextField.text != "" && categoryTextField.text != "" && paymentNameTextField.text != "" {
            let paymentAmount = priceLabel.text?.replacingOccurrences(of: ",", with: "")
            db.collection("paymentData").document().setData([
                "paymentAmount" : Int(paymentAmount!)!,
                "productName" : paymentNameTextField.text!,
                "paymentDay" : paymentDay as Date,
                "category" : categoryTextField.text!,
                "userID" : userID,
                "groupID" : groupID
            ])
            
            dismiss(animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "全て必須入力です", message: "", preferredStyle: .alert)

            let cancel = UIAlertAction(title: "OK", style: .cancel) { (acrion) in
            }
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func resetButton(_ sender: Any) {
        priceTextField.text = ""
        priceLabel.text = ""
        textFieldCalcArray = []
    }
    
    
}

// MARK: - PickerView
extension PaymentViewController: UIPickerViewDelegate,UIPickerViewDataSource{
   
    
    func makePickerView(){
        pickerViewOfCategory.delegate = self
        pickerViewOfCategory.dataSource = self
        
        //カテゴリーのピッカーの生成
        categoryTextField.inputView = pickerViewOfCategory
        let toolbarOfCategory = UIToolbar()
        toolbarOfCategory.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let buttonItemOfCategory = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(self.doneButtonOfCategory))
        toolbarOfCategory.setItems([buttonItemOfCategory], animated: true)
        categoryTextField.inputAccessoryView = toolbarOfCategory
        
        //支払い日のピッカーを生成
        pickerViewOfPaymentDay.preferredDatePickerStyle = .wheels
        pickerViewOfPaymentDay.datePickerMode = .date
        pickerViewOfPaymentDay.locale = Locale(identifier: "ja_JP")
        pickerViewOfPaymentDay.addTarget(self, action: #selector(self.dateChanged(_ :)), for: .valueChanged)
        paymentDayTextField.inputView = pickerViewOfPaymentDay
        let toolbarOfPaymentDay = UIToolbar()
        toolbarOfPaymentDay.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let buttonItemOfPaymentDay = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(self.doneButtonOfPaymentDay))
        toolbarOfPaymentDay.setItems([buttonItemOfPaymentDay], animated: true)
        paymentDayTextField.inputAccessoryView = toolbarOfPaymentDay
        
//        支払い日の選択期間を取得＆反映
//        let settlementDayString = UserDefaults.standard.object(forKey: "settlementDay") as! String
//        let settlementDay = Int(settlementDayString)
//        dateModel.getPeriodOfTextField(settelemtDay: settlementDay!, completion: { maxDate, minDate in
//            pickerViewOfPaymentDay.maximumDate = maxDate
//            pickerViewOfPaymentDay.minimumDate = minDate
//        })
        
    }
    
    @objc func doneButtonOfCategory(){
        categoryTextField.endEditing(true)
        
    }
    @objc func doneButtonOfPaymentDay(){
        paymentDayTextField.text = dateModel.changeString(date: pickerViewOfPaymentDay.date)
        paymentDayTextField.endEditing(true)
    }
    
    @objc func dateChanged(_ picker: UIDatePicker){
        paymentDayTextField.text = dateModel.changeString(date: picker.date)
    }
    
    @objc func doneButtonOfPrice(){
        priceTextField.resignFirstResponder()
        if let num:Int = Int(priceTextField.text!){
            textFieldCalcArray.append(num)
            print(num)
        }
        priceLabel.text = "\(changeCommaModel.getComma(num: textFieldCalcArray.reduce(0){ $0 + $1 }))"
        priceTextField.text = ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        categoryTextField.text = categoryArray[row]
        return categoryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoryTextField.text = categoryArray[row]
    }
    
    
}

// MARK: - UITextFieldDelegate
extension PaymentViewController: UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let num:Int = Int(textField.text!){
            textFieldCalcArray.append(num)
            print(num)
        }
        priceLabel.text = "\(changeCommaModel.getComma(num: textFieldCalcArray.reduce(0){ $0 + $1 }))"
        textField.text = ""
        return true
    }
    
    
}

// MARK: -
extension PaymentViewController {
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
    
}
