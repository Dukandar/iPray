//
//  UploadImageViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class UploadImageViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outle & Variable
    @IBOutlet var profileImage: UIImageView!
    
    // MARK: - Variables
    private var imagePicker = UIImagePickerController()
    private let kInviteCde : NSString = ConstantMessage.kInviteCode as NSString
    private let kInviteCodeEr: NSString = ConstantMessage.kValidInviteCode as NSString
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileImage()
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height / 2
        self.imagePicker.delegate = self
        setUpOTPView()
    }
    
    func setProfileImage()
    {
        if let profileImageUrl = UserDefaults.standard.object(forKey: ConstantMessage.kUploadImage){
            profileImage.setImageWith(NSURL(string: profileImageUrl as! String)! as URL, placeholderImage: UIImage(named: ConstantMessage.kUploadImage))
            self.profileImage.layoutIfNeeded()
        }else{
            self.profileImage.image =  UIImage(named: ConstantMessage.kUploadImage)
        }
    }
    
    func navigateToWelcomeViewController(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kWelcomeViewController) as! WelcomeViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Button Action
    @IBAction func skipUploadImagBtnTapped(_ sender: UIButton) {
        navigateToWelcomeViewController()
    }
    
    @IBAction func changeProfileImageBtnCliked(_ sender: UIButton) {
        let settingsActionSheet: UIAlertController = UIAlertController(title:ConstantMessage.kChooseImage, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        settingsActionSheet.addAction(UIAlertAction(title:ConstantMessage.kCamera, style:UIAlertAction.Style.default, handler:{ action in
            self.uploadPictureFromCamera()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:ConstantMessage.kPhotoGallery, style:UIAlertAction.Style.default, handler:{ action in
            self.uploadPictureFromGallery()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:ConstantMessage.kCancel, style:UIAlertAction.Style.cancel, handler:nil))
        if UIDevice.current.userInterfaceIdiom == .phone{
            self.present(settingsActionSheet, animated: true, completion: nil)
        }
    }
}

// MARK: - ImagePicker Delegate
extension UploadImageViewController : UIImagePickerControllerDelegate,UIPopoverControllerDelegate , UINavigationControllerDelegate {
    /**
     *  Function to take image through camera
     */
    func uploadPictureFromCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.isEditing = false
            self .present(self.imagePicker, animated: true, completion: nil)
        }else {
            let alertVC = UIAlertController(title: ConstantMessage.kNoCamera, message: ConstantMessage.kDevicecameraErr, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: ConstantMessage.kOk, style:.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    /**
     *  Function to selsect image from photo gallery
     */
    
    func uploadPictureFromGallery()
    {
        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.imagePicker.isEditing = false
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    /**
     *  Function to set profile image using UIImagePickerController
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
//        UIApplication.shared.statusBarStyle = .lightContent
        let tempimage : UIImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)!
        self.profileImage.image  = tempimage
        dismiss(animated: true, completion: nil)
        uploadImageWebservice()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- API Call
extension UploadImageViewController
{
    func uploadImageWebservice() {
        let image : UIImage = self.profileImage.image!
        ServiceUtility.callWebService(UPLOAD_PROFILE_IMAGE_URl, parameters: returnUploadImageParams(), uploadImage: [image], imageParam:  [ConstantMessage.kPhotoURL], PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                var profile_image = "" as String
                if data.object(forKey: ConstantMessage.kImageURL) != nil
                {
                    profile_image = data.object(forKey: ConstantMessage.kImageURL) as! String
                }
                UserDefaults.standard.set(profile_image, forKey: ConstantMessage.kProfileImage)
                UserDefaults.standard.synchronize()
                self.navigateToWelcomeViewController()
            }  else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay:  ServiceUtility.messageDelay())
            }
        }
    }
    
    func sendInvitationCode(shareCode : String) {
        ServiceUtility.callWebService(VERIFY_TAG_INVITATION_CODE, parameters: returnInvServiceParamsWith(shareCode: shareCode), PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                }else{
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay:  ServiceUtility.messageDelay())
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay:  ServiceUtility.messageDelay())
            }
        }
    }
}

//MARK:- OTP
extension UploadImageViewController {
     func setUpOTPView() {
            let actionSheetController: UIAlertController = UIAlertController(title: ConstantMessage.kOTPPray, message: ConstantMessage.kPrivateCode, preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kCancel, style: .cancel) { action -> Void in
                //Do some stuff
            }
            let nextAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kSubmit, style: .default) { action -> Void in
                
               if let field : UITextField = actionSheetController.textFields?[0]
                {
                    let text : String = field.text!
                    if text.count == 6
                    {
                        self.sendInvitationCode(shareCode: text)
                        actionSheetController.dismiss(animated: true, completion: nil)
                    }else
                    {
                        if text.count == 0
                        {
                            ServiceUtility.showMessageHudWithMessage(self.kInviteCde, delay:  ServiceUtility.messageDelay())
                        }else
                        {
                            ServiceUtility.showMessageHudWithMessage(self.kInviteCodeEr, delay:  ServiceUtility.messageDelay())
                        }
                        self.setUpOTPView()
                    }
                }
                else
                {
                    ServiceUtility.showMessageHudWithMessage(self.kInviteCde, delay:  ServiceUtility.messageDelay())
                    self.setUpOTPView()
                }
            }
            //Add a text field
            actionSheetController.addTextField { textField -> Void in
                //TextField configuration
                textField.textColor = UIColor.black
                textField.delegate = self
                textField.tag = 51
                textField.keyboardType = .default
                textField.placeholder = "######"
                textField.textAlignment = .center
            }
            
            actionSheetController.addAction(nextAction)
            actionSheetController.addAction(cancelAction)
            //actionSheetController.addAction(resentOtp)
            self.present(actionSheetController, animated: true, completion: nil)
        }
}

extension UploadImageViewController{
    
    func returnUploadImageParams()-> NSMutableDictionary{
        return [ConstantMessage.kUserID: UserManager.shareManger.userID!]
    }
    
    func returnInvServiceParamsWith(shareCode : String)-> NSMutableDictionary{
        return [ConstantMessage.kUserID    : UserManager.shareManger.userID!,
                ConstantMessage.kShareCode : shareCode]
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

