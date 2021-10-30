//
//  ForgotViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 18/04/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class ForgotViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var forgotTableView: UITableView!
    
    // MARK: - Variables
    private var tempUserId = ""
    private var serviceRequestParams = NSMutableDictionary()
    private var filedNames : NSArray {
        return self.returnFieldNames()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forgotTableView.estimatedRowHeight = 145
        self.serviceRequestParams = self.returnServiceRequestParams()
    }

    
    override func viewDidLayoutSubviews() {
        self.forgotTableView.reloadData()
        getcoutrycodedefault()
    }
    
    func getcoutrycodedefault() {
        let locale = NSLocale.current as NSLocale
        //NSLocaleCountryCode
        let countryCode: String = (locale.object(forKey: .countryCode) as? String)!
        let identifier: String = NSLocale.localeIdentifier(fromComponents: [ NSLocale.Key.countryCode.rawValue : countryCode ])
        let country: String = locale.displayName(forKey: .identifier, value: identifier)!
        var phoneCode: String = Reachability.getCountryCallingCode(country)
        if phoneCode == ""
        {
            phoneCode = "+1"
        }
        let cell = self.forgotTableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let textField = cell?.viewWithTag(13) as! UITextField
        textField.text = phoneCode
        (cell!.viewWithTag(12) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
        self.serviceRequestParams.setValue(phoneCode, forKey: ConstantMessage.kIsdCode)
    }
    
    // MARK: - Button Action
    @IBAction func backBtnAction(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kCountryListViewController) as! CountryListViewController
        vc.deligate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func forgotBtnAction(_ sender: UIButton) {
       self.view.endEditing(true)
       let errorMessage = ForgotValidation()
       if errorMessage.length <= 0{
            forgotPasswordWebService()
       }else{
            ServiceUtility.showMessageHudWithMessage(errorMessage,delay: ServiceUtility.messageDelay())
       }
    }
}

extension ForgotViewController:countryList {
    func getCountryList(name: String) {
       let cell = self.forgotTableView.cellForRow(at: IndexPath(row: 1, section: 0))
       let textField = cell?.viewWithTag(13) as! UITextField
       textField.text = name
       (cell!.viewWithTag(12) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
    }
}

// MARK: - TableView Delegate
extension ForgotViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filedNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLogoCell)! as UITableViewCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextFldCell)! as UITableViewCell
            (cell.viewWithTag(13) as! UITextField).placeholder = ((self.filedNames[indexPath.row] as! NSDictionary).value(forKey: ConstantMessage.kFieldName) as! String)
            return cell
        }
    }
}

// New reset
extension ForgotViewController {
    //MARK: get user details Webservice
    func VerifyOtpWebService(otp : String) {
        ServiceUtility.callWebService(CHECK_OTP_URl, parameters: self.returnVerifiyOTPServiceRequestParams(otp: otp), PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    let resetvc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kResetPasswordViewController) as! ResetPasswordViewController
                    resetvc.numberOrEmail = self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as!String
                    resetvc.userId = self.tempUserId
                    resetvc.otp = otp
                    self.navigationController?.pushViewController(resetvc, animated: true)
                    
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                    self.setUpOTPView()
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
            
        }
    }
    
    //MARK: get user details Webservice
    func forgotPasswordWebService() {
        ServiceUtility.callWebService(FORGOT_PASSWORD_URl, parameters: self.serviceRequestParams, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    self.tempUserId = data.object(forKey: ConstantMessage.kUserID) as! String
                    DispatchQueue.main.async {
                        self.setUpOTPView()
                    }
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
    
    //MARK: get user details Webservice
    func ResentOtpWebService() {
        ServiceUtility.callWebService(RESENT_OTP_URl, parameters: self.resendOTPServiceRequestParams(), PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.setUpOTPView()
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                    self.setUpOTPView()
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
}

// MARK: - TextField Delegate
extension ForgotViewController: UITextFieldDelegate {
    
    func setUpOTPView() {
        let actionSheetController: UIAlertController = UIAlertController(title: ConstantMessage.kSignupCode, message: ConstantMessage.kTextMessage, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title:ConstantMessage.kCancel, style: .default) { action -> Void in
                   //Do some stuff
        }
        
        let resentOtp: UIAlertAction = UIAlertAction(title:ConstantMessage.kResendCode, style: .default) { action -> Void in
            //Do some stuff
            self.ResentOtpWebService()
        }
               
        //Create and add the Cancel action
        let nextAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kSubmit, style: .cancel) { action -> Void in
            if let field : UITextField = actionSheetController.textFields?[0]
            {
                let text : String = field.text!
                if text.count == 4
                {
                    self.VerifyOtpWebService(otp: text)
                    actionSheetController.dismiss(animated: true, completion: nil)
                }else
                {
                    if text.count == 0
                    {
                        ServiceUtility.showMessageHudWithMessage(ConstantMessage.kForgotResetCode as NSString, delay: ConstantMessage.kDelay)
                    }else
                    {
                        ServiceUtility.showMessageHudWithMessage(ConstantMessage.kValidResetCode as NSString, delay: ConstantMessage.kDelay)
                    }
                    self.setUpOTPView()
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.kForgotResetCode as NSString, delay: ConstantMessage.kDelay)
                self.setUpOTPView()
            }
        }
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
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
    
    /**
     *  Keyboard Return Key Action
     */
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.canBeConverted(to: String.Encoding.ascii){
            return false
        }
        
        if UIPasteboard.general.string != nil && (((UIPasteboard.general.string)?.count)! > 30) && string == (UIPasteboard.general.string)
        {
            return false
        }
        let maxLength = 14
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kEmail)
    }
}

extension ForgotViewController {
    
    func returnFieldNames()-> NSArray {
        return [[ConstantMessage.kFieldName    : ""],
                [ConstantMessage.kFieldName    : "Mobile Number"]
               ]
    }
    
    func returnServiceRequestParams()-> NSMutableDictionary {
        return [ConstantMessage.kEmail   : "",
                ConstantMessage.kIsdCode : ""]
    }
    
    func returnVerifiyOTPServiceRequestParams(otp : String)-> NSMutableDictionary {
        return [ConstantMessage.kMobileNo  : self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as! String,
                ConstantMessage.kIsdCode   : self.serviceRequestParams.value(forKey: ConstantMessage.kIsdCode) as! String,
                ConstantMessage.kOtp       : otp,
                ConstantMessage.kUserID:self.tempUserId]
    }
    
    func resendOTPServiceRequestParams()-> NSMutableDictionary {
        return [ConstantMessage.kMobileNo : self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as! String,
                ConstantMessage.kIsdCode:self.serviceRequestParams.value(forKey: ConstantMessage.kIsdCode) as! String,
                ConstantMessage.kUserID:self.tempUserId]
    }
    
    func ForgotValidation()-> NSString {
       if let mobileNo = self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as? String,mobileNo.count <= 0{
           return ConstantMessage.kEmptyMobileNumber
       }else if let mobileNo = self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as? String,mobileNo.count < 5{
           return ConstantMessage.kValidContact
       }
       return ""
    }
}


