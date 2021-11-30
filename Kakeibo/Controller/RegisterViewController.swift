//
//  RegisterViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Firebase
import FirebaseFirestore
import CropViewController

class RegisterViewController: UIViewController,LoginOKDelegate,SendOKDelegate {
    
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkTextField: UITextField!
    @IBOutlet weak var errorShowLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var loginModel = LoginModel()
    var userID = String()
    var myEmail = String()
    var sendDBModel = SendDBModel()
    var alertModel = AlertModel()
    var db = Firestore.firestore()
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        
        registerButton.layer.cornerRadius = 5
        profileImageView.layer.cornerRadius = 108
        loginModel.loginOKDelegate = self
        sendDBModel.sendOKDelegate = self
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
    }
    
    @IBAction func registerButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        loginModel.register(email: emailTextField.text!, password: passwordTextField.text!, check: checkTextField.text!, errorShowLabel: errorShowLabel,activityIndicatorView: activityIndicatorView)
    }
    
    func registerOK(userID: String) {
        self.userID = userID
        
        let data = profileImageView.image?.jpegData(compressionQuality: 1.0)
        sendDBModel.sendProfileImage(data: data!, activityIndicatorView: activityIndicatorView)
    }
    
    func sendImage_OK(url: String, storagePath: String?) {
        if url.isEmpty != true{
            db.collection("userManagement").document(userID).setData([
                "email" : emailTextField.text!,
                "userName": userNameTextField.text!,
                "password": passwordTextField.text!,
                "profileImage" : url,
                "userID" : userID,
                "profileStoragePath" : storagePath!
            ])
            userNameTextField.text = ""
            emailTextField.text = ""
            passwordTextField.text = ""
            checkTextField.text = ""
            activityIndicatorView.stopAnimating()
            performSegue(withIdentifier: "ProfileVC", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let ProfileVC = segue.destination as! ProfileViewController
        ProfileVC.userID = userID
        UserDefaults.standard.setValue(userID, forKey: "userID")
    }
    
    @IBAction func profileImageView(_ sender: UITapGestureRecognizer) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    
}

//MARK:- ImagePicker
extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate{
    
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
        self.profileImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
}

//MARK:- UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
