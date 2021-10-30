
//
//  LoginViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import FirebaseAnalytics

class LoginViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var loginTableView: UITableView!
    
    // MARK: - Variables
    var isFrommaInScreen                = true
    private var loginDictionary         = NSMutableDictionary()
    private var isSecured : Bool!       = false
    private var filedNames : NSArray {
        return self.returnFieldNames()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginTableView.estimatedRowHeight = 145
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.loginTableView.reloadData()
    }
    
    // MARK: - Button Action
    @IBAction func logInAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let errorMessage = loginValidation()
        if errorMessage.length <= 0{
            self.logInWebService()
        }else{
            ServiceUtility.showMessageHudWithMessage(errorMessage,delay:  ServiceUtility.messageDelay())
        }
    }
    
    @IBAction func sighnUP(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isFrommaInScreen
        {
            let signupvc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAccountCreateViewController) as! AccountCreateViewController
            signupvc.isFrommaInScreen = false
            self.navigationController?.pushViewController(signupvc, animated: true)
        }else
        {
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @IBAction func UnhidePassword(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            self.isSecured = false
        }else{
            sender.isSelected = true
            self.isSecured = true
        }
        self.loginTableView.reloadData()
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let signupvc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kForgotViewController) as! ForgotViewController
        self.navigationController?.pushViewController(signupvc, animated: true)
    }
    
}

// MARK: - TableView Delegate
extension LoginViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filedNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLogoCell)! as UITableViewCell
             Utility.shareUtility.updateCorenerBezierPathWith(view: cell.viewWithTag(1)!, tag: 1)
             return cell
        case 3:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLoginCell)! as UITableViewCell
             Utility.shareUtility.updateCorenerBezierPathWith(view: cell.viewWithTag(1)!, tag: 0)
             return cell
        case 4:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kSignUpCell)! as UITableViewCell
             return cell
        default:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextFldCell)! as UITableViewCell
             let textFiled = cell.viewWithTag(11) as! UITextField
            textFiled.placeholder = ((self.filedNames[indexPath.row] as! NSDictionary).value(forKey: ConstantMessage.kFieldName) as! String)
             textFiled.keyboardType = (indexPath.row == 1) ? UIKeyboardType.emailAddress : UIKeyboardType.default
             (cell.viewWithTag(12) as! UIButton).isHidden = (indexPath.row == 1) ? true : false
             textFiled.isSecureTextEntry = (indexPath.row == 1) ? false : ((self.isSecured) ? false : true)
             return cell
        }
    }
}

// MARK: - Textfield
extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if !string.canBeConverted(to: String.Encoding.ascii){
            return false
        }
        // pasting and max char
        if UIPasteboard.general.string != nil && (((UIPasteboard.general.string)?.count)! > 30) && string == (UIPasteboard.general.string)
        {
            return false
        }
        
        if  (((textField.text?.count)! > 40) && string != "")
        {
            return false
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.loginTableView)
        let textFieldIndexPath = self.loginTableView.indexPathForRow(at: pointInTable)
        switch textFieldIndexPath?.row {
        case 1:
            self.loginDictionary.setValue(textField.text!, forKey: ConstantMessage.kUserID)
        case 2:
            self.loginDictionary.setValue(textField.text!, forKey: ConstantMessage.kPassword)
        default:break
        }
    }
}

// MARK: - Web Service
extension LoginViewController {
    //MARK: get user details Webservice
    func logInWebService() {
        
        ServiceUtility.callWebService(Login_URl, parameters: returnServiceParams(), PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    DefaultsManager.share.isShowHelp = false
                    DefaultsManager.share.isShowTagHelp = false
                    DefaultsManager.share.isShowGroupHelp = false
                    let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    var authentication_key = ""
                    if dataFromServer.object(forKey:ConstantMessage.kAPIKEY) != nil
                    {
                        authentication_key = dataFromServer.object(forKey:ConstantMessage.kAPIKEY) as! String
                    }
                    DefaultsManager.share.authenticationKey = authentication_key
                    DefaultsManager.share.setUserAsLoggedIn()
                    if dataFromServer.object(forKey: ConstantMessage.kMobileNo) as! Bool == true
                    {
                        DefaultsManager.share.loginData = data
                        UserManager.shareManger.setLoginDataWith(data: DefaultsManager.share.loginData)
                         Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                          AnalyticsParameterItemID: ConstantMessage.kLogin +  "_" + "\(UserManager.shareManger.userName!)_\(UserManager.shareManger.userEmail!)",
                          AnalyticsEventSelectItem:ConstantMessage.kLogin,
                          AnalyticsParameterValue : UserManager.shareManger.userID!,
                          AnalyticsParameterItemName : ConstantMessage.kLogin
                         // AnalyticsEventScreenView:"LoginScreen"
                        ])
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kBubblesViewController) as! BubblesViewController
                         conatactManger.deleteAllRecord()
                        self.navigationController?.pushViewController(vc, animated: true)
                        if dataFromServer.object(forKey: ConstantMessage.kCountribute) as! Bool == false
                        {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantMessage.kDonationnotification), object: nil)
                        }
                    }else
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kMobileOtpViewController) as! MobileOtpViewController
                        vc.data = data
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay:  ServiceUtility.messageDelay())
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay:  ServiceUtility.messageDelay())
            }
        }
    }
     
    func returnServiceParams()-> NSMutableDictionary {
        return[ConstantMessage.kEmail:self.loginDictionary.value(forKey: ConstantMessage.kUserID) as! String,
               ConstantMessage.kPassword:self.loginDictionary.value(forKey: ConstantMessage.kPassword) as! String,
               ConstantMessage.kDeviceToken:DefaultsManager.share.deviceToken ?? "0",
               ConstantMessage.kDeviceType:ConstantMessage.kConstDeviceType]
    }
}

class SignUpCell : UITableViewCell {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension LoginViewController {
    func returnFieldNames()-> NSArray {
        return [[ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:"Email or Mobile Number (no country code)"],
                [ConstantMessage.kFieldName:"Password"],
                [ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:""]]
    }
    
    func loginValidation()-> NSString {
        if let userid = self.loginDictionary.value(forKey: ConstantMessage.kUserID) as? String,userid.count <= 0{
            return ConstantMessage.kMobileNumber
       }else if self.loginDictionary.value(forKey: ConstantMessage.kUserID) == nil{
            return ConstantMessage.kMobileNumber
        }else if let userid = self.loginDictionary.value(forKey: ConstantMessage.kPassword) as? String,userid.count <= 0{
        return ConstantMessage.kEmptyPassword
       }else if self.loginDictionary.value(forKey: ConstantMessage.kPassword) == nil{
            return ConstantMessage.kEmptyPassword
       }else if let userId = self.loginDictionary.value(forKey: ConstantMessage.kUserID) as? String,userId.count > 0,userId.trimmingCharacters(in: CharacterSet.whitespaces).count < 5{
           return ConstantMessage.kMobileNumber
       }
       return ""
    }
}


