//
//  AddNewContactViewController.swift
//  iPray
//
//  Created by zeba on 30/03/19.
//  Copyright © 2019 TrivialWorks. All rights reserved.
//

import UIKit

protocol AddNewContactDelegate {
    func referesgListAfterAdd(contactList : NSArray)
    func sharePrayerWithfriends()
    func updateseletedArrayList(contactList : NSArray)
}
class AddNewContactViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var nameTextFld: UITextField!
    @IBOutlet weak var mobileNoTextFld: UITextField!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var usFlagImgView: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    
    // MARK: - Variables
    var mobileNumberArray = NSMutableArray()
    var isFlag : Bool = true
    var countryCodeBtnText : String = ""
    var delegate : AddNewContactDelegate!
    var btnName = ConstantMessage.kADD
    var isTag = true
    var SharePrayerID = ""
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBtn.setTitle(ConstantMessage.kADD, for: .normal)
        getcoutrycodedefault()
    }
    
    override func viewDidLayoutSubviews() {
        popView.layer.cornerRadius=18
        nameView.layer.cornerRadius=20
        mobileNumberView.layer.cornerRadius=20
        addBtnView.layer.cornerRadius=20
        addBtnView.layer.borderWidth=1
        addBtnView.layer.borderColor=UIColor(red: 254.0/255.0, green: 221.0/255.0, blue: 172.0/255.0, alpha: 1).cgColor
        
    }
    
    // MARK: - Button Action
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func addContactBtnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if (nameTextFld.text)!.trimmingCharacters(in: CharacterSet.whitespaces) == "" && (mobileNoTextFld.text )!.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.EmptyForm,delay: ConstantMessage.kDelay)
            return
        }else if (nameTextFld.text)!.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.EmptyName,delay: ConstantMessage.kDelay)
            return
        }else if (mobileNoTextFld.text)!.trimmingCharacters(in: CharacterSet.whitespaces) == ""{
            
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.kEmptyMobileNumber,delay: ConstantMessage.kDelay)
            return
        }else if (((mobileNoTextFld.text)!.count) < 5 ){
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.kValidContact,delay: ConstantMessage.kDelay)
            return
        }
        else if (countryCodeTextField.text)!.trimmingCharacters(in: CharacterSet.whitespaces)==""
        {
            ServiceUtility.showMessageHudWithMessage("\(ConstantMessage.kSelectCountryCode)" as NSString,delay: ConstantMessage.kDelay)
            return
        }else{
            let mobNo = (mobileNoTextFld.text)!.trimmingCharacters(in: CharacterSet.whitespaces)
            let countryCode = (countryCodeTextField.text)!.trimmingCharacters(in: CharacterSet.whitespaces)
            let finalContact = countryCode + mobNo
            if UserManager.shareManger.contact != nil
            {
                let contact = UserManager.shareManger.contact!
                if finalContact == contact{
                    ServiceUtility.showMessageHudWithMessage("\(ConstantMessage.kAddYourNmuber)" as NSString,delay: ConstantMessage.kDelay)
                    return
                }
            }
            addContactWebServices()
        }
    }
    
    @IBAction func selectCountryCodeBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kCountryListViewController) as! CountryListViewController
        vc.deligate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Get Country Code
    func getcoutrycodedefault()
    {
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
        if phoneCode == "+1"
        {
            usFlagImgView.isHidden = false
        }else
        {
            usFlagImgView.isHidden = true
        }
        self.countryCodeTextField.text = phoneCode
    }
}

// MARK: - TextField Delegate
extension AddNewContactViewController : UITextFieldDelegate, countryList{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getCountryList(name: String) {
        
        self.countryCodeTextField.text = "  \(name)"
        
        if name == "+1"
        {
            usFlagImgView.isHidden = false
        }else
        {
            usFlagImgView.isHidden = true
        }
    }
}

// MARK: - Web Service
extension AddNewContactViewController{
    func addContactWebServices() {
        let modifiedNo = countryCodeTextField.text! + mobileNoTextFld.text!
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(modifiedNo, forKey: ConstantMessage.kMobileNo)
        perameter.setValue(modifiedNo, forKey: ConstantMessage.kModifiedNo)
        perameter.setValue(nameTextFld.text, forKey: ConstantMessage.kName)
        ServiceUtility.callWebService(ADD_CONTACT, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    let data = dataFromServer.object(forKey: ConstantMessage.kData) as! NSArray
                    self.delegate.referesgListAfterAdd(contactList: data.mutableCopy() as! NSArray)
                    let sendthisContactArray = NSArray()
                    self.delegate.updateseletedArrayList(contactList: sendthisContactArray.adding(perameter) as NSArray)
                    self.delegate.sharePrayerWithfriends()
                    self.view.removeFromSuperview()
                    self.removeFromParent()
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
    
    func sharePrayerWebService(friendsList : String , deletedcontact : String , deleteIndexPath : Int)
        {
            self.view.endEditing(true)
            if(!ServiceUtility.hasConnectivity())
            {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
                return
            }
            let perameter = NSMutableDictionary()
            perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
            perameter.setValue(SharePrayerID, forKey: ConstantMessage.kPrayerID)
            
            var url = ""
            if isTag {
                perameter.setValue(friendsList, forKey: ConstantMessage.kContacts)
                perameter.setValue(deletedcontact, forKey: ConstantMessage.kUntag)
                url = TAG_PRAYER
            }else{
                perameter.setValue(friendsList, forKey: ConstantMessage.kFriendMobileNo)
                perameter.setValue(deletedcontact, forKey: ConstantMessage.kUnshared)
                url = SHARE_PRAYER_URL
            }
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFJSONResponseSerializer()
            manager.requestSerializer .setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:  ConstantMessage.kAPIKEY)
            ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
            manager.post(url, parameters: perameter, progress: nil, success:
                {
                    requestOperation, response  in
                    ServiceUtility.hideProgressHudInView()
                    let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                    {
                        if deleteIndexPath == -1
                        {
                        }else
                        {
                        }
                    }else
                    {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                    }
            }, failure: {
                requestOperation, error in
                ServiceUtility.hideProgressHudInView()
                ServiceUtility.hideProgressHudInView()
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
            })
            
        }
    
}

