//
//  InviteAdminViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import MessageUI
import AVFoundation


class InviteAdminViewController: UIViewController  {
    
    // MARK: - Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var searchContact: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerName: UILabel!
    @IBOutlet var shareView: UIView!
    @IBOutlet var splitView: UISegmentedControl!
    @IBOutlet var subHeadingConstraint: NSLayoutConstraint!
    @IBOutlet var subHeadingView: UIView!
    
    // MARK: - Variables
    var refreshControl: UIRefreshControl!
    var ShareGroupID = ""
    var groupName = ""
    var contactMainArrayList = NSMutableArray()
    var searchContactArrayList = NSMutableArray()
    var seletedArrayList = NSMutableArray()
    var alreadyShareContactArrayList = NSMutableArray()
    var allphonenum:String = ""
    var allname :String = ""
    var prayingCount = 0
    var isadmin = false
    /* At logout or new login
     conatactManger.deleteAllRecord()
     */
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !isadmin
        {
            sendButton.isHidden = true
            shareView.isHidden = true
            splitView.selectedSegmentIndex = 1
            subHeadingView.isHidden = true
            subHeadingConstraint.constant = 0
        }
        conatactManger.deligate = self
        bgView.layer.cornerRadius=21
        shareView.layer.cornerRadius = 10
        shareView.layer.borderColor = UIColor.white.cgColor
        shareView.layer.borderWidth = 1.0
       
        // Array already conatain data from plist
        if groupName != ""
        {
            //headerName.text =  groupName.uppercased() + "'S GROUP ADMINS"
            headerName.text =  groupName.uppercased() + " \(ConstantMessage.kADMINS)"
        }
         self.fetchAlreadyshareArray()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if isadmin
        {
            // check update from background object
            if conatactManger.previousConatctArray.count == 0
            {
                // get from local db
                conatactManger.fetchContactFromList()
                
            }
            // local db is also empty
            if conatactManger.previousConatctArray.count == 0
            {
                conatactManger.getUsercontactContacts()
                // openUploadContactPrompt() // commnet upper line when this uncommented
                
            }else
            {
                contactMainArrayList = conatactManger.previousConatctArray.mutableCopy() as! NSMutableArray
                searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
            }
            
        }
    }
    
    
    func openUploadContactPrompt()
    {
        let alert = UIAlertController(title: ConstantMessage.kUploadContact, message: ConstantMessage.kSharePrayer, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kUpload, style: .cancel, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            conatactManger.getUsercontactContacts()
            
        }))
        alert.addAction(UIAlertAction(title: ConstantMessage.kNotNow, style: .destructive, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetAllSearchData()
    {
        searchContact.text = ""
        if splitView.selectedSegmentIndex == 0
        {
            searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
        }else
        {
            searchContactArrayList = alreadyShareContactArrayList.mutableCopy() as! NSMutableArray
        }
        tableView.reloadData()
        
    }
    func refresh(sender:AnyObject)
    {
        self.searchContact.text = ""
        refreshControl.endRefreshing()
        conatactManger.getUsercontactContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // conatactManger.getContacts()
    }
    
    func fetchAlreadyshareArray()
    {
        
       seletedArrayList.removeAllObjects()
        let tempArray = NSMutableArray()
        for  number in self.alreadyShareContactArrayList
        {
            if ((number as! NSDictionary).object(forKey: ConstantMessage.kUserID) as! String) == UserDefaults.standard.object(forKey: ConstantMessage.kUserId) as! String
            {
               // continue
            }
            
            if (number as! NSDictionary).object(forKey: ConstantMessage.kMobileNo) != nil &&  (number as! NSDictionary).object(forKey: ConstantMessage.kMobileNo) is String
            {
                var name = ((number as! NSDictionary).object(forKey: ConstantMessage.kMobileNo) as! String)
                
                if (number as! NSDictionary).object(forKey: ConstantMessage.kName)  != nil &&  (number as! NSDictionary).object(forKey: ConstantMessage.kName) is String
                {
                    name = (number as! NSDictionary).object(forKey: ConstantMessage.kName)  as! String
                }
                
                let tempDic = NSMutableDictionary()
                tempDic.setValue(((number as! NSDictionary).object(forKey: ConstantMessage.kMobileNo) as! String), forKey: ConstantMessage.kModifiedNo)
                tempDic.setValue(name, forKey: ConstantMessage.kName)
                tempDic.setValue(((number as! NSDictionary).object(forKey: ConstantMessage.kUserID) as! String), forKey: ConstantMessage.kIPrayUser)
                tempDic.setValue("", forKey: ConstantMessage.kISDCode)
                tempDic.setValue(0, forKey: ConstantMessage.kId)
                tempDic.setValue(0, forKey: ConstantMessage.kMobileNo)
                tempArray.add(tempDic.mutableCopy())
                tempDic.removeAllObjects()
            }
            
        }
        
         self.alreadyShareContactArrayList =  tempArray.mutableCopy() as! NSMutableArray
        
        tempArray.removeAllObjects()
        if splitView.selectedSegmentIndex == 1
        {
            searchContactArrayList = alreadyShareContactArrayList
            tableView.reloadData()
        }
    }
    
    // MARK: - Button Action
    @IBAction func cancel(_ sender: UIButton) {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refressContactList(_ sender: UIButton) {
        self.searchContact.text = ""
        conatactManger.getUsercontactContacts()
    }
    
    @IBAction func splitViewValuechange(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        searchContact.text = ""
        if splitView.selectedSegmentIndex == 0
        {
            searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
        }else
        {
            searchContactArrayList = alreadyShareContactArrayList.mutableCopy() as! NSMutableArray
        }
        tableView.reloadData()
    }
    
    @IBAction func resendBtnCliked(_ sender: UIButton) {
        /*
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)! as IndexPath
        
        let tempdic = searchContactArrayList.object(at: cellIndexPath.row) as! NSDictionary
        self.resendPrayerNotificationWebService(friendID: tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String )
        */
    }
    
    
    @IBAction func sendMessage(_ sender: UIButton) {
        self.view.endEditing(true)
        if seletedArrayList.count == 0
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.kSelectContact, delay: ConstantMessage.kDelay)
            return
        }
        self.inviteToGroupWithfriends()
    }
    
    func inviteToGroupWithfriends()
    {
        if  seletedArrayList.count == 0
        {
            
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.kSelectFriends, delay: ConstantMessage.kDelay)
            return
        }
        
        var newUserIdList = ""
        var newMobileList = ""
        for i in 0..<seletedArrayList.count
        {
            let tempdic = seletedArrayList.object(at: i) as! NSDictionary
            if tempdic.object(forKey: ConstantMessage.kIPrayUser) != nil && tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "N/A" || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "" || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "0"
            {
                let number = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
                if newMobileList != ""
                {
                    newMobileList = newMobileList + ","
                }
                newMobileList = newMobileList + number
                
            }else
            {
                let number = tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String
                if newUserIdList != ""
                {
                    newUserIdList = newUserIdList + ","
                }else
                {
                    newUserIdList = newUserIdList + number
                }
            }
        }
        inviteToGroupAdminWebService(userIdList : newUserIdList , mobileList : newMobileList )
    }
    
}

// MARK: - TextField Delegate
extension InviteAdminViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        var tempstring : String = textField.text!
        if string == "" && tempstring.count != 0
        {
            tempstring = String(tempstring.dropLast())
        }else
        {
            tempstring = tempstring + string
        }
        searchFunction(text: tempstring)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        searchFunction(text: textField.text!)
    }
    
    func searchFunction(text : String)
    {
        
        if splitView.selectedSegmentIndex == 0
        {
            if text == ""
            {
                searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
                
            }else
            {
                let searchPresicate = NSPredicate(format: "name contains[cd] %@",text)
                searchContactArrayList = (contactMainArrayList.filtered(using: searchPresicate) as NSArray).mutableCopy() as! NSMutableArray
                
            }
        }else
        {
            if text == ""
            {
                searchContactArrayList = alreadyShareContactArrayList.mutableCopy() as! NSMutableArray
                
            }else
            {
                let searchPresicate = NSPredicate(format: "name contains[cd] %@",text)
                searchContactArrayList = (alreadyShareContactArrayList.filtered(using: searchPresicate) as NSArray).mutableCopy() as! NSMutableArray
                
            }
        }
        tableView.reloadData()
    }
    
}

extension InviteAdminViewController: contactfetchSuccesFully
{
    func reloadview()
    {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantMessage.kContactUploaded), object: nil)
        
        contactMainArrayList  = conatactManger.newContactFromServer.mutableCopy() as! NSMutableArray
        
        
        if splitView.selectedSegmentIndex == 0
        {
            searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
            
        }
        self.tableView.reloadData()
        
    }
    
}

// MARK: - TableView Delegate
extension InviteAdminViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchContactArrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kReuseCell)! as UITableViewCell
        let lable = cell.viewWithTag(1) as! UILabel
        let useLbale = cell.viewWithTag(2) as! UILabel
        let selectedimage = cell.viewWithTag(3) as! UIImageView
        
        
        let tempdic = searchContactArrayList.object(at: indexPath.row) as! NSDictionary
        
        let name = tempdic.object(forKey: ConstantMessage.kName) as! String
        let id = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
        
        lable.text = "\(name)"
        
        if splitView.selectedSegmentIndex == 0
        {
            selectedimage.image = UIImage(named: ConstantMessage.kShareIptay)
            let searchPresicate = NSPredicate(format: "\(ConstantMessage.kModifiedNoContains) %@",id)
            let tempSearchCategory = seletedArrayList.filtered(using: searchPresicate) as NSArray
            if tempSearchCategory.count == 0
            {
                // hide
                selectedimage.isHidden = true
            }else
            {
                // show
                selectedimage.isHidden = false
            }
        }else
        {
            if isadmin
            {
                selectedimage.image = UIImage(named: ConstantMessage.kUnshareIptay)
                selectedimage.isHidden = false
            }else
            {
                selectedimage.image = UIImage(named: "")
                selectedimage.isHidden = true
            }
        }
        
        
         useLbale.isHidden = true
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let tempdic = searchContactArrayList.object(at: indexPath.row) as! NSDictionary
        
        if splitView.selectedSegmentIndex == 1
        {
            if !isadmin
            {
                return
            }
            let alert = UIAlertController(title: ConstantMessage.kRemove, message: ConstantMessage.kWantToRemove, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: ConstantMessage.kNo, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: ConstantMessage.kYes, style: UIAlertAction.Style.default, handler: {
                (alertAction) -> Void in
               self.removeFromGroupWebService(index: indexPath.row)
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let id : String = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
            let searchPresicate = NSPredicate(format: "\(ConstantMessage.kModifiedNoContains) %@",id)
            
            let tempSearchCategory = seletedArrayList.filtered(using: searchPresicate) as NSArray
            
            if tempSearchCategory.count == 0
            {
                seletedArrayList.add(tempdic)
            }else
            {
                seletedArrayList.remove(tempdic)
            }
            
        }
        
        tableView.reloadData()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // self.view.endEditing(true)
    }
}


// MARK: - Web Service
extension InviteAdminViewController
{
    // as per PHP developer we send both user id and mobile id
    func inviteToGroupAdminWebService(userIdList : String , mobileList : String )
    {
        self.view.endEditing(true)
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(ShareGroupID, forKey: ConstantMessage.kGroupID)
        perameter.setValue(userIdList, forKey: ConstantMessage.kFriendID)
        perameter.setValue(mobileList, forKey: ConstantMessage.kMNumber)
        perameter.setValue("1", forKey: ConstantMessage.kIsAdmin)
        ServiceUtility.callWebService(INVITE_TO_GROUP_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success && dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool
            {
                self.navigationController?.popViewController(animated: true)
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
    
    func removeFromGroupWebService(index : Int)
    {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        perameter.setValue("", forKey: ConstantMessage.kFriendID)
        perameter.setValue("", forKey: ConstantMessage.kFriendMobile)
        let tempdic = searchContactArrayList.object(at: index) as! NSDictionary
        if tempdic.object(forKey: ConstantMessage.kIPrayUser) != nil && tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == ConstantMessage.kNA || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "" || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "0"
        {
            perameter.setValue(tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String, forKey: ConstantMessage.kFriendMobile)
        }else{
            perameter.setValue(tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String, forKey: ConstantMessage.kFriendID)
        }
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(ShareGroupID, forKey: ConstantMessage.kGroupID)
        perameter.setValue("1", forKey: ConstantMessage.kAsAdmin)
        ServiceUtility.callWebService(LEAVE_GROUP_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success && dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool
            {
                self.navigationController?.popViewController(animated: true)
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
}



