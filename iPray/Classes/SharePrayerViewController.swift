//
//  SharePrayerViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import MessageUI
import AVFoundation
import ContactsUI
import FirebaseAnalytics

protocol SharePrayerViewControllerProtocol{
    func cancelBtnTapped()
    func shareTagBtnTapped()
}

class SharePrayerViewController: UIViewController, AddNewContactDelegate  {
    // MARK: - Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var searchContact: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerName: UILabel!
    @IBOutlet var shareView: UIView!
    @IBOutlet var splitView: UISegmentedControl!
    @IBOutlet weak var shareBtnTitle: UILabel!
    var delegate : SharePrayerViewControllerProtocol!
    // MARK: - Variables
    var refreshControl: UIRefreshControl!
    var SharePrayerID = ""
    var SharePrayerTitle = ""
    var contactMainArrayList = NSMutableArray()
    var searchContactArrayList = NSMutableArray()
    var seletedArrayList = NSMutableArray()
    var alreadyShareContactArrayList = NSMutableArray()
    var iPrayUserContactList = NSMutableArray()
    var allPhoneNum:String = ""
    var allName :String = ""
    var prayingCount = 0
    var isTag = false
    var isIprayContact = false
    
    //MARK: New CR APR20
    var vctr = UIViewController()
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        bgView.layer.cornerRadius=21
        shareView.layer.cornerRadius = 10
        shareView.layer.borderColor = UIColor.white.cgColor
        shareView.layer.borderWidth = 1.0
        // Array already conatain data from plist
        if SharePrayerTitle != ""
        {
            headerName.text = SharePrayerTitle
        }
        if isTag {
            shareBtnTitle.text = ConstantMessage.kTAG
            splitView.setTitle("\(ConstantMessage.kTagged)(\(alreadyShareContactArrayList.count))", forSegmentAt: 2)
        }else{
            shareBtnTitle.text = ConstantMessage.kSHARE
            splitView.setTitle("\(ConstantMessage.kShared1)(\(prayingCount))", forSegmentAt: 2)
        }
         self.fetchAlreadyshareArray()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        conatactManger.deligate = self
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
            if searchContactArrayList.count > 0{
            //Sorting Alphabetic
            var sortedUsers = searchContactArrayList.sorted {
                (($0 as! NSDictionary).object(forKey: ConstantMessage.kName) as! String).lowercased() > (($1 as! NSDictionary).object(forKey: ConstantMessage.kName) as! String).lowercased()
            }
            sortedUsers.reverse()
            searchContactArrayList = (sortedUsers as NSArray).mutableCopy() as! NSMutableArray
            }
        }
        if isTag && isIprayContact {
            for i in 0..<searchContactArrayList.count{
                let tempdic = searchContactArrayList.object(at: i) as! NSDictionary
                if tempdic.object(forKey: ConstantMessage.kIPrayUser) != nil && (tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == ConstantMessage.kNA || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "" || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "0"){
                }else{
                    iPrayUserContactList.add(tempdic)
                }
            }
            searchContactArrayList = iPrayUserContactList.mutableCopy() as! NSMutableArray
            self.contactMainArrayList = iPrayUserContactList.mutableCopy() as! NSMutableArray
        }
        // resetAllSearchData()
    }
    
    // MARK: - Button Action
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
        
        //changes for updating share and tag
        if splitView.selectedSegmentIndex == 2{
            if isTag {
                shareBtnTitle.text = ConstantMessage.kTagging.capitalized
                splitView.setTitle("\(ConstantMessage.kTagged)(\(searchContactArrayList.count))", forSegmentAt: 2)
            }else{
                shareBtnTitle.text = ConstantMessage.kSHARE
                splitView.setTitle("\(ConstantMessage.kShared1)(\(searchContactArrayList.count))", forSegmentAt: 2)
            }
        }
        //Changes Done
        tableView.reloadData()
    }
    
    func refresh(sender:AnyObject)
    {
        self.searchContact.text = ""
        refreshControl.endRefreshing()
        conatactManger.getUsercontactContacts()
    }
    
    func fetchAlreadyshareArray()
    {
       seletedArrayList.removeAllObjects()
        let tempArray = NSMutableArray()
        for  number in self.alreadyShareContactArrayList
        {
            if (number as! NSDictionary).object(forKey: ConstantMessage.kNumber) != nil &&  (number as! NSDictionary).object(forKey: ConstantMessage.kNumber) is String
            {
                var name = ((number as! NSDictionary).object(forKey: ConstantMessage.kNumber) as! String)
                if (number as! NSDictionary).object(forKey: ConstantMessage.kName)  != nil &&  (number as! NSDictionary).object(forKey: ConstantMessage.kName) is String
                {
                    name = (number as! NSDictionary).object(forKey: ConstantMessage.kName)  as! String
                }
                let tempDic = NSMutableDictionary()
                tempDic.setValue(((number as! NSDictionary).object(forKey: ConstantMessage.kName) as! String), forKey: ConstantMessage.kModifiedNo)
                tempDic.setValue(name, forKey: ConstantMessage.kName)
                tempDic.setValue(((number as! NSDictionary).object(forKey: ConstantMessage.kUserID) as! String), forKey: ConstantMessage.kIPrayUser)
                tempDic.setValue("", forKey: ConstantMessage.kISDCode)
                tempDic.setValue(0, forKey: ConstantMessage.kId)
                tempDic.setValue(0, forKey: ConstantMessage.kMobileNo)
                tempArray.add(tempDic.mutableCopy())
                tempDic.removeAllObjects()
            }
            else if (number as! NSDictionary).object(forKey: ConstantMessage.kMobileNo) != nil &&  (number as! NSDictionary).object(forKey: ConstantMessage.kMobileNo) is String
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
        self.seletedArrayList =  tempArray.mutableCopy() as! NSMutableArray
        tempArray.removeAllObjects()
        if splitView.selectedSegmentIndex == 2
        {
            searchContactArrayList = alreadyShareContactArrayList
            tableView.reloadData()
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.view.endEditing(true)
        if  self.alreadyShareContactArrayList.count == self.seletedArrayList.count || self.seletedArrayList.count == 0
        {
             self.vctr.view.isHidden = false
             self.dismiss(animated: true, completion: nil)
            if self.delegate != nil{
                self.delegate.cancelBtnTapped()
            }
        }else{
            let alert = UIAlertController(title: ConstantMessage.kFYI, message: "\(ConstantMessage.kSelectionWithout) \((self.isTag) ? ConstantMessage.kTagging : ConstantMessage.kSharing) yet.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: ConstantMessage.kExit, style: .cancel, handler: {
            (alertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
                self.vctr.view.isHidden = false
                if self.delegate != nil{
                    self.delegate.shareTagBtnTapped()
                }
            }))
            alert.addAction(UIAlertAction(title: "\((self.isTag) ? ConstantMessage.kTagging : ConstantMessage.kSharing)", style: UIAlertAction.Style.default, handler: {
                (alertAction) -> Void in
                 self.sharePrayerWithfriends()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK:- Button Action
    @IBAction func refressContactList(_ sender: UIButton) {
        self.searchContact.text = ""
        conatactManger.getUsercontactContacts()
       // ServiceUtility.showMessageHudWithMessage("Please be patient, Your contact list is updating.", delay: ConstantMessage.kDelay)
    }
    
    @IBAction func splitViewValuechange(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        searchContact.text = ""
        if splitView.selectedSegmentIndex == 0
        {
            searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
        }else if splitView.selectedSegmentIndex == 1
        {
            searchContactArrayList = filterIprayList()
            self.iPrayUserContactList = searchContactArrayList;
        }
        else
        {
            searchContactArrayList = alreadyShareContactArrayList.mutableCopy() as! NSMutableArray
        }
        tableView.reloadData()
    }
    
    @IBAction func resendBtnCliked(_ sender: UIButton) {
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)! as IndexPath
        let tempdic = searchContactArrayList.object(at: cellIndexPath.row) as! NSDictionary
        self.resendPrayerNotificationWebService(friendID: tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String )
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        self.view.endEditing(true)
        if seletedArrayList.count == 0
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.kSelectFriends, delay: ConstantMessage.kDelay)
            return
        }
       
        if self.vctr is AddPrayerViewController{
            let tempVCTR =  self.vctr  as! AddPrayerViewController
            tempVCTR.removefromsuperview()
        }
       self.sharePrayerWithfriends()
    }
    
    @IBAction func addNewContactBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddNewContactViewController) as! AddNewContactViewController
        vc.delegate = self
        vc.SharePrayerID = SharePrayerID
        if isTag{
            vc.isTag = true
            vc.btnName = ConstantMessage.kAddAndTag
        }else{
            vc.isTag = false
            vc.btnName = ConstantMessage.kAddAndShare
        }
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
    
    func referesgListAfterAdd(contactList: NSArray) {
        //self.searchContactArrayList = contactList.mutableCopy() as! NSMutableArray
        iPrayUserContactList.removeAllObjects()
        if isTag && isIprayContact {
            for i in 0..<contactList.count{
                let tempdic = contactList.object(at: i) as! NSDictionary
                if tempdic.object(forKey: ConstantMessage.kIPrayUser) != nil && (tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == ConstantMessage.kNA || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "" || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "0"){
                }else{
                    iPrayUserContactList.add(tempdic)
                }
            }
            if splitView.selectedSegmentIndex == 0
            {
                searchContactArrayList.removeAllObjects()
                searchContactArrayList = iPrayUserContactList.mutableCopy() as! NSMutableArray
            }
            contactMainArrayList.removeAllObjects()
            self.contactMainArrayList = iPrayUserContactList.mutableCopy() as! NSMutableArray
        }else{
            self.contactMainArrayList = contactList.mutableCopy() as! NSMutableArray
            if splitView.selectedSegmentIndex == 0
            {
                searchContactArrayList = contactMainArrayList.mutableCopy() as! NSMutableArray
            }
        }
        self.tableView.reloadData()
    }
    
    func updateseletedArrayList(contactList: NSArray){
        seletedArrayList = contactList.mutableCopy() as! NSMutableArray
    }
    
    func sharePrayerWithfriends()
//    func sharePrayerWithfriends(contactList: NSArray)
    {
     //   let  deletedArrayList = findDeletedContact()
        let newcontactArrayList = findThenewContactShared()
        if  newcontactArrayList.count == 0 //&&deletedArrayList.count == 0
        {
            if isTag {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.kAlreadySharedWithFriends, delay: ConstantMessage.kDelay)
            }else{
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.kAlreadyTaggedWithFriends, delay: ConstantMessage.kDelay)
            }
            return
        }
        
        var newcontactString = ""
        for var i in 0..<newcontactArrayList.count
        {
            i = i + 0
            let tempdic = newcontactArrayList.object(at: i) as! NSDictionary
            let number = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
            if i != 0
            {
                newcontactString = newcontactString + ","
            }
            newcontactString = newcontactString + number
        }
        self.sharePrayerWebService(friendsList: newcontactString , deletedcontact : "" , deleteIndexPath: -1)
    }
    
    func findThenewContactShared() -> NSMutableArray
    {
        let newcontactArray = NSMutableArray()
        for var index in 0..<seletedArrayList.count
        {
            index = index + 0
            let tempdic = seletedArrayList.object(at: index) as! NSDictionary
            let mobile_no = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
            let searchPresicate = NSPredicate(format: "\(ConstantMessage.kModifiedNoContains) %@",mobile_no)
            let tempSearchCategory = alreadyShareContactArrayList.filtered(using: searchPresicate) as NSArray
            if tempSearchCategory.count == 0
            {
                newcontactArray.add(tempdic)
            }
        }
        return newcontactArray
    }
    
    //Filter iPray List
    func filterIprayList() -> NSMutableArray
    {
        let newcontactArray = NSMutableArray()
        for var index in 0..<contactMainArrayList.count
        {
            index = index + 0
            let tempdic = contactMainArrayList.object(at: index) as! NSDictionary
            let iPrayUser = tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String
            if iPrayUser != ConstantMessage.kNA{
                newcontactArray.add(tempdic)
            }
        }
        return newcontactArray
    }
    
    func findDeletedContact() -> NSMutableArray
    {
        let deletedContactArray = NSMutableArray()
        for var index in 0..<alreadyShareContactArrayList.count
        {
            index = index + 0
            let tempdic = alreadyShareContactArrayList.object(at: index) as! NSDictionary
            let mobile_no = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
            let searchPresicate = NSPredicate(format: "\(ConstantMessage.kModifiedNoContains) %@",mobile_no)
            let tempSearchCategory = seletedArrayList.filtered(using: searchPresicate) as NSArray
            if tempSearchCategory.count == 0
            {
                deletedContactArray.add(tempdic)
            }
        }
        return deletedContactArray
    }
}

// MARK: - TextField Delegate
extension SharePrayerViewController : UITextFieldDelegate
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
        }else if splitView.selectedSegmentIndex == 1
        {
            if text == ""
            {
                searchContactArrayList = iPrayUserContactList.mutableCopy() as! NSMutableArray
            }else
            {
                let searchPresicate = NSPredicate(format: "name contains[cd] %@",text)
                searchContactArrayList = (iPrayUserContactList.filtered(using: searchPresicate) as NSArray).mutableCopy() as! NSMutableArray
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

extension SharePrayerViewController: contactfetchSuccesFully
{
    func reloadview()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantMessage.kContactUploaded), object: nil)
        contactMainArrayList  = conatactManger.newContactFromServer.mutableCopy() as! NSMutableArray
        referesgListAfterAdd(contactList: contactMainArrayList)
        self.tableView.reloadData()
    }
}

// MARK: - TableView Delegate
extension SharePrayerViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchContactArrayList.count > 0 {
             return searchContactArrayList.count
        }else{
             return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if searchContactArrayList.count > 0 {
            let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kReuseCell)! as UITableViewCell
            let lable = cell.viewWithTag(1) as! UILabel
            let useLbale = cell.viewWithTag(2) as! UILabel
            let selectedimage = cell.viewWithTag(3) as! UIImageView
            let resendBtn = cell.viewWithTag(-2) as! UIButton
            let tempdic = searchContactArrayList.object(at: indexPath.row) as! NSDictionary
            let name = tempdic.object(forKey: ConstantMessage.kName) as! String
            let id = tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String
            if name != "" {
                lable.text = "\(name)"
            }else{
                lable.text = "\(id)"
            }
            
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
            }else if splitView.selectedSegmentIndex == 1
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
                if isTag{
                    selectedimage.isHidden = true
                }else{
                    selectedimage.image = UIImage(named: ConstantMessage.kUnshareIptay)
                    selectedimage.isHidden = false
                }
            }
            
            if tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == ConstantMessage.kNA || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "" || tempdic.object(forKey: ConstantMessage.kIPrayUser) as! String == "0"
            {
                if splitView.selectedSegmentIndex == 0
                {
                    // hide
                    useLbale.isHidden = true
                    resendBtn.isHidden = true
                }else
                {
                    // show
                    if isTag{
                        useLbale.isHidden = true
                        resendBtn.isHidden = true
                    }else{
                        useLbale.isHidden = false
                        useLbale.text = ConstantMessage.kResend
                        resendBtn.isHidden = false
                    }
                }
            }else
            {
                // show
                useLbale.text = ConstantMessage.kUSESiPray
                useLbale.isHidden = false
                resendBtn.isHidden = true
            }
            cell.selectionStyle = .none
            return cell
        }else{
            let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kNoRecordCell)! as UITableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if (searchContactArrayList.count > 0){
            let tempdic = searchContactArrayList.object(at: indexPath.row) as! NSDictionary
            if splitView.selectedSegmentIndex == 2
            {
                if !isTag {
                    let alert = UIAlertController(title: ConstantMessage.kUnshare, message: ConstantMessage.kUnsharePrayer, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: ConstantMessage.kNo, style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: ConstantMessage.kYes, style: UIAlertAction.Style.default, handler: {
                        (alertAction) -> Void in
                        self.sharePrayerWebService(friendsList: "" , deletedcontact : tempdic.object(forKey: ConstantMessage.kModifiedNo) as! String ,deleteIndexPath: indexPath.row)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }else{
                    return
                }
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
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}


// MARK: - Web Service
extension SharePrayerViewController
{
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
       
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: (isTag ? ConstantMessage.kTag : ConstantMessage.kShare) + "_" + "\(UserManager.shareManger.userName!)_\(SharePrayerTitle)",
            AnalyticsEventSelectItem:(isTag ? ConstantMessage.kTag : ConstantMessage.kShare),
            AnalyticsParameterValue : UserManager.shareManger.userID!,
            AnalyticsParameterItemName : (isTag ? ConstantMessage.kTag : ConstantMessage.kShare)
        ])
        
        
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer .setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:ConstantMessage.kAPIKEY)
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
                        if self.isTag{
                            if(Utility.shareUtility.getTagUserDefaults()){
                            ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                                 let delayInSeconds = 1.0
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            }else{
                                Utility.shareUtility.showPopUpWith(title: (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString) as String, desc: ConstantMessage.kInviation, buttonName: ConstantMessage.ksubmit, view: self.view,delegate:self)
                            }
                           
                        }else{
                            if(Utility.shareUtility.getShareUserDefaults()){
                            ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                                 let delayInSeconds = 1.0
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            }else{
                                Utility.shareUtility.showPopUpWith(title: (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString) as String, desc: ConstantMessage.kShared, buttonName: ConstantMessage.ksubmit, view: self.view,delegate:self)
                            }
                            
                        }
                       
                    }else
                    {
                        self.seletedArrayList.remove( self.alreadyShareContactArrayList.object(at: deleteIndexPath))
                        self.alreadyShareContactArrayList.removeObject(at: deleteIndexPath)
                        self.resetAllSearchData()
                    }
                    if self.delegate != nil{
                        self.delegate.shareTagBtnTapped()
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
    
    func resendPrayerNotificationWebService(friendID :String)
    {
        self.view.endEditing(true)
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(friendID, forKey: ConstantMessage.kFriendMobileNo)
        perameter.setValue(SharePrayerID, forKey: ConstantMessage.kPrayerID)
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer .setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField: ConstantMessage.kAPIKEY)
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        manager.post(RESEND_PRAYER_URL, parameters: perameter, progress: nil, success:
            {
                requestOperation, response  in
                ServiceUtility.hideProgressHudInView()
                let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
        }, failure: {
            requestOperation, error in
            ServiceUtility.hideProgressHudInView()
            ServiceUtility.hideProgressHudInView()
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
        })
    }
}

extension SharePrayerViewController : UtilityProtocol{
    func submitBtnActionWith(isChecked : Bool){
        let subViews = self.view.subviews
        subViews.last?.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
        if self.isTag{
            Utility.shareUtility.setTagUserDefaults(isChecked: isChecked)
        }else{
            Utility.shareUtility.setShareUserDefaults(isChecked: isChecked)
        }
    }
    
    func cancel(){
        let subViews = self.view.subviews
        subViews.last?.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
}


