//
//  GroupSettingViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
protocol GroupSettingViewControllerDelegate
{
    func navigateToPreviousScreen()
}
class GroupSettingViewController: UIViewController {
    
    // MARK: - outlets
    var delegate : GroupSettingViewControllerDelegate!
    @IBOutlet var editBtnCliked: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var leaveGroupPopUp: UIView!
    @IBOutlet weak var leaveGroupPopUp1: UIView!
    
    // MARK: - Variables
    var profileImageView : UIImageView!
    var groupProfileDic : NSDictionary!
    var groupProfileArray  : NSMutableArray = NSMutableArray()
    var placeHolderArray = ["","Group Name","Group Description","Group Password","Admins","Members",ConstantMessage.kLeaveGroup,"Close Group"]
    var imagePicker = UIImagePickerController()
    var iseditableTrue = false
    var isAdmin = false
    var totalRows = 0
    var isforImage = false
    var isFromGroupList = false
    var isPublic = true
    var isUnderstand = false
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        imagePicker.delegate = self
        self.leaveGroupPopUp1.layer.cornerRadius = 10.0
        leaveGroupPopUp.isHidden = true
        self.fillBlanckArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isforImage
        {
             isforImage = false
        }else
        {
             self.getGroupDetailWebService()
        }
    }
    
    func fillBlanckArray()
    {
        groupProfileArray.add("")
        groupProfileArray.add("")
        groupProfileArray.add("")
        groupProfileArray.add("")
        groupProfileArray.add("")
        groupProfileArray.add("")
        groupProfileArray.add("")
        groupProfileArray.add("")
        //self.setGroupProfileData()
    }
    
    func setGroupProfileData(){
        if groupProfileDic != nil && groupProfileDic.object(forKey: ConstantMessage.kIsCoAdmin) != nil
        {
            // open for admin
            if let coAdiminCount = groupProfileDic.object(forKey: ConstantMessage.kIsCoAdmin) as? String,coAdiminCount.count > 0{
                isAdmin = (NSInteger(coAdiminCount)! >= 1) ? true : false
            }
            totalRows = placeHolderArray.count
        }else
        {
            // open for member
            isAdmin = false
            totalRows = placeHolderArray.count - 1
            editBtnCliked.isHidden = true
        }
        if groupProfileDic.object(forKey: ConstantMessage.kGroupProfilePic) != nil
        {
            groupProfileArray.replaceObject(at: 0, with: groupProfileDic.object(forKey: ConstantMessage.kGroupProfilePic) as! String)
        }else if groupProfileDic.object(forKey: ConstantMessage.kGroupImage) != nil
        {
           groupProfileArray.replaceObject(at: 0, with: groupProfileDic.object(forKey: ConstantMessage.kGroupImage) as! String)
        }
        if groupProfileDic.object(forKey: ConstantMessage.kGroupName) != nil
        {
            groupProfileArray.replaceObject(at: 1, with: groupProfileDic.object(forKey: ConstantMessage.kGroupName) as! String)
        }else if groupProfileDic.object(forKey: ConstantMessage.kName) != nil
        {
            groupProfileArray.replaceObject(at: 1, with: groupProfileDic.object(forKey: ConstantMessage.kName) as! String)
           
        }
        if groupProfileDic.object(forKey: ConstantMessage.kGroupDescription) != nil
        {
            groupProfileArray.replaceObject(at: 2, with: groupProfileDic.object(forKey: ConstantMessage.kGroupDescription) as! String)
        }
        
        if groupProfileDic.object(forKey: ConstantMessage.kIsPublic) as! String == "1"
        {
            self.isPublic = true
        }else
        {
            self.isPublic = false
        }
 
        var totalmembercount = 0
        if groupProfileDic.object(forKey: ConstantMessage.kAdminCount) != nil && groupProfileDic.object(forKey: ConstantMessage.kAdminCount) is String
        {
            groupProfileArray.replaceObject(at: 4, with: groupProfileDic.object(forKey: ConstantMessage.kAdminCount) as! String)
            totalmembercount = Int( groupProfileDic.object(forKey: ConstantMessage.kAdminCount) as! String)!
        }
        if groupProfileDic.object(forKey: ConstantMessage.kMemberCount) != nil && groupProfileDic.object(forKey: ConstantMessage.kMemberCount) is String
        {
            totalmembercount = totalmembercount + Int( groupProfileDic.object(forKey: ConstantMessage.kMemberCount) as! String)!
            groupProfileArray.replaceObject(at: 5, with: "\(totalmembercount)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Button Action
    @IBAction func backBtnCliked(_ sender: UIButton) {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // 11 : I understand
    // 12 : Yes
    // 13 : No
    @IBAction func leaveGroupPopUpBtnClicked(_ sender: UIButton) {
        if sender.tag == 11{
            if isUnderstand {
                isUnderstand = false
                sender.setImage(UIImage(named : ConstantMessage.kHelpUnCheck), for: .normal)
            }else{
                isUnderstand = true
                sender.setImage(UIImage(named : ConstantMessage.kHelpCheck), for: .normal)
            }
        }else if sender.tag == 12{
            if isUnderstand {
                self.leaveGroupPopUp.isHidden = true
                self.CloseGroupWebService()
            }else{
                return
            }
        }else{
            self.leaveGroupPopUp.isHidden = true
        }
    }
    
    /**
     *  Action to change uploaded profile image by camera or photo gallery
     */
    @IBAction func changeProfileImageBtnCliked(_ sender: UIButton) {
        if iseditableTrue
        {
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
        
    }
    
    @IBAction func editBtnCliked(_ sender: UIButton) {
        self.view.endEditing(true)
        if iseditableTrue
        {
            
            if ((groupProfileArray[1]) as! String).trimmingCharacters(in: CharacterSet.whitespaces)=="" {
                
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.GroupName,delay: ConstantMessage.kDelay)
                return
            }else if groupProfileDic.object(forKey: ConstantMessage.kIsPublic) as! String == "1" && !self.isPublic && groupProfileArray.object(at: 3) as! String == "" {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.EnterGroupPassword,delay: ConstantMessage.kDelay)
                return
            }else
            {
                 saveGroupProfileDetailWebService()
            }
        }else
        {
            iseditableTrue = true
            editBtnCliked.setImage(UIImage(named: ""), for: UIControl.State.normal)
            editBtnCliked.setTitle(ConstantMessage.kSSave, for: UIControl.State.normal)
            
        }
        tableView.reloadData()
        
    }
    
    @IBAction func publicSwitchClicked(_ sender: UISwitch) {
        
        if sender.isOn {
            isPublic = true
        }else{
            isPublic = false
        }
        self.tableView.reloadData()
    }
    
    @IBAction func cellButtonPress(_ sender: UIButton) {
        
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: pointInTable)! as IndexPath
        
        var placeholderIndex : Int!
        
        if isPublic {
            placeholderIndex = placeHolderArray.count - 1
        }else{
            placeholderIndex = placeHolderArray.count
        }
        
        if indexPath.row == placeholderIndex
        {
            self.leaveGroupPopUp.isHidden = false
            
        }else if indexPath.row == placeholderIndex - 1
        {
            
            if self.groupProfileDic.object(forKey: ConstantMessage.kIsMember) != nil && self.groupProfileDic.object(forKey: ConstantMessage.kIsMember) as! String == "0"
            {
                if self.groupProfileDic.object(forKey: ConstantMessage.kIsPublic) != nil && self.groupProfileDic.object(forKey: ConstantMessage.kIsPublic) as! String == "0"
                {
                    // password
                    self.openPasswordView()
                }else
                {
                    // send request
                    self.sendRequestToAddGroupWebServices(password : "")
                    
                }
            }else
            {
                let alert = UIAlertController(title: ConstantMessage.kLeaveGroup, message: ConstantMessage.LeaveConfirmation, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: ConstantMessage.kNo, style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: ConstantMessage.kYes, style: UIAlertAction.Style.default, handler: {
                    (alertAction) -> Void in
                    self.LeaveGroupWebService()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }else  if indexPath.row == placeholderIndex - 2
        {
            // force othr user not to open lists
            if groupProfileDic.object(forKey: ConstantMessage.kIsMember) != nil && groupProfileDic.object(forKey: ConstantMessage.kGroupAdmins) != nil && groupProfileDic.object(forKey: ConstantMessage.kGroupID) != nil && groupProfileDic.object(forKey: ConstantMessage.kGroupName) != nil && groupProfileDic.object(forKey: ConstantMessage.kIsMember) as! String == "0"
            {
                return
            }
            // navigate to Member list
            let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kInviteMembersViewController) as! InviteMembersViewController
            vc.isadmin = isAdmin
             vc.ShareGroupID = groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String
            // mergering here bc of php team provide seperate list
            let members = ((groupProfileDic.object(forKey: ConstantMessage.kGroupMembers) as! NSArray)).addingObjects(from: ((groupProfileDic.object(forKey: ConstantMessage.kGroupAdmins) as! NSArray) as! [Any]))
            vc.alreadyShareContactArrayList = (members as NSArray).mutableCopy() as! NSMutableArray
             vc.groupName = groupProfileDic.object(forKey: ConstantMessage.kGroupName) as! String
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else  if (indexPath.row == placeholderIndex - 3)
        {
            // force othr user not to open lists
            if groupProfileDic.object(forKey: ConstantMessage.kIsMember) != nil && groupProfileDic.object(forKey: ConstantMessage.kGroupAdmins) != nil && groupProfileDic.object(forKey: ConstantMessage.kGroupID) != nil && groupProfileDic.object(forKey: ConstantMessage.kGroupName) != nil && groupProfileDic.object(forKey: ConstantMessage.kIsMember) as! String == "0"
            {
                return
            }
            // navigate to admin list
            let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kInviteAdminViewController) as! InviteAdminViewController
             vc.isadmin = isAdmin
            vc.ShareGroupID = groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String
            vc.alreadyShareContactArrayList = (groupProfileDic.object(forKey: ConstantMessage.kGroupAdmins) as! NSArray).mutableCopy() as! NSMutableArray
            vc.groupName = groupProfileDic.object(forKey: ConstantMessage.kGroupName) as! String
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func openPasswordView()
    {
        let actionSheetController: UIAlertController = UIAlertController(title: ConstantMessage.kPRIVATEGROUP, message: ConstantMessage.kEnterGroupPassword, preferredStyle: .alert)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kCancel, style: .cancel) { action -> Void in
            //Do some stuff
        }
        let nextAction: UIAlertAction = UIAlertAction(title: ConstantMessage.ksubmit, style: .default) { action -> Void in
            if let field : UITextField  = actionSheetController.textFields![0] as? UITextField
            {
                let text : String = field.text!
                
                if text.count == 0
                {
                    ServiceUtility.showMessageHudWithMessage("\(ConstantMessage.kEnterGroupPassword)" as NSString, delay: ConstantMessage.kDelay)
                }else
                {
                    self.sendRequestToAddGroupWebServices(password : text)
                }
            }
        }
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.black
            textField.delegate = self
            textField.tag = 51
            textField.keyboardType = .default
            textField.placeholder = ConstantMessage.kPasswordPlaceHolder
            textField.textAlignment = .center
        }
        
        actionSheetController.addAction(nextAction)
        actionSheetController.addAction(cancelAction)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
}

// MARK: - TableView Delegate
extension GroupSettingViewController :  UITableViewDataSource , UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPublic {
            return totalRows
        }
        return totalRows + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        
        if indexPath.row == 0
        {
            let indexData = groupProfileArray.object(at: indexPath.row)
            cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kProfileCell, for: indexPath)
            
            profileImageView = (cell.viewWithTag(1) as! UIImageView)
            let groupPasswordIntruction = cell.viewWithTag(-11) as! UILabel
            let editButton = cell.viewWithTag(-12) as! UIButton
            if isAdmin
            {
                if groupProfileDic.object(forKey: ConstantMessage.kIsPublic) != nil && groupProfileDic.object(forKey: ConstantMessage.kIsPublic) as! String != "1"
                {
                   
                    groupPasswordIntruction.text = ConstantMessage.kPRIVATERemovePassword
                }else
                {
                    groupPasswordIntruction.text = ConstantMessage.kPUBLICAddPassword
                }
            }else
            {
                groupPasswordIntruction.text =  ""
            }
            
            if iseditableTrue
            {
                editButton.isHidden = false
                
            }else
            {
                editButton.isHidden = true
            }
           
            
            profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
            if indexData is String && indexData as! String != ""
            {
                profileImageView.setImageWith(NSURL(string: indexData as! String)! as URL, placeholderImage: #imageLiteral(resourceName: "groupDefault"))
                profileImageView.layoutIfNeeded()
                
            }else if indexData is UIImage
            {
                profileImageView.image = indexData as? UIImage
                
            }else
            {
                
                profileImageView.image = #imageLiteral(resourceName: "groupDefault")
            }
            profileImageView.layoutIfNeeded()
            
        }else //1 2 3
        {
            
            if  (indexPath.row  == 1)
            {
                let indexData = groupProfileArray.object(at: indexPath.row)
                cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kLabelCell, for: indexPath)
                let dataTextview = cell.viewWithTag(2) as! UITextField
                let nameLbl = cell.viewWithTag(1) as! UILabel
                
                if  iseditableTrue
                {
                    dataTextview.isUserInteractionEnabled = true
                    dataTextview.text = indexData as? String
                    nameLbl.text = ""
                    nameLbl.isHidden = true
                    dataTextview.isHidden = false
                    
                }else
                {
                    nameLbl.isHidden = false
                    dataTextview.isHidden = true
                    nameLbl.text = indexData as? String
                    dataTextview.text = ""
                    dataTextview.isUserInteractionEnabled = false
   
                }
            }else if indexPath.row == 3 {
                cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kPublicCell, for: indexPath)
                let publicSwitch = cell.viewWithTag(1) as! UISwitch
                
                if iseditableTrue {
                    publicSwitch.isUserInteractionEnabled = true
                }else{
                    publicSwitch.isUserInteractionEnabled = false
                }
                
                if self.isPublic {
                    publicSwitch.isOn = true
                }else{
                    publicSwitch.isOn = false
                }
            }else
            {
                var indexData = ""
                
                if indexPath.row == 2 || isPublic{
                    indexData = groupProfileArray.object(at: indexPath.row) as! String
                }else {
                    indexData = groupProfileArray.object(at: indexPath.row - 1) as! String
                }
                
                cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kTextFiledCell, for: indexPath)
                let lableName = cell.viewWithTag(1) as! UILabel
                let dataTextview = cell.viewWithTag(2) as! UITextField
                let button = cell.viewWithTag(3) as! UIButton
                let nameLbl = cell.viewWithTag(4) as! UILabel
                
                nameLbl.isHidden = true
                if !isPublic && indexData == "" && indexPath.row  == 4
                {
                    dataTextview.text =  ConstantMessage.kDefNumber
                }else
                {
                    if  (indexPath.row  == 2) {
                        if iseditableTrue{
                            dataTextview.text = indexData
                            nameLbl.text = ""
                            nameLbl.isHidden = true
                            dataTextview.isHidden = false
                        }else{
                            dataTextview.text = ""
                            nameLbl.text = indexData
                            nameLbl.isHidden = false
                            dataTextview.isHidden = true
                        }
                    }else{
                        nameLbl.isHidden = true
                        dataTextview.text = indexData
                    }
                }
                
                if ((!isPublic && indexPath.row == 7) || (indexPath.row == 6)) && groupProfileDic.object(forKey: ConstantMessage.kIsMember) != nil && groupProfileDic.object(forKey: ConstantMessage.kIsMember) as! String == "0"
                {
                    lableName.text = ConstantMessage.kJoinGroup
                }else
                {
                    let index : Int!
                    if isPublic || indexPath.row == 2{
                        index = indexPath.row
                    }else{
                        index = indexPath.row - 1
                    }
                    lableName.text = placeHolderArray[index]
                }
                if  (indexPath.row  == 2) && iseditableTrue
                {
                    dataTextview.isUserInteractionEnabled = true
                    button.isHidden = true
                }else if !isPublic && indexPath.row  == 4 && iseditableTrue{
                    dataTextview.isUserInteractionEnabled = true
                    button.isHidden = true                }else
                {
                    dataTextview.isUserInteractionEnabled = false
                    button.isHidden = false
                    
                }
                
                if !isPublic && indexPath.row  == 4
                {
                    dataTextview.isSecureTextEntry = true
                }else
                {
                    dataTextview.isSecureTextEntry = false
                }
                
            }
        }
        return cell
    }
}

// MARK: - TextField Delegate
extension GroupSettingViewController :  UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let textFieldIndexPath = (self.tableView.indexPathForRow(at: pointInTable)! as IndexPath)
        if !isPublic && (textFieldIndexPath.row) == 4 && textField.text == ConstantMessage.kNonePublic {
            textField.text = ""
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.canBeConverted(to: String.Encoding.ascii){
            return false
        }
        
        // pasting and max char
        if  (((textField.text?.count)! > 25) && string != "")
        {
            return false
        }
        if UIPasteboard.general.string != nil && (((UIPasteboard.general.string)?.count)! > 25) && string == (UIPasteboard.general.string)
        {
            return false
        }
        return true
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let textFieldIndexPath = (self.tableView.indexPathForRow(at: pointInTable)! as IndexPath)
        let newtextdata : String = textField.text!
        if (textFieldIndexPath.row) > 0 && (textFieldIndexPath.row) < 4 {
            groupProfileArray.replaceObject(at: (textFieldIndexPath.row), with: newtextdata)
        }
        if !isPublic && (textFieldIndexPath.row) == 4 {
            groupProfileArray.replaceObject(at: 3, with: newtextdata)
        }
    }
}

// MARK: - ImagePicker Delegate
extension GroupSettingViewController : UIImagePickerControllerDelegate,UIPopoverControllerDelegate , UINavigationControllerDelegate
{

    func takePictureThroughCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            isforImage = true
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self .present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alertVC = UIAlertController(title: ConstantMessage.kNoCamera, message: ConstantMessage.kDevicecameraErr, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: ConstantMessage.kOk, style:.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    func selectPictureThroughPhotoGallery()
    {
        isforImage = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        dismiss(animated: true, completion: nil)
        if let newimage : UIImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)
        {
            groupProfileArray.replaceObject(at: 0, with: newimage)
            tableView.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Web Service
extension GroupSettingViewController
{
    func moveToBackClass()
    {
        if !self.isFromGroupList && delegate != nil
        {
             self.navigationController?.popViewController(animated: false)
             delegate.navigateToPreviousScreen()
            
        }else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    func getGroupDetailWebService()
    {
        
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        
        let perameter = NSMutableDictionary()
        if groupProfileDic.object(forKey: ConstantMessage.kGroupID)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String, forKey: ConstantMessage.kGroupID)
        }else if groupProfileDic.object(forKey: ConstantMessage.kId)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kId) as! String, forKey: ConstantMessage.kGroupID)
        }else
        {
            return
        }
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)

        
        ServiceUtility.callWebService(GET_ALL_GROUP_LIST, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            self.view.isUserInteractionEnabled = true
            if success && dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool
            {
                self.groupProfileDic = (dataFromServer.object(forKey: ConstantMessage.kData) as! NSDictionary)
                self.setGroupProfileData()
                
            }else
            {
                
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }
        
    }
    func saveGroupProfileDetailWebService()
    {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }

        var passwordString = ""
        
        if isPublic {
            passwordString = ""
        }else{
            passwordString = groupProfileArray[3] as! String
        }
        
        let perameter = NSMutableDictionary()
        if groupProfileDic.object(forKey: ConstantMessage.kGroupID)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String, forKey: ConstantMessage.kGroupID)
        }else if groupProfileDic.object(forKey: ConstantMessage.kId)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kId) as! String, forKey: ConstantMessage.kGroupID)
        }else
        {
            return
        }
        
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
   
        perameter.setValue(groupProfileArray[1], forKey: ConstantMessage.kGroupName)
        perameter.setValue(groupProfileArray[2], forKey: ConstantMessage.kGroupDecription)
        perameter.setValue(passwordString, forKey: ConstantMessage.kGroupPassword)
        perameter.setValue(isPublic, forKey: ConstantMessage.kIsPublic)
        perameter.setValue("1", forKey: ConstantMessage.kIsActive)
        let image : UIImage = self.profileImageView.image!
        ServiceUtility.callWebService(SAVE_GROUP_DETAIL_URL, parameters: perameter, uploadImage: [image], imageParam:  [ConstantMessage.kGroupProfilePic], PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.iseditableTrue = false
                    self.editBtnCliked.setTitle("", for: .normal)
                    self.editBtnCliked.setImage(UIImage(named: ConstantMessage.kProfileEditIcon), for: UIControl.State.normal)
                    self.getGroupDetailWebService()
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
    
    func CloseGroupWebService()
    {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        if groupProfileDic.object(forKey: ConstantMessage.kGroupID)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String, forKey: ConstantMessage.kGroupID)
        }else if groupProfileDic.object(forKey: ConstantMessage.kId)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kId) as! String, forKey: ConstantMessage.kGroupID)
        }else
        {
            return
        }
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue("0", forKey:ConstantMessage.kIsActive)
        ServiceUtility.callWebService(SAVE_GROUP_DETAIL_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success && dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                self.moveToBackClass()
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
    
   
    func LeaveGroupWebService()
    {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        if groupProfileDic.object(forKey: ConstantMessage.kGroupID)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String, forKey: ConstantMessage.kGroupID)
        }else if groupProfileDic.object(forKey: ConstantMessage.kId)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kId) as! String, forKey: ConstantMessage.kGroupID)
        }else
        {
            return
        }
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
    
        perameter.setValue(UserDefaults.standard.object(forKey: ConstantMessage.kUserId) as! String, forKey: ConstantMessage.kFriendID)
        
        ServiceUtility.callWebService(LEAVE_GROUP_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success && dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                self.moveToBackClass()
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
    
    func sendRequestToAddGroupWebServices(password : String)
    {
        let perameter = NSMutableDictionary()
        if groupProfileDic.object(forKey: ConstantMessage.kGroupID)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kGroupID) as! String, forKey: ConstantMessage.kGroupID)
        }else if groupProfileDic.object(forKey: ConstantMessage.kId)  != nil {
            perameter.setValue(groupProfileDic.object(forKey: ConstantMessage.kId) as! String, forKey: ConstantMessage.kGroupID)
        }else
        {
            return
        }
        perameter.setValue(password, forKey: ConstantMessage.kGroupPassword)
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        ServiceUtility.callWebService(REQUEST_TO_JOIN_GROUP, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success &&  dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                ServiceUtility.hideProgressHudInView()
                self.getGroupDetailWebService()
            }else
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

