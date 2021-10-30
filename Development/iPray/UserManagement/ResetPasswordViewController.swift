//
//  ResetPasswordViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 18/04/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class ResetPasswordViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var resetTableView: UITableView!
    
    // MARK: - Variable
    var numberOrEmail = ""
    var otp = ""
    var userId = ""
    private var isSecured : Bool! = false
    private var serviceRequestParams = NSMutableDictionary()
    private var filedNames : NSArray {
        return self.returnFieldNames()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resetTableView.estimatedRowHeight = 145
        self.serviceRequestParams = returnServiceRequestParams()
    }
    
    override func viewDidLayoutSubviews() {
        self.resetTableView.reloadData()
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
        
    @IBAction func UnhidePassword(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            self.isSecured = false
        }else{
            sender.isSelected = true
            self.isSecured = true
        }
        self.resetTableView.reloadData()
    }
    
    @IBAction func resetBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let errorMessage = resetPasswordValidation()
        if errorMessage.length <= 0{
            resetPasswordWebService()
        }else{
            ServiceUtility.showMessageHudWithMessage(errorMessage,delay: ServiceUtility.messageDelay())
        }
    }
}
    
// MARK: - TextField Delegate
extension ResetPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.canBeConverted(to: String.Encoding.ascii) {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.resetTableView)
        let textFieldIndexPath = self.resetTableView.indexPathForRow(at: pointInTable)
        switch textFieldIndexPath?.row {
        case 1:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kPassword)
        case 2:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kConfirmPass)
        default:break
        }
    }
}

// MARK: - TableView Delegate
extension ResetPasswordViewController : UITableViewDelegate, UITableViewDataSource {
    
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
            Utility.shareUtility.updateCorenerBezierPathWith(view: cell.viewWithTag(1)!, tag: 1)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLoginCell)! as UITableViewCell
            Utility.shareUtility.updateCorenerBezierPathWith(view: cell.viewWithTag(1)!, tag: 0)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextFldCell)! as UITableViewCell
            (cell.viewWithTag(11) as! UITextField).placeholder = ((self.filedNames[indexPath.row] as! NSDictionary).value(forKey: ConstantMessage.kFieldName) as! String)
           (cell.viewWithTag(12) as! UIButton).isHidden = (indexPath.row == 2) ? false : true
           (cell.viewWithTag(11) as! UITextField).isSecureTextEntry = ((indexPath.row == 2) ? ((self.isSecured) ? false : true) : false)
           return cell
        }
    }
}

// New reset
extension ResetPasswordViewController {
    //MARK: get user details Webservice
    func resetPasswordWebService() {
        ServiceUtility.callWebService(RESET_PASSWORD, parameters: self.serviceRequestParams, PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
        }
    }
}


extension ResetPasswordViewController {
    func returnFieldNames()-> NSArray {
        return [[ConstantMessage.kFieldName    : ""],
                [ConstantMessage.kFieldName    : "New Password"],
                [ConstantMessage.kFieldName    : "Confirm Password"],
                [ConstantMessage.kFieldName    : ""]]
    }
    
    func returnServiceRequestParams()-> NSMutableDictionary {
        return [ConstantMessage.kPassword:"",
                "confirmPass":"",
                ConstantMessage.kOtp:self.otp,
                ConstantMessage.kUserID:self.userId]
    }
    
    func resetPasswordValidation()-> NSString {
        if let password = self.serviceRequestParams.value(forKey: ConstantMessage.kPassword) as? String,password.count <= 0{
            return ConstantMessage.kEmptyPassword
        }else if let confirmPass = self.serviceRequestParams.value(forKey: "confirmPass") as? String,confirmPass.count <= 0{
            return ConstantMessage.kConfirmPassword
        }else if (self.serviceRequestParams.value(forKey: ConstantMessage.kPassword) as! String) !=  (self.serviceRequestParams.value(forKey: "confirmPass")  as! String){
            return ConstantMessage.kMismatchPassword
        }
        return ""
    }
}

