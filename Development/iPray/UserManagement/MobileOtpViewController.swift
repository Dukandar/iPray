//
//  MobileOtpViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 18/04/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class MobileOtpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mobileOtpTableView: UITableView!
    
    // MARK: - Variables
    var data = NSDictionary()
    private var serviceRequestParams = NSMutableDictionary()
    private var filedNames : NSArray {
        return self.returnFieldNames()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mobileOtpTableView.estimatedRowHeight = 145
        self.serviceRequestParams = self.returnMobileServiceRequestParams()
        self.mobileOtpTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.mobileOtpTableView.reloadData()
        updateValue()
    }
    
    func updateValue() {
        if let mobileNumber = data.value(forKey: ConstantMessage.kMNumber){
            let countryCode = data.value(forKey: ConstantMessage.kCountryCode) ?? ""
            let cell = self.mobileOtpTableView.cellForRow(at: IndexPath(row: 1, section: 0))
            let textField = cell?.viewWithTag(13) as! UITextField
            textField.text = (countryCode as! String)
            (cell!.viewWithTag(12) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
            self.serviceRequestParams.setValue(mobileNumber, forKey: ConstantMessage.kMobileNo)
            self.serviceRequestParams.setValue(countryCode, forKey: ConstantMessage.kIsdCode)
        }
        getcoutrycodedefault()
        self.SendMobileNumberWebService()
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
       let cell = self.mobileOtpTableView.cellForRow(at: IndexPath(row: 1, section: 0))
       let textField = cell?.viewWithTag(13) as! UITextField
       textField.text = phoneCode
       (cell!.viewWithTag(12) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
       self.serviceRequestParams.setValue(phoneCode, forKey: ConstantMessage.kIsdCode)
    }
    
    //MARK:- IBAction
    @IBAction func backBtnCliked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectCountryCode(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kCountryListViewController) as! CountryListViewController
        vc.deligate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sendOtpBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let errorMessage = OTPValidation()
        if errorMessage.length <= 0{
            SendMobileNumberWebService()
        }else{
            ServiceUtility.showMessageHudWithMessage(errorMessage,delay: ServiceUtility.messageDelay())
        }
    }
}

// MARK: - TextField
extension MobileOtpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.tag == 51) && ((textField.text?.count)! > 6 && string != "")
        {
            return false
        }
        
        if !string.canBeConverted(to: String.Encoding.ascii){
            return false
        }
        
        if UIPasteboard.general.string != nil && (((UIPasteboard.general.string)?.count)! > 20) && string == (UIPasteboard.general.string)
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
        self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kMobileNo)
    }
}

// MARK: - TableView Delegate
extension MobileOtpViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filedNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
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

extension MobileOtpViewController:countryList {
    
    func getCountryList(name: String) {
        let cell = self.mobileOtpTableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let textField = cell?.viewWithTag(13) as! UITextField
        textField.text = name
        (cell!.viewWithTag(12) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
    }
    
}
// MARK: - Web Service
extension MobileOtpViewController {
    //MARK: get user details Webservice
    func SendMobileNumberWebService() {
        ServiceUtility.callWebService(UPDATE_MOBILE_URl, parameters: self.serviceRequestParams, PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.setUpOTPView()
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
    
    //MARK: get user details Webservice
    func SendOtpWebService(otp : String) {
        ServiceUtility.callWebService(CHECK_OTP_URl, parameters: self.returnOTPServiceRequestParamsWith(otp: otp), PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    DefaultsManager.share.loginData = self.data
                    UserManager.shareManger.setLoginDataWith(data: DefaultsManager.share.loginData)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kUploadImageViewController) as! UploadImageViewController
                    self.navigationController?.pushViewController(vc, animated: true)
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
    func ResentOtpWebService() {
        ServiceUtility.callWebService(RESENT_OTP_URl, parameters: self.returnResendOTPServiceRequestParams(), PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
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

extension MobileOtpViewController {
    func setUpOTPView() {
        let actionSheetController: UIAlertController = UIAlertController(title: ConstantMessage.kSignupCode, message: ConstantMessage.kTextMessage, preferredStyle: .alert)
          //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kConfirm, style: .cancel) { action -> Void in
              //Do some stuff
        }
        let resentOtp: UIAlertAction = UIAlertAction(title:ConstantMessage.kResendCode, style: .default) { action -> Void in
              //Do some stuff
              self.ResentOtpWebService()
        }
        let nextAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kSubmit, style: .default) { action -> Void in
            if let field : UITextField = actionSheetController.textFields?[0]
              {
                  let text : String = field.text!
                  if text.count == 4
                  {
                        self.SendOtpWebService(otp: text)
                        actionSheetController.dismiss(animated: true, completion: nil)
                  }else
                  {
                      if text.count == 0
                      {
                        ServiceUtility.showMessageHudWithMessage(ConstantMessage.kOtpSignupCode as NSString, delay:  ServiceUtility.messageDelay())
                      }else
                      {
                        ServiceUtility.showMessageHudWithMessage(ConstantMessage.kValidOtpSignupCode as NSString, delay:  ServiceUtility.messageDelay())
                      }
                      self.setUpOTPView()
                  }
              }
              else
              {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.kOtpSignupCode as NSString, delay:  ServiceUtility.messageDelay())
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
}

extension MobileOtpViewController {
    func returnFieldNames()-> NSArray{
        return [[ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:"Mobile Number"]
               ]
    }
    
    func returnMobileServiceRequestParams()-> NSMutableDictionary {
        return[ConstantMessage.kMobileNo   : "",
               ConstantMessage.kIsdCode    : "",
               ConstantMessage.kUserID     : data.value(forKey: ConstantMessage.kUserID) ?? ""]
    }
    
    func returnOTPServiceRequestParamsWith(otp : String)-> NSMutableDictionary {
        return[ConstantMessage.kMobileNo   : self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as! String,
               ConstantMessage.kUserID     : data.value(forKey: ConstantMessage.kUserID) ?? "",
               ConstantMessage.kIsdCode    : self.serviceRequestParams.value(forKey: ConstantMessage.kIsdCode) as! String,
               ConstantMessage.kOtp        :otp]
    }
    
    func returnResendOTPServiceRequestParams()->NSMutableDictionary {
        return [ConstantMessage.kMobileNo  : self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as! String,
                ConstantMessage.kIsdCode   : self.serviceRequestParams.value(forKey: ConstantMessage.kIsdCode) as! String,]
    }
    
    func OTPValidation()-> NSString {
        if let mobileNo = self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as? String,mobileNo.count <= 0{
            return ConstantMessage.kEmptyMobileNumber
        }else if let mobileNo = self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as? String,mobileNo.count < 5{
            return ConstantMessage.kValidContact
        }
        return ""
    }
}

