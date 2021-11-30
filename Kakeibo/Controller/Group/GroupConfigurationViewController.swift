
//
//  GroupConfigurationViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//
import UIKit
import CropViewController
import Firebase
import FirebaseFirestore
import FirebaseStorage

class GroupConfigurationViewController: UIViewController{
    
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var settlementTextField: UITextField!
    @IBOutlet weak var changeGroupButton: UIButton!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var sendDBModel = SendDBModel()
    var db = Firestore.firestore()
    var alertModel = AlertModel()
    var selectedUserImageArray = [String]()
    var groupID = String()
    var groupImage = UIImage()
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var pickerView = UIPickerView()
    let settlementArray = ["5","10","15","20","25"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeGroupButton.layer.cornerRadius = 5
        changeGroupButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        changeGroupButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
        warningLabel.text = ""
        groupImageView.image = groupImage
        
        makePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            presentingViewController?.beginAppearanceTransition(false, animated: animated)
        }
        super.viewWillAppear(animated)
        
        groupNameTextField.text = (UserDefaults.standard.object(forKey: "groupName") as! String)
        settlementTextField.text = (UserDefaults.standard.object(forKey: "settlementDay") as! String)
        
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
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        settlementTextField.endEditing(true)
    }
    
    @IBAction func changeGroupButton(_ sender: Any) {
        
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        activityIndicatorView.startAnimating()
        
        if groupNameTextField.text == "" || settlementTextField.text == ""{
            warningLabel.text = "グループ名と決済日は必須入力です"
            activityIndicatorView.stopAnimating()
        }
        
        if groupImageView.image != groupImage{
            activityIndicatorView.startAnimating()
            sendDBModel.sendOKDelegate = self
            let data = groupImageView.image?.jpegData(compressionQuality: 1.0)
            let groupStoragePath = UserDefaults.standard.object(forKey: "groupStoragePath") as! String
            sendDBModel.sendChangeGroupImage(data: data!, activityIndicatorView: activityIndicatorView, groupStragePath: groupStoragePath)
        }else{
            db.collection("groupManagement").document(groupID).updateData(
                ["groupName": groupNameTextField.text!,"settlementDay": settlementTextField.text!])
            let dateModel = DateModel()
            let newSettlement = dateModel.getNextSettlement(settlement: settlementTextField.text!)
            db.collection("groupManagement").document(groupID).updateData(["nextSettlementDay" : newSettlement])
            let notificationModel = NotificationModel()
            notificationModel.deleteNotification(identifier: groupID)
            notificationModel.registerNotificarionOfSettlement(groupName:groupNameTextField.text!,groupID: groupID,settlementDay: settlementTextField.text!)
            activityIndicatorView.stopAnimating()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func groupImageView(_ sender: Any) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    @IBAction func groupImageViewButton(_ sender: Any) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    
}

// MARK: - SendOKDelegate
extension GroupConfigurationViewController:SendOKDelegate{
    
    
    func sendImage_OK(url: String, storagePath: String?) {
        db.collection("groupManagement").document(groupID).updateData([
            "groupImage": url,
             "groupName": groupNameTextField.text!,
             "settlementDay": settlementTextField.text!
            ])
        dismiss(animated: true, completion: nil)
        activityIndicatorView.stopAnimating()
    }
    
    
}

// MARK: - ImagePicker
extension GroupConfigurationViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] as? UIImage != nil{
            let pickerImage = info[.originalImage] as! UIImage
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
            
            cropController.delegate = self
            cropController.customAspectRatio = groupImageView.frame.size
            //cropBoxのサイズを固定する。
            cropController.cropView.cropBoxResizeEnabled = false
            //pickerを閉じたら、cropControllerを表示する。
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.groupImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - PickerView
extension GroupConfigurationViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    func makePicker(){
        pickerView.dataSource = self
        pickerView.delegate = self
        settlementTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(self.doneButtonOfpicker))
        toolbar.setItems([doneButtonItem], animated: true)
        settlementTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonOfpicker(){
        settlementTextField.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return settlementArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        settlementTextField.text = settlementArray[row]
        return settlementArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        settlementTextField.text = settlementArray[row]
    }
    
    
}
