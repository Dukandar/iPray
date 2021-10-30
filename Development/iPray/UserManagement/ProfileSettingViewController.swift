//
//  ProfileSettingViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class ProfileSettingViewController: UIViewController {
    
    // MARK: - outlets
    @IBOutlet var editBtnCliked: UIButton!
    @IBOutlet var userProfileTableView: UITableView!
    
    // MARK: - Variables
    private var imagePicker = UIImagePickerController()
    private var filedNames : NSArray {
           return self.returnFieldNames()
       }
    private var serviceRequestParams = NSMutableDictionary()
    private var isEditableTrue = false
    private var isFromISD = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userProfileTableView.estimatedRowHeight = 120
        self.imagePicker.delegate = self
        self.getUserDetailWebService()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshUserDataWith(data :  NSDictionary) {
       DefaultsManager.share.loginData = data
       UserManager.shareManger.setLoginDataWith(data: DefaultsManager.share.loginData)
       self.userProfileTableView.dataSource = self
       self.userProfileTableView.delegate = self
       self.userProfileTableView.reloadData()
       self.getCoutryCodeDefault()
       self.serviceRequestParams = self.returnServiceRequestParams()
    }
    
    // MARK: -  Action Button
    @IBAction func backBtnCliked(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func getCoutryCodeDefault() {
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
         let cell = self.userProfileTableView.cellForRow(at: IndexPath(row: 3, section: 0))
         let textField = cell?.viewWithTag(32) as! UITextField
         textField.text = UserManager.shareManger.countryCode ?? phoneCode
         (cell!.viewWithTag(31) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
    }
    
    
    @IBAction func changeProfileImageBtnCliked(_ sender: UIButton) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:ConstantMessage.kChooseImage, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:ConstantMessage.kCamera, style:UIAlertAction.Style.default, handler:{ action in
            self.takePictureThroughCamera()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:ConstantMessage.kPhotoGallery, style:UIAlertAction.Style.default, handler:{ action in
            self.selectPictureThroughPhotoGallery()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:ConstantMessage.kCancel, style:UIAlertAction.Style.cancel, handler:nil))
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            self.present(settingsActionSheet, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func genderSelectionBtnCliked(_ sender: UIButton) {
        if self.isEditableTrue
        {
            let cell = self.userProfileTableView.cellForRow(at: IndexPath(row: 4, section: 0))
            (cell!.viewWithTag(3) as! UIImageView).image = (sender.tag == 11) ? #imageLiteral(resourceName: "addPrayer_select_radio_button_Image") : #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
            (cell!.viewWithTag(4) as! UIImageView).image = (sender.tag == 12) ? #imageLiteral(resourceName: "addPrayer_select_radio_button_Image") : #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
            self.serviceRequestParams.setValue((sender.tag == 12) ? "2" : "1" , forKey: ConstantMessage.kGender)
        }
    }
    
    @IBAction func editBtnCliked(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isEditableTrue
        {
            let errorMessage = userProfileValidation()
            if errorMessage.length <= 0 {
                saveUserDetailWebService()
            }else{
                ServiceUtility.showMessageHudWithMessage(errorMessage,delay: ConstantMessage.kDelay)
            }
        }else
        {
            self.isEditableTrue = true
            self.userProfileTableView.reloadData()
            editBtnCliked.setImage(UIImage(named: ""), for: UIControl.State.normal)
            editBtnCliked.setTitle(ConstantMessage.kSSave, for: UIControl.State.normal)
        }
    }
    
    @IBAction func selectCountryCodeBtn(_ sender: UIButton) {
        self.isFromISD = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kCountryListViewController) as! CountryListViewController
        vc.deligate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logOutBtnCliked(_ sender: UIButton) {
        let alert = UIAlertController(title: ConstantMessage.kLogout, message: ConstantMessage.LogoutConfirmation, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kNo, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: ConstantMessage.kYes, style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            self.logOutWebService()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func iPrayLinkForDonation(_ sender: UIButton) {}
}

// MARK: - TableView Delegate
extension ProfileSettingViewController :  UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filedNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  (indexPath.row == 0) ? 180.0 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kImageCell)! as UITableViewCell
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.setImageWith(NSURL(string: returnProfileDataWith(index: indexPath.row))! as URL, placeholderImage: UIImage(named: ConstantMessage.kPlaceholderProfileImage))
            imageView.layer.cornerRadius = imageView.frame.size.height / 2
            cell.isUserInteractionEnabled = (self.isEditableTrue) ? true : false
            return cell
        case 3:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kMobileNo)! as UITableViewCell
            let textField = cell.viewWithTag(34) as! UITextField
            textField.placeholder = ((self.filedNames[indexPath.row] as! NSDictionary).value(forKey: ConstantMessage.kFieldName) as! String)
            (cell.viewWithTag(32) as! UITextField).text = UserManager.shareManger.countryCode!
            textField.text = returnProfileDataWith(index: indexPath.row)
            cell.isUserInteractionEnabled = (self.isEditableTrue) ? true : false
            return cell
        case 4:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kRadioGroupCell)! as UITableViewCell
            (cell.viewWithTag(3) as! UIImageView).image = (returnProfileDataWith(index: indexPath.row) == "1") ? #imageLiteral(resourceName: "addPrayer_select_radio_button_Image") : #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
            (cell.viewWithTag(4) as! UIImageView).image = (returnProfileDataWith(index: indexPath.row) == "2") ? #imageLiteral(resourceName: "addPrayer_select_radio_button_Image") : #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
            return cell
        case 5:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kButtonCell)! as UITableViewCell
            return cell
        default:
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextfieldCell)! as UITableViewCell
            let textField = cell.viewWithTag(1) as! UITextField
            textField.placeholder = ((self.filedNames[indexPath.row] as! NSDictionary).value(forKey: ConstantMessage.kFieldName) as! String)
            textField.text = returnProfileDataWith(index: indexPath.row)
            cell.isUserInteractionEnabled = (self.isEditableTrue) ? true : false
            return cell
        }
    }
}

extension ProfileSettingViewController:countryList {
    func getCountryList(name: String) {
        let cell = self.userProfileTableView.cellForRow(at: IndexPath(row: 3, section: 0))
        let textField = cell?.viewWithTag(32) as! UITextField
        textField.text = name
        (cell!.viewWithTag(31) as! UIImageView).isHidden = (textField.text == "+1") ? false : true
    }
    
}

// MARK: - TextField Delegate
extension ProfileSettingViewController :  UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.canBeConverted(to: String.Encoding.ascii){
            return false
        }
        if UIPasteboard.general.string != nil && (string == UIPasteboard.general.string) {
            return false
        }
        if  (((textField.text?.count)! > 45) && string != "")
        {
            return false
        }
        if UIPasteboard.general.string != nil && (((UIPasteboard.general.string)?.count)! > 30) && string == (UIPasteboard.general.string)
        {
            return false
        }
        
        //Manage Country Code
        let pointInTable = textField.convert(textField.bounds.origin, to: self.userProfileTableView)
        let textFieldIndexPath = self.userProfileTableView.indexPathForRow(at: pointInTable)
        if textFieldIndexPath?.row == 3{
            let maxLength = 14
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.userProfileTableView)
        let textFieldIndexPath = (self.userProfileTableView.indexPathForRow(at: pointInTable)! as IndexPath)
        switch textFieldIndexPath.row {
        case 1:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kName)
        case 2:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kEmail)
        case 3:
            self.serviceRequestParams.setValue(textField.text, forKey: ConstantMessage.kMobileNo)
        default:break
        }
    }
}

// MARK: - ImagePicker Delegate
extension ProfileSettingViewController : UIImagePickerControllerDelegate,UIPopoverControllerDelegate , UINavigationControllerDelegate
{
    func takePictureThroughCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.allowsEditing = false
            self .present(self.imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alertVC = UIAlertController(title: ConstantMessage.kNoCamera, message: ConstantMessage.kDevicecameraErr, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: ConstantMessage.kOk, style:.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func selectPictureThroughPhotoGallery() {
        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.imagePicker.allowsEditing = true
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        dismiss(animated: true, completion: nil)
        if let newimage : UIImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)
        {
            self.uploadImageWebservice(image: newimage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Web Service
extension ProfileSettingViewController
{
    //MARK: get user details Webservice
    func getUserDetailWebService() {
        if(!ServiceUtility.hasConnectivity())
        {
            self.userProfileTableView.dataSource = self
            self.userProfileTableView.delegate = self
            self.userProfileTableView.reloadData()
            self.getCoutryCodeDefault()
            self.serviceRequestParams = self.returnServiceRequestParams()
            
        }else{
            let perameter = NSMutableDictionary()
            if UserManager.shareManger.userID != nil {
                perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
            }else
            {
                return
            }
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFJSONResponseSerializer()
            manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField: ConstantMessage.kAPIKEY)
            ServiceUtility.hideProgressHudInView()
            ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
            manager.post(GET_USER_DETAIL_URL, parameters: perameter, progress: nil, success:
            {
                    requestOperation, response  in
                    ServiceUtility.hideProgressHudInView()
                    let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                self.refreshUserDataWith(data: data)
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
            }, failure: {
                requestOperation, error in
                ServiceUtility.hideProgressHudInView()
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
            })
        }
    }
    
    //MARK: update user details Webservice
    func saveUserDetailWebService() {
        if(!ServiceUtility.hasConnectivity()) {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField: ConstantMessage.kAPIKEY)
        manager.responseSerializer = AFJSONResponseSerializer()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        manager.post(SAVE_USER_DETAIL_URL, parameters: self.serviceRequestParams, progress: nil, success:
        {
            requestOperation, response  in
            ServiceUtility.hideProgressHudInView()
            let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                self.isEditableTrue = false
                self.editBtnCliked.setTitle("", for: .normal)
                self.editBtnCliked.setImage(UIImage(named: ConstantMessage.kProfileEditIcon), for: UIControl.State.normal)
                let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                self.refreshUserDataWith(data: data)
               
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }, failure: {
            requestOperation, error in
            ServiceUtility.hideProgressHudInView()
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
        })
    }
    
    //MARK: logOutWebService
    func logOutWebService() {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(DefaultsManager.share.deviceToken ?? "0", forKey: ConstantMessage.kDeviceToken)
        perameter.setValue("1", forKey: ConstantMessage.kDeviceType)
        let manager = AFHTTPSessionManager()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:  ConstantMessage.kAPIKEY)
        manager.responseSerializer = AFJSONResponseSerializer()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        manager.post(LOGOUT_URL, parameters: perameter, progress: nil, success:
            {
                requestOperation, response  in
                ServiceUtility.hideProgressHudInView()
                ApplicationDelegate.logOutFunction()
                DefaultsManager.share.setUserAsLoggedOUT()
        }, failure: {
            requestOperation, error in
            ServiceUtility.hideProgressHudInView()
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
        })
    }
    
    func uploadImageWebservice(image: UIImage) {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:  ConstantMessage.kAPIKEY)
        ServiceUtility.hideProgressHudInView()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        manager.post(UPLOAD_PROFILE_IMAGE_URl, parameters: perameter, constructingBodyWith: { (formData) in
            formData.appendPart(
                withFileData: supportingfuction.compressimage(image: image, compress: 0.1, maxwidth: Int(min( (image.size.width) / 4 , CGFloat(200.0))) , maxheight: Int(min( (image.size.height) / 4 , CGFloat(200.0)))),
                name: ConstantMessage.kPhotoURL,
                fileName: "image.jpeg",
                mimeType: "image/jpeg")
        }, progress: { (Progress) in
        }, success: {
            requestOperation, response  in
            ServiceUtility.hideProgressHudInView()
            let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
            if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                var profile_image = "" as String
                if data.object(forKey: ConstantMessage.kImageURL) != nil
                {
                    profile_image = data.object(forKey: ConstantMessage.kImageURL) as! String
                     let cell = self.userProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0))
                    (cell!.viewWithTag(1) as! UIImageView).setImageWith(NSURL(string: profile_image)! as URL, placeholderImage: UIImage(named: ConstantMessage.kPlaceholderProfileImage))
                    self.editBtnCliked.setTitle("", for: .normal)
                    self.editBtnCliked.setImage(UIImage(named: ConstantMessage.kProfileEditIcon), for: UIControl.State.normal)
                }
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }, failure: {
            requestOperation, error in
            ServiceUtility.hideProgressHudInView()
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}


extension ProfileSettingViewController {
    
    func returnFieldNames()-> NSArray {
        return [[ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:"Full name"],
                [ConstantMessage.kFieldName:"Email"],
                [ConstantMessage.kFieldName:"Mobile"],
                [ConstantMessage.kFieldName:""],
                [ConstantMessage.kFieldName:""]]
    }
    
    func returnProfileDataWith(index  : Int)-> String {
        switch index {
        case 0:
            return UserManager.shareManger.profileImage!
        case 1:
            return UserManager.shareManger.userName!
        case 2:
            return UserManager.shareManger.userEmail!
        case 3:
            return (UserManager.shareManger.contact!.contains("+91") ? (UserManager.shareManger.contact!.replacingOccurrences(of: "+91", with: "")) : UserManager.shareManger.contact!)
        case 4:
            return UserManager.shareManger.gender!
        default:return ""
        }
    }
    
    
    func returnServiceRequestParams()-> NSMutableDictionary {
        return [ConstantMessage.kUserID      : UserManager.shareManger.userID!,
                ConstantMessage.kCountryCode               : UserManager.shareManger.countryCode!,
                ConstantMessage.kName        : UserManager.shareManger.userName!,
                ConstantMessage.kEmail       : UserManager.shareManger.userEmail!,
                ConstantMessage.kMobileNo    : (UserManager.shareManger.contact!.contains("+91") ? (UserManager.shareManger.contact!.replacingOccurrences(of: "+91", with: "")) : UserManager.shareManger.contact!),
                ConstantMessage.kGender                    : UserManager.shareManger.gender!]
    }
    
    func userProfileValidation()-> NSString {
        if let name = self.serviceRequestParams.value(forKey: ConstantMessage.kName) as? String,name.count <= 0{
             return ConstantMessage.kUserName
        }else if let email = self.serviceRequestParams.value(forKey: ConstantMessage.kEmail) as? String,email.count <= 0{
             return ConstantMessage.kEmptyEmail
        }else if let mobile = self.serviceRequestParams.value(forKey: ConstantMessage.kMobileNo) as? String,mobile.count <= 0{
             return ConstantMessage.kEmptyMobileNumber
        }
          return ""
    }
}

