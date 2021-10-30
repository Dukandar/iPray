//
//  UploadGroupImageViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class UploadGroupImageViewController: UIViewController {
    
    // MARK: - Outles & Variables
    @IBOutlet var profileImage: UIImageView!
    var imagePicker = UIImagePickerController()
    var groupData : NSDictionary!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigatToNextScreen()
    {
        let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupWallViewController) as! GroupWallViewController
        vc.groupDiscription = (self.groupData.mutableCopy() as! NSMutableDictionary)
        self.navigationController?.pushViewController(vc, animated: true)
        let array = NSMutableArray()
        array.addObjects(from: (self.navigationController?.viewControllers)!)
        array.removeObject(at: array.count - 2)
        array.removeObject(at: array.count - 2)
        self.navigationController?.viewControllers = array as NSArray as! [UIViewController]
    }
    
    // MARK: - Button Action
    @IBAction func skipUploadImageAction(_ sender: UIButton) {
        navigatToNextScreen()
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
        if UIDevice.current.userInterfaceIdiom == .phone{
            self.present(settingsActionSheet, animated: true, completion: nil)
        }
    }
}

// MARK: - ImagePicker Delegate
extension UploadGroupImageViewController : UIImagePickerControllerDelegate,UIPopoverControllerDelegate , UINavigationControllerDelegate {
    func takePictureThroughCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.isEditing = false
            self .present(imagePicker, animated: true, completion: nil)
        }else {
            let alertVC = UIAlertController(title: ConstantMessage.kNoCamera, message: ConstantMessage.kDevicecameraErr, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: ConstantMessage.kOk, style:.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    /**
     *  Function to selsect image from photo gallery
     */
    
    func selectPictureThroughPhotoGallery()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.isEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     *  Function to set profile image using UIImagePickerController
     */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        UIApplication.shared.statusBarStyle = .lightContent
        let tempimage : UIImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)!
        profileImage.image  = tempimage
        dismiss(animated: true, completion: nil)
        uploadImageWebservice()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - WebService
extension UploadGroupImageViewController
{
    func uploadImageWebservice()
    {
        let image : UIImage = profileImage.image!
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue( self.groupData.object(forKey: ConstantMessage.kGroupID) as! String, forKey: ConstantMessage.kGroupID)
        
        ServiceUtility.callWebService(UPLOAD_GROUP_IMAGE_URl, parameters: parameter, uploadImage: [image], imageParam:  [ConstantMessage.kGroupProfilePic], PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.groupData =  (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    self.navigatToNextScreen()
                    
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                    
                }
                
            }  else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
            
        }
        
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

