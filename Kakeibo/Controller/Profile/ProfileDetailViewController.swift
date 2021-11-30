//
//  ProfileDetailViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import SDWebImage
import CropViewController
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileDetailViewController: UIViewController{
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var profileImage = UIImage()
    let user = Auth.auth().currentUser

    var nameArray = ["名前","メールアドレス","パスワード"]
    var dataNameArray = ["userName","email","password"]
    var userInfoArray = [String]()
    var sendString = String()
    var sendData = String()
    var userID = String()
    var alertModel = AlertModel()
    var sendDBModel = SendDBModel()
    var editDBModel = EditDBModel()
    var db = Firestore.firestore()
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var profileImageData:Data?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        title = "プロフィール設定"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        
        profileImageView.image = profileImage
        profileImageView.layer.cornerRadius = 120
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView() 
        
        sendDBModel.sendOKDelegate = self
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let ProfileConfigurationVC = segue.destination as! ProfileConfigurationViewController
        ProfileConfigurationVC.delivery = self
        ProfileConfigurationVC.receiveTitle = sendString
        ProfileConfigurationVC.receiveDataName = sendData
        ProfileConfigurationVC.userID = userID
        ProfileConfigurationVC.userInfoArray = userInfoArray
    }
    
    @IBAction func profileImageView(_ sender: UITapGestureRecognizer) {
        alertModel.satsueiAlert(viewController: self)
    }

    
}

// MARK: - TableView
extension ProfileDetailViewController:UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let loadLabel = cell.contentView.viewWithTag(2) as! UILabel
        var passwaordString = String()
        
        nameLabel.text = nameArray[indexPath.row]
        
        if indexPath.row == 2{
            userInfoArray[indexPath.row].forEach{string in
                passwaordString = passwaordString + "●"
                print(string)
            }
            loadLabel.text = passwaordString
            print(passwaordString)
        }else{
            loadLabel.text = userInfoArray[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendString = nameArray[indexPath.row]
        sendData = dataNameArray[indexPath.row]
        alertModel.passWordAlert(viewController: self, userInfo: userInfoArray)
    }
    
    
}

// MARK: - SendOKDelegate
extension ProfileDetailViewController:SendOKDelegate{
    
    func sendImage_OK(url: String, storagePath: String?) {
         db.collection("userManagement").document(userID).updateData(["profileImage" : url])
        
         activityIndicatorView.stopAnimating()
         navigationController?.popViewController(animated: true)
     }
    
}

// MARK: - ImagePicker
extension ProfileDetailViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] as? UIImage != nil{
            let pickerImage = info[.originalImage] as! UIImage
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
            
            cropController.delegate = self
            cropController.customAspectRatio = profileImageView.frame.size
            cropController.cropView.cropBoxResizeEnabled = false
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        activityIndicatorView.startAnimating()
        self.profileImageView.image = image
        profileImageData = image.jpegData(compressionQuality: 1.0)!
        let profileStoragePath = UserDefaults.standard.object(forKey: "profileStoragePath") as! String
        sendDBModel.sendChangeProfileImage(data: profileImageData!, activityIndicatorView: activityIndicatorView,profileStoragePath: profileStoragePath)
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - profileConfigurationVCDelegate

extension ProfileDetailViewController: profileConfigurationVCDelegate{
    
    func delivery(value: [String]) {
        userInfoArray = value
        tableView.reloadData()
    }
    
}
