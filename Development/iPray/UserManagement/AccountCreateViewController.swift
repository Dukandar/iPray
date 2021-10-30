//
//  AccountCreateViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
class AccountCreateViewController: UIViewController {
    
    // MARK: - Variables & Button
    @IBOutlet weak var accountCreateTableView: UITableView!
    
    // MARK: - Variables
    var isFrommaInScreen = true
    private var isFromISD = false
    private var tempAccessKey = ""
    private var tempUserId = ""
    private var isSecured : Bool = false
    private var serviceRequestParams = NSMutableDictionary()
    private var signupCode  : NSString = ConstantMessage.kOtpSignupCode as NSString
    private var validSignupCode : NSString = ConstantMessage.kValidOtpSignupCode as NSString
    private var filedNames : NSArray {
        return self.returnFieldNames()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountCreateTableView.estimatedRowHeight = 145
        self.serviceRequestParams = self.returnServiceRequestParms()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.isFromISD = !self.isFromISD
        self.tempUserId = ""
        self.tempAccessKey = ""
    }
    
    override func viewDidLayoutSubviews() {
        self.accountCreateTableView.reloadData()
        getcoutrycodedefault()
    }
    
    // MARK: - Button Action
    @IBAction func createAccountBtnTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let errorMessage = signUpValidation()
        if errorMessage.length <= 0{
             createAccountWebService()
        }else{
            ServiceUtility.showMessageHudWithMessage(errorMessage,delay: ServiceUtility.messageDelay())
        }
    }
    
    @IBAction func logInAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if isFrommaInScreen
        {
            let login = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kLoginViewController) as! LoginViewController
            login.isFrommaInScreen = false
            self.navigationController?.pushViewController(login, animated: true)
        }else
        {
            self.navigationController?.popViewController(animated: true)
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
        self.accountCreateTableView.reloadData()
    }
    
    @IBAction func selectCountryCode(_ sender: UIButton) {
        self.isFromISD = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kCountryListViewController) as! CountryListViewController
        vc.deligate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backButtonPress(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - TableView Delegate
extension AccountCreateViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filedNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        let placeHolder = ((self.filedNames[indexPath.row] as! NSDictionary).value(forKey: ConstantMessage.kFieldName) as! String)
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLogoCell)! as UITableViewCell
             Utility.shareUtility.updateCorenerBezierPathWith(view: cell.viewWithTag(1)!, tag: 1)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kMobileCell)! as UITableViewCell
            let textFiled = cell.viewWithTag(32) as! UITextField
            textFiled.placeholder = placeHolder
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kCreateAccountCell)! as UITableViewCell
             Utility.shareUtility.updateCorenerBezierPathWith(view: cell.viewWithTag(1)!, tag: 0)
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLoginCell)! as UITableViewCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextFld)! as UITableViewCell
            let textFiled = cell.viewWithTag(21) as! UITextField
            textFiled.placeholder = placeHolder
            (cell.viewWithTag(22) as! UIButton).isHidden = (indexPath.row == 4) ? false : true
            textFiled.isSecureTextEntry = ((indexPath.row == 4) ? ((self.isSecured) ? false : true) : false)
        }
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension AccountCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.accountCreateTableView)
        let textFieldIndexPath = self.accountCreateTableView.indexPathForRow(at: pointInTable)
        if textFieldIndexPath?.row == 2{
            let maxLength = 14
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        if !string.canBeConverted(to: String.Encoding.ascii){
            return false
        }
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let pointInTable = textField.convert(textField.bounds.origin, to: self.accountCreateTableView)
        let textFieldIndexPath = self.accountCreateTableView.indexPathForRow(at: pointInTable)
        switch textFieldIndexPath?.row {
        case 1:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kFiledFullName)
        case 2:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kMobileNo)
        case 3:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kEmail)
        case 4:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kPassword)
        default:break
        }
        
    }
}

// MARK: - Web Service
extension AccountCreateViewController {
    //MARK: Create Account Webservice
    func createAccountWebService() {
        ServiceUtility.callWebService(CREATE_ACCOUNT_URl, parameters: self.serviceRequestParams, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    DefaultsManager.share.isShowHelp = false
                    DefaultsManager.share.isShowTagHelp = false
                    DefaultsManager.share.isShowGroupHelp = false
                    // change here
                    let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    self.tempAccessKey = dataFromServer.object(forKey:ConstantMessage.kAPIKEY) as! String
                    self.tempUserId = data.object(forKey: ConstantMessage.kUserID) as! String
                    self.setUpOTPView()
                }else
                {
                    self.accountCreateTableView.reloadData()
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay:  ServiceUtility.messageDelay())
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay:  ServiceUtility.messageDelay())
            }
        }
    }
}

//MARK:- OTP Action and Functionality
extension AccountCreateViewController{
    func setUpOTPView() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: ConstantMessage.kSignupCode, message: ConstantMessage.kTextMessage, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kConfirm, style: .cancel) { action -> Void in
        }
          
        let resentOtp: UIAlertAction = UIAlertAction(title: ConstantMessage.kResendCode, style: .default) { action -> Void in
                self.resendOtpWebService()
        }
        let nextAction: UIAlertAction = UIAlertAction(title:ConstantMessage.kSubmitBtn, style: .default) { action -> Void in
              if let field : UITextField = actionSheetController.textFields?[0]
              {
                  let text : String = field.text!
                  if text.count == 4
                  {
                      self.VerifyOtp(otp: text)
                      actionSheetController.dismiss(animated: true, completion: nil)
                    
                  }else
                  {
                      if text.count == 0
                      {
                        ServiceUtility.showMessageHudWithMessage(self.signupCode, delay:  ServiceUtility.messageDelay())
                      }else
                      {
                        ServiceUtility.showMessageHudWithMessage(self.validSignupCode, delay:  ServiceUtility.messageDelay())
                      }
                      self.setUpOTPView()
                  }
              }
              else
              {
                  ServiceUtility.showMessageHudWithMessage(self.signupCode, delay:  ServiceUtility.messageDelay())
                  self.setUpOTPView()
              }
          }
          //Add a text field
          actionSheetController.addTextField { textField -> Void in
              textField.textColor = UIColor.black
              textField.delegate = self
              textField.tag = 51
              textField.keyboardType = .numberPad
              textField.placeholder = "####"
              textField.textAlignment = .center
          }
          actionSheetController.addAction(nextAction)
          actionSheetController.addAction(cancelAction)
          actionSheetController.addAction(resentOtp)
          self.present(actionSheetController, animated: true, completion: nil)
      }
    //MARK: Verify Webservice
    func VerifyOtp(otp : String) {
        ServiceUtility.callWebService(CHECK_OTP_URl, parameters: self.returnOTPServiceRequestParmsWith(otp: otp), PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    UserDefaults.standard.synchronize()
                    DefaultsManager.share.authenticationKey = self.tempAccessKey
                    DefaultsManager.share.loginData = data
                    UserManager.shareManger.setLoginDataWith(data: DefaultsManager.share.loginData)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kUploadImageViewController) as! UploadImageViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ServiceUtility.messageDelay())
                    self.setUpOTPView()
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ServiceUtility.messageDelay())
            }
        }
    }
    
    //MARK: Resend OTP Webservice
    func resendOtpWebService() {
        ServiceUtility.callWebService(RESENT_OTP_URl, parameters: self.returnResendOTPServiceRequestParms(), PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.setUpOTPView()
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ServiceUtility.messageDelay())
                    self.setUpOTPView()
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ServiceUtility.messageDelay())
            }
        }
    }
}

// MARK: - Country List
extension AccountCreateViewController : countryList {
    func getCountryList(name: String) {
       let cell = self.accountCreateTableView.cellForRow(at: IndexPath(row: 2, section: 0))
       let textField = cell?.viewWithTag(32) as! UITextField
       textField.text = name
        self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kIsdCode)
       (cell?.viewWithTag(31) as! UIImageView).isHidden = (name == "+1") ?  false : true
    }
    func getcoutrycodedefault() {
        let locale = NSLocale.current as NSLocale
        let countryCode: String = (locale.object(forKey: .countryCode) as? String)!
        let identifier: String = NSLocale.localeIdentifier(fromComponents: [ NSLocale.Key.countryCode.rawValue : countryCode ])
        let country: String = locale.displayName(forKey: .identifier, value: identifier)!
        var phoneCode: String = Reachability.getCountryCallingCode(country)
        if phoneCode == ""
        {
            phoneCode = "+1"
        }
        let cell = self.accountCreateTableView.cellForRow(at: IndexPath(row: 2, section: 0))
        let textField = cell?.viewWithTag(32) as! UITextField
        textField.text = phoneCode
        self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kIsdCode)
        (cell?.viewWithTag(31) as! UIImageView).isHidden = (phoneCode == "+1") ?  false : true
    }
}

//MARK:- Validation and Service request params
extension AccountCreateViewController {
    
    func signUpValidation()-> NSString {
        if let fullName = self.serviceRequestParams.value(forKey: ConstantMessage.kFiledFullName) as? String,fullName.count <= 0{
            return ConstantMessage.kFullName
        }else if let mobileNo = self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as? String,mobileNo.count <= 0{
            return ConstantMessage.kEmptyMobileNumber
        }else if let mobileNo = self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as? String,mobileNo.count < 5{
            return ConstantMessage.kValidContact
        }else if let email = self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as? String,email.count <= 0{
            return ConstantMessage.kEmptyEmail
        }else if let email = self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as? String,email.count > 0,!(commonValidations.isValidEmailid((email.trimmingCharacters(in: CharacterSet.whitespaces)))){
            return ConstantMessage.kValidEmail
        }else if let password = self.serviceRequestParams.value(forKey: ConstantMessage.kPassword) as? String,password.count <= 0{
            return ConstantMessage.kEmptyPassword
        }else if let password = self.serviceRequestParams.value(forKey: ConstantMessage.kPassword) as? String,password.count > 0,!(commonValidations.isalphanumericpassword((password.trimmingCharacters(in: CharacterSet.whitespaces)))){
            return ConstantMessage.kValidPassword
        }
        return ""
    }
    
    func returnResendOTPServiceRequestParms()-> NSMutableDictionary {
        return [ConstantMessage.kMobileNo  : self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as! String,
                ConstantMessage.kIsdCode   : self.serviceRequestParams.value(forKey: ConstantMessage.kIsdCode) as! String,
                ConstantMessage.kUserID    : self.tempUserId]
    }
    
    func returnOTPServiceRequestParmsWith(otp : String)-> NSMutableDictionary {
        return [ConstantMessage.kMobileNo  : self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as! String,
                ConstantMessage.kIsdCode   : self.serviceRequestParams.value(forKey: ConstantMessage.kIsdCode) as! String,
                ConstantMessage.kOtp       : otp,
                ConstantMessage.kUserID    : self.tempUserId]
    }
    
    func returnServiceRequestParms()-> NSMutableDictionary {
        return [ConstantMessage.kFiledFullName       : "",
                ConstantMessage.kEmail               :"",
                ConstantMessage.kMobileNo            :"",
                ConstantMessage.kPassword            :"",
                ConstantMessage.kIsdCode             :"",
                ConstantMessage.kDeviceType          :"1",
                ConstantMessage.kDeviceToken         :DefaultsManager.share.deviceToken ?? "0"]
    }
    
    func returnFieldNames()-> NSArray {
        return [[ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:"Full Name"],
                [ConstantMessage.kFieldName:"Mobile Number"],
                [ConstantMessage.kFieldName:"Email Address"],
                [ConstantMessage.kFieldName:"Password"],
                [ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:""]]
    }
}

