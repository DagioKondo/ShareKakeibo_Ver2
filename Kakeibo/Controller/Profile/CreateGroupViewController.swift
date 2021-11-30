//
//  ViewController.swift
//  shareKakeibo
//
//  Created by nishimaru on 2021/10/25.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import UIKit
import CropViewController
import Firebase
import FirebaseFirestore
import FirebaseStorage

class CreateGroupViewController: UIViewController{
    
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var settlementTextField: UITextField!
    @IBOutlet weak var searchUserButton: UIButton!
    @IBOutlet weak var createGroupButton: UIButton!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var sendDBModel = SendDBModel()
    var db = Firestore.firestore()
    var selectedUserImageArray = [String]()
    var userIDArray = [String]()
    var userNameArray = [String]()
    var userID = String()
    var userName = String()
    var profileImage = String()
    var alertModel = AlertModel()
    var pickerView = UIPickerView()
    let settlementArray = ["5","10","15","20","25"]
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var activityIndicatorView = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "グループ作成"
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        
        searchUserButton.layer.cornerRadius = 5
        
        searchUserButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        searchUserButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        createGroupButton.layer.cornerRadius = 5
        createGroupButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        createGroupButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
        warningLabel.text = ""
        
        makePicker()
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    @IBAction func searchUserButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        performSegue(withIdentifier: "searchVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let searchVC = segue.destination as! SearchViewController
        searchVC.collectionDeligate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        settlementTextField.endEditing(true)
    }
    
    @IBAction func createGroupButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        activityIndicatorView.startAnimating()
        if groupNameTextField.text == "" || settlementTextField.text == ""{
            warningLabel.text = "グループ名と決済日は必須入力です"
            activityIndicatorView.stopAnimating()
        }else{
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            userName = UserDefaults.standard.object(forKey: "userName") as! String
            profileImage = UserDefaults.standard.object(forKey: "profileImage") as! String
            
            if groupImageView.image == nil{
                groupImageView.image = UIImage(named: "home2")
            }
            sendDBModel.sendOKDelegate = self
            let data = groupImageView.image?.jpegData(compressionQuality: 1.0)
            sendDBModel.sendGroupImage(data: data!, activityIndicatorView: activityIndicatorView)
        }
    }

    
    @IBAction func groupImageView(_ sender: Any) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    @IBAction func groupImageViewButton(_ sender: Any) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    
}

//MARK:- UICollectionView
extension CreateGroupViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUserImageArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.profileImage.sd_setImage(with: URL(string: selectedUserImageArray[indexPath.row]), completed: nil)
        cell.deleteButton!.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
        cell.userNameLabel.text = userNameArray[indexPath.row]
        print("daigoitemAt")
        print(cell.deleteButton.tag)
        
        return cell
    }
    
    @objc func tapDeleteButton(_ sender:UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        selectedUserImageArray.remove(at: indexPath!.row)
        userIDArray.remove(at: indexPath!.row)
        print(userIDArray)
        collectionView.deleteItems(at: [IndexPath(item: indexPath!.row, section: 0)])
    }
    
    
}

//MARK:- ImagePicker
extension CreateGroupViewController:CropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

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
        //トリミング編集が終えたら、呼び出される。
        self.groupImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
}
//MARK:- SendOKDelegate
extension CreateGroupViewController:SendOKDelegate{
    
    func sendImage_OK(url: String, storagePath: String?) {
           let groupDocument = db.collection("groupManagement").document()
           let groupID = groupDocument.documentID
           UserDefaults.standard.setValue(groupID, forKey: "groupID")
           
           let dateModel = DateModel()
           let nextSettlementDay = dateModel.getNextSettlement(settlement: settlementTextField.text!)
           let notificationModel = NotificationModel()
        notificationModel.registerNotificarionOfSettlement(groupName:groupNameTextField.text!,groupID: groupID,settlementDay: settlementTextField.text!)
           
           db.collection("groupManagement").document(groupID).setData([
               "groupName": groupNameTextField.text!,
               "groupImage": url,
               "groupStoragePath": storagePath!,
               "settlementDay": settlementTextField.text!,
               "nextSettlementDay":nextSettlementDay,
               "groupID": groupID,
               "settlementDic": ["\(userID)": false],
               "userIDArray": [userID],
               "create_at": Date().timeIntervalSince1970
           ])
           
           db.collection("userManagement").document(userID).setData([
               "joinGroupDic" : ["\(groupID)": true]
           ],merge: true)
           
           userIDArray.removeAll(where: {$0 == userID})
           
           for usersID in userIDArray{
               db.collection("userManagement").document(usersID).setData([
                   "joinGroupDic":["\(groupID)": false]
               ], merge: true)
           }
           
           activityIndicatorView.stopAnimating()
           let index = navigationController!.viewControllers.count - 3
           navigationController?.popToViewController(navigationController!.viewControllers[index], animated: true)
       }
    
}
//MARK:- Picker
extension CreateGroupViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    
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

//MARK:- CollectionDelegate

extension CreateGroupViewController:CollectionDeligate{
    
    func SendArray(selectedUserImageArray: [String], userIDArray: [String], userNameArray: [String]) {
        self.selectedUserImageArray = selectedUserImageArray
        self.userIDArray = userIDArray
        self.userNameArray = userNameArray
        collectionView.reloadData()
    }
    
}
