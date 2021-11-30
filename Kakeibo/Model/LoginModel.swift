//
//  LoginModel.swift
//  KakeiboApp_LoginTest
//
//  Created by 山口誠士 on 2021/10/17.
//
import Foundation
import FirebaseAuth
import UIKit

@objc protocol LoginOKDelegate {
    
    @objc optional func loginOK(userID:String)
    @objc optional func registerOK(userID:String)
    @objc optional func upDateOK(value: String)
    @objc optional func reauthenticationOK(check:Int)
    
}

class LoginModel{
    

    let auth = Auth.auth()
    var loginOKDelegate:LoginOKDelegate?

    
    func login(emailTextField:UITextField,passwordTextField:UITextField,errorShowLabel:UILabel,activityIndicatorView:UIActivityIndicatorView){
        
        if emailTextField.text == ""{
            
            activityIndicatorView.stopAnimating()
            errorShowLabel.text = "メールアドレスを入力してください"
            
        }else if passwordTextField.text == ""{
            
            activityIndicatorView.stopAnimating()
            errorShowLabel.text = "パスワードを入力してください"
            
        }else{
            auth.signIn(withEmail: emailTextField.text! , password: passwordTextField.text!) { result, error in
                
                if error != nil{
                    
                    activityIndicatorView.stopAnimating()
                    self.showError(error, showLabel: errorShowLabel)
                    
                }else{
                    if let user = result?.user.uid{
                        let userID = String(user)
                        print(userID)
                        self.loginOKDelegate?.loginOK!(userID: userID)
                        emailTextField.text = ""
                        passwordTextField.text = ""
                        errorShowLabel.text = ""
                        
                    }
                }
            }
            
            
        }
        
     
    }
    
    func register(email:String,password:String,check:String,errorShowLabel:UILabel,activityIndicatorView:UIActivityIndicatorView){
        
        if email == ""{
            activityIndicatorView.stopAnimating()
            errorShowLabel.text = "メールアドレスを入力してください"
            
        }else if password == ""{
            activityIndicatorView.stopAnimating()
            errorShowLabel.text = "パスワードを入力してください"
            
        }else if password != check{
            activityIndicatorView.stopAnimating()
            errorShowLabel.text = "パスワードが違います"
            
        }else{
            auth.createUser(withEmail: email, password: password) { result, error in
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    self.showError(error, showLabel: errorShowLabel)
                    
                }else{
                    if let user = result?.user.uid{
                        let userID = String(user)
                        print(userID)
                        self.loginOKDelegate?.registerOK!(userID: userID)
                        errorShowLabel.text = ""
                    }
                }
            }
        }
        
        
    }
    
    
    func updateUserDataOfEmail(emailTextField:UITextField, errorShowLabel:UILabel){
        
        if auth.currentUser == nil{
            print("***updateUserOfEmail***")
            print("currentUserがnilです")
            
        }
        
        auth.currentUser?.updateEmail(to: emailTextField.text!, completion: { [self] error in
                if error != nil{
                    print(error.debugDescription)
                    self.showError(error, showLabel: errorShowLabel)
                }else{
                    errorShowLabel.text = "メールアドレスを変更しました"
                    loginOKDelegate?.upDateOK?(value: emailTextField.text!)
                }
            })
        }
    
    
    func updateUserDataOfPassword(passwordTextField:UITextField, errorShowLabel:UILabel){
        auth.currentUser?.updatePassword(to: passwordTextField.text!, completion: { [self] error in
                if error != nil{
                    self.showError(error, showLabel: errorShowLabel)
                }else{
                    errorShowLabel.text = "パスワードを変更しました"
                    loginOKDelegate?.upDateOK?(value: passwordTextField.text!)
                }
            })
        }
    
    func showError(_ errorOrNil: Error?,showLabel:UILabel){
        
        guard let error = errorOrNil else { return }
        let message = errorMessage(of: error)
        
        showLabel.text = message
        
    }
    
    func reauthentication(viewController:UIViewController, userInfoArray: [String]){
        let user = auth.currentUser
        let email = userInfoArray[1]
        let password = userInfoArray[2]
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential, completion: { result, error in
            if error != nil{
                print(error.debugDescription)
                return
            }else{
                
                viewController.performSegue(withIdentifier: "ProfileConfigurationVC", sender: nil)
                
            }
        })
    }
    
    func errorMessage(of error:Error) -> String{
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        
        switch errcd {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        case .weakPassword: message = "パスワードが脆弱すぎます"
        default: break
        }
        return message
        
    }
    
    
    
}
