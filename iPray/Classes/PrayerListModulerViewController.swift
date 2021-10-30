//
//  PrayerListModulerViewController.swift
//  iPray
//
//  Created by Zeba on 10/6/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import FirebaseAnalytics

@objc protocol PrayerListModulerDeligate {
    @objc optional func changeHeaderName(name : String)
    @objc optional func notificaitonCount(notificationCount : Int)
    @objc optional func invitationCount(invitationCount : Int)
    @objc optional func openAddprayerPopViewController(prayerData : NSDictionary,isupdate: Bool,isreminder: Bool,isOnlyReminder : Bool)
}

class PrayerListModulerViewController: UIViewController , UIGestureRecognizerDelegate{
    
    // MARK: - variables
    var delegate : PrayerListModulerDeligate!
    let manager = AFHTTPSessionManager()
    var tapGesture = UITapGestureRecognizer()
    var refreshControl: UIRefreshControl!
    var notFoundLable : UILabel!
    var prayerListDataArray = NSMutableArray()
    var selectedPopUpIndex : Int = -1
    var friendsUSerId :String = ""
    var prayerURL :String = ""
    var prayerId : String = ""
    var searchText : String = ""
    var PageNo = 1
    var notificationCount : Int = 0
    
    //New changes
    let kSharingTitle = ConstantMessage.kiPraySharing;
    let kSharingSubTitle = ConstantMessage.kAskSomeoneToPray
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableView.automaticDimension
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(PrayerListModulerViewController.handleOnTapOnBackgroud))
        tapGesture.delegate = self
        
        // Refresh tableView
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: ConstantMessage.kPullToRefresh)
        refreshControl.addTarget(self, action: #selector(pulltoRrefresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        let nib = UINib.init(nibName: iPrayIdentifier.kPrayerTableViewCell, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: iPrayIdentifier.kPrayerTableViewCell)
        tableView.reloadData()
    }
    
    func reloadPrayerTableview()
    {
        self.tableView.reloadData()
    }
    
    @objc func pulltoRrefresh(sender:AnyObject) {
        self.PageNo = 1
        self.prayerId = ""
        refreshControl.endRefreshing()
        self.getprayerListWebService()
    }
}

// MARK: - TableView Delegate
extension PrayerListModulerViewController : PrayerTableViewCellProtocol
{
    func PrayerActionButtonCliked(index : Int,action : Int)
    {
        switch action {
        case 1: debugPrint("start prayer")
        self.startPrayerWebServices(prayerIndex: index)
            break
        case 2: debugPrint("share prayer")
        self.openShareViewController(prayerData: self.prayerListDataArray[index] as! NSDictionary)
            break
        case 3: debugPrint("Edit pop up")
        self.selectedPopUpIndex = index
        editPrayerPopUpMenuBtnCliked()
            break
        case 4: debugPrint("see more")
        self.seeMoreBtncliked(cellIndex: index)
            break
        case 5: debugPrint("Answered")
        self.answerPrayerWebServices(index : index)
            break
        case 6: debugPrint("Tag prayer")
        self.openTagViewController(prayerData: self.prayerListDataArray[index] as! NSDictionary)
            break
        default:
            debugPrint("Pop up Index")
            self.prayerPopUpActionBtnCliked(indexRow: index, Buttontag: action)
        }
    }
}

// MARK: - Prayer functionality
extension PrayerListModulerViewController{
    
    @objc func handleOnTapOnBackgroud(){
       self.selectedPopUpIndex = -1
       self.tableView.reloadData()
       self.view.removeGestureRecognizer(tapGesture)
    }
    
   func scroltableviewToIndex(Index : Int){
       if Index + 1 < 10
       {
           self.tableView.selectRow(at: IndexPath(item: Index + 1 , section: 0) , animated: true , scrollPosition: UITableView.ScrollPosition.none)
       }
   }
    
   func editPrayerPopUpMenuBtnCliked() {
     self.tableView.reloadData()
     scroltableviewToIndex(Index: self.selectedPopUpIndex)
     self.view.addGestureRecognizer(tapGesture)
   }
    
   func seeMoreBtncliked(cellIndex : Int) {
    let data = (self.prayerListDataArray[cellIndex] as! NSDictionary).mutableCopy() as! NSMutableDictionary
    if data.object(forKey: ConstantMessage.kShowfull) as! Bool
    {
        data.setValue(false, forKey: ConstantMessage.kShowfull)
    }else
    {
        data.setValue(true, forKey: ConstantMessage.kShowfull)
    }
    self.prayerListDataArray.replaceObject(at: cellIndex, with: data)
    self.tableView.reloadData()
    scroltableviewToIndex(Index: cellIndex)
   }
    
}
//MARK:  - Share
extension PrayerListModulerViewController{
    func openShareViewController(prayerData : NSDictionary) {
        if prayerData.object(forKey: ConstantMessage.kCopiedPrayer) != nil &&  prayerData.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1" && prayerData.object(forKey: ConstantMessage.kIsShareble) != nil &&  prayerData.object(forKey: ConstantMessage.kIsShareble) as! String == "1"
        {
            let alert = UIAlertController(title: self.kSharingTitle, message: self.kSharingSubTitle, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: ConstantMessage.kMyContacts, style: .default, handler: {
                (alertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
                self.sharewithContact(prayerData : prayerData, isIprayContact: false, isTag: false)
            }))
            alert.addAction(UIAlertAction(title: ConstantMessage.kExternal, style: .default, handler: {
                (alertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
                let newdata : NSMutableDictionary = prayerData.mutableCopy() as! NSMutableDictionary
                newdata.setValue(prayerData.object(forKey: ConstantMessage.kSenderName) as! String, forKey: ConstantMessage.kGroupName)
                ApplicationDelegate.shareLinkBeyondTheApp(groupData :newdata, isPrayerTitle: true, isTag: false)
            }))
            alert.addAction(UIAlertAction(title: ConstantMessage.kCancel, style: .destructive, handler: {
                (alertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }else
        {
            self.sharewithContact(prayerData : prayerData, isIprayContact: false, isTag: false)
        }
    }
    
    func sharewithContact(prayerData : NSDictionary,isIprayContact:Bool, isTag:Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagPrayerPopUpViewController) as! TagPrayerPopUpViewController
        vc.delegate = self
        vc.dataDict = prayerData
        vc.type = ConstantMessage.kshare
        vc.isTag = isTag
        vc.isIprayContact = isIprayContact
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.addChild(vc)
        self.view.addSubview(vc.view)
    }
}
//MARK:- Tag
extension PrayerListModulerViewController : TagPrayerPopUpDelegate
{
    func openTagViewController(prayerData : NSDictionary) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagPrayerPopUpViewController) as! TagPrayerPopUpViewController
        vc.delegate = self
        vc.dataDict = prayerData
        vc.type = ConstantMessage.ktag
        vc.isTag = true
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.addChild(vc)
        self.view.addSubview(vc.view)
    }
    
    func tagPopUpBtnClicked(actionType: Int, data: NSDictionary,isTagging : Bool) {
        
        switch actionType {
        case 1:
             self.sharewithContact(prayerData : data, isIprayContact: true, isTag: true)
        case 2:
             self.sharewithContact(prayerData : data, isIprayContact: false, isTag: true)
        case 1000:
            if (self.navigationController?.viewControllers.count)! > 0{
                let viewControllers = self.navigationController?.viewControllers
                if viewControllers!.count > 1{
                    for item in viewControllers![1].children{
                        if item is AddPrayerViewController{
                            let VCTR = item as! AddPrayerViewController
                            VCTR.view.isHidden = false
                        }
                    }
                }
            }
        default:
            let newdata : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
            if newdata.count > 0 {
                if let title =  data.object(forKey: ConstantMessage.kTitle) as? String,title.count > 0{
                   newdata.setValue(title, forKey: ConstantMessage.kGroupName)
                }else{
                    newdata.setValue("", forKey: ConstantMessage.kGroupName)
                }
                var vctr = UIViewController()
               if (self.navigationController?.viewControllers.count)! > 0{
                   let viewControllers = self.navigationController?.viewControllers
                   if viewControllers!.count > 1{
                    for item in viewControllers![1].children{
                        if item is AddPrayerViewController{
                            vctr = item
                        }
                    }
                   }
               }
                ApplicationDelegate.shareLinkBeyondTheApp(groupData :newdata, isPrayerTitle: true, isTag: isTagging,vctr:vctr)
            }
        }
    }
    
    func prayerPopUpActionBtnCliked(indexRow : Int, Buttontag : Int) {
        let data =  self.prayerListDataArray[indexRow] as! NSDictionary
        switch Buttontag{
        case -11:// update prayer
            // restrick user to update the group prayer
            if !(data.object(forKey: ConstantMessage.kCopiedPrayer) != nil &&  data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1")
            {
                handleOnTapOnBackgroud()
                self.delegate.openAddprayerPopViewController!(prayerData: data, isupdate: true, isreminder: false, isOnlyReminder: false)
            }
            break
        case -12:// se as answered
                answerPrayerWebServices(index : indexRow)
            break
        case -13:// remove prayer
            self.openRemovePrayerPrompt(prayerIndex: indexRow)
            break
        case -22:// set reminder prayer
            if (data.object(forKey: ConstantMessage.kCopiedPrayer) != nil &&  data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1")
            {
                self.delegate.openAddprayerPopViewController!(prayerData: data, isupdate: true, isreminder: false, isOnlyReminder: true)
            }else{
                 self.delegate.openAddprayerPopViewController!(prayerData: data, isupdate: false, isreminder: true, isOnlyReminder: false)
            }
            break
        case -23:// remove  reminder prayer
            self.openRemovePrayerPrompt(prayerIndex: indexRow)
            break
        default:
            break
        }
    }
    
    func openRemovePrayerPrompt(prayerIndex : Int){
        let alert = UIAlertController(title: ConstantMessage.kRemovePrayer, message: ConstantMessage.kWantToRemove, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kYes, style: .default, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            
            self.removePrayerWebServices(prayerIndex: prayerIndex)
            
        }))
        
        alert.addAction(UIAlertAction(title: ConstantMessage.kNo, style: .destructive, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - TableView Delegate
extension PrayerListModulerViewController: UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if prayerListDataArray.count == 0
        {
            return 1
        }
        return prayerListDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if prayerListDataArray.count == 0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kNoCell)! as UITableViewCell
            notFoundLable = cell.viewWithTag(1) as? UILabel
            if !(self.delegate is SearchIprayViewController)
            {
                notFoundLable.text = ConstantMessage.kSearching
            }
            cell.selectionStyle = .none
            return cell
        } else{
            let data = self.prayerListDataArray[indexPath.row] as! NSDictionary
            let cell = tableView.dequeueReusableCell(withIdentifier: iPrayIdentifier.kPrayerTableViewCell)! as! PrayerTableViewCell
            cell.tag = indexPath.row
            cell.cellIndex = indexPath.row
            cell.degligatePrayerTableViewCell = self
            cell.loadData(data: data, indexPath: indexPath.row, selectedPopUpIndex: selectedPopUpIndex,tableView : tableView)
            if self.prayerListDataArray.count == indexPath.row + 1 && self.prayerListDataArray.count % ConstantMessage.pagingConstant == 0
            {
                PageNo = PageNo + 1
                self.getprayerListWebService()
            }
            return cell
        }
    }
}

// MARK: - Web Service
extension PrayerListModulerViewController
{
    // New
    func getprayerListWebService()
    {
        self.selectedPopUpIndex = -1
        let parameter = NSMutableDictionary()
        parameter.setValue(friendsUSerId, forKey: ConstantMessage.kFriendID)
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(prayerId, forKey: ConstantMessage.kPrayerID)
        parameter.setValue(PageNo, forKey: ConstantMessage.kPage)
        parameter.setValue(searchText, forKey: ConstantMessage.kSearchText)
        if prayerURL  == ADOPTED_PRAYER_URl
        {
            parameter.setValue(friendsUSerId, forKey: ConstantMessage.kFriendUserID)
        }
        if notFoundLable != nil
        {
            notFoundLable.text = ConstantMessage.kSearching
        }
        if searchText != ""
        {
            manager.operationQueue.cancelAllOperations()
        }
        ServiceUtility.callWebService(prayerURL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    var serverData = NSMutableArray()
                    // check bc of server Data type changes
                    if self.prayerId == ""
                    {
                        serverData = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray).mutableCopy() as! NSMutableArray
                        
                    }else
                    {
                        serverData.add(dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    }
                    let serverdata =  ApplicationDelegate.sortPrayerUsingPrayStatus(prayerList:serverData)
                    
                    //new Soarting based on date (NEW CR 15THAPRILSB)
                    let soartDescriptor = NSSortDescriptor(key: ConstantMessage.kUpdatedOn, ascending: false)
                       let soartserverData  = serverData.sortedArray(using: [soartDescriptor])
                       serverData = NSMutableArray(array: soartserverData)
                    
                    
                    if self.PageNo == 1
                    {
                        self.prayerListDataArray.removeAllObjects()
                        self.prayerListDataArray = serverdata.mutableCopy() as! NSMutableArray
                        
                    }else
                    {
                        self.prayerListDataArray.addObjects(from: serverdata.mutableCopy() as! [Any])
                        
                    }
                    // Manage badge
                    if self.prayerId != ""
                    {
                        self.notificationCount = 0
                        
                    }else
                    {
                        var myDewContact : Int = 0
                        var totalOtherDew : Int = 0
                        var tagRequestCount = 0
                        
                        if dataFromServer.object(forKey: ConstantMessage.kMyDuecount) != nil && dataFromServer.object(forKey: ConstantMessage.kMyDuecount)! as! Int != 0
                        {
                            myDewContact = (dataFromServer.object(forKey: ConstantMessage.kMyDuecount) as! Int)
                        }
                        
                        if  dataFromServer.object(forKey: ConstantMessage.kOtherduecount) != nil
                        {
                            
                            totalOtherDew =  (dataFromServer.object(forKey: ConstantMessage.kOtherduecount) as! Int)
                        }
                        if dataFromServer.object(forKey: ConstantMessage.kTaggedInvitation) != nil && dataFromServer.object(forKey: ConstantMessage.kTaggedInvitation) as! Int != 0
                        {
                            tagRequestCount = (dataFromServer.object(forKey: ConstantMessage.kTaggedInvitation) as! Int)
                        }
                        // set batch to app icon
                        UIApplication.shared.applicationIconBadgeNumber  = myDewContact +  totalOtherDew
                        self.delegate.invitationCount?(invitationCount: tagRequestCount)
                        
                        if self.delegate is ShowPrayerListViewController
                        {
                            self.notificationCount = myDewContact
                            
                        }else if self.delegate is PrayerRequestViewController
                        {
                            
                            self.notificationCount = totalOtherDew
                            
                            // if its single friend request prayer list
                            if (self.friendsUSerId != "")
                            {
                                if  self.prayerListDataArray.count != 0
                                {
                                    let data =  self.prayerListDataArray.object(at: 0) as! NSDictionary
                                    self.delegate.changeHeaderName!(name: data[ConstantMessage.kSenderName] as! String)
                                }
                                
                                if  dataFromServer.object(forKey: ConstantMessage.kOtherUserDue) != nil
                                {
                                    if dataFromServer.object(forKey: ConstantMessage.kOtherUserDue) is String && dataFromServer.object(forKey: ConstantMessage.kOtherUserDue) as! String != ""
                                    {
                                        self.notificationCount = Int(dataFromServer.object(forKey: ConstantMessage.kOtherUserDue) as! String)!
                                    }else if dataFromServer.object(forKey: ConstantMessage.kOtherUserDue) is Int
                                    {
                                        self.notificationCount = (dataFromServer.object(forKey: ConstantMessage.kOtherUserDue) as! Int)
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    if !(self.delegate is SearchIprayViewController)
                    {
                        self.delegate.notificaitonCount!(notificationCount: self.notificationCount)
                    }
                    
                    if self.delegate is SearchIprayViewController && self.searchText.trimmingCharacters(in: CharacterSet.whitespaces) == ""
                    {
                        self.prayerListDataArray.removeAllObjects()
                    }
                    
                }
                else
                {
                    if self.delegate is SearchIprayViewController
                    {
                        self.prayerListDataArray.removeAllObjects()
                    }
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
                    
                }
            }
            else
            {
            
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
            
            if self.notFoundLable != nil &&  self.prayerListDataArray.count == 0
            {
                self.notFoundLable.text = ConstantMessage.NotFound as String
            }
            
            self.tableView.reloadData()
            
        }
    }
    
    func removePrayerWebServices(prayerIndex : Int) {
        let tempdata = (self.prayerListDataArray[prayerIndex] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let perameter = NSMutableDictionary()
        perameter.setValue(tempdata[ConstantMessage.kPrayerID] as! String, forKey: ConstantMessage.kPrayerID)
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        var tempURL = REMOVE_NOTIFICATION_PRAYER_URL
        // if self prayer then
        if ((tempdata.object(forKey: ConstantMessage.kUserID) != nil) && (tempdata.object(forKey: ConstantMessage.kUserID) as! String == UserManager.shareManger.userID!)) || ((tempdata.object(forKey: ConstantMessage.kCopiedPrayer) != nil) && (tempdata.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1"))
        {
            tempURL = REMOVE_PRAYER_URL
        }
        ServiceUtility.callWebService(tempURL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    newNotificationCome = true
                    if  self.notificationCount != 0
                    {
                        let prayercurrentStatus = ApplicationDelegate.checkPrayerStatus(prayerData: tempdata)
                        if prayercurrentStatus == 1 || prayercurrentStatus == 3
                        {
                            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
                            self.notificationCount = self.notificationCount - 1
                            self.delegate.notificaitonCount!(notificationCount: self.notificationCount)
                        }
                    }
                    self.prayerListDataArray.removeObject(at: prayerIndex)
                    self.handleOnTapOnBackgroud()
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
    
    func answerPrayerWebServices(index : Int) {
        
        let tempdata = (self.prayerListDataArray[index] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        // restrick user to update the group prayer
        if (tempdata.object(forKey: ConstantMessage.kCopiedPrayer) != nil &&  tempdata.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1")
        {
           return
        }
        
        var status = "0"
        if tempdata[ConstantMessage.kSetAnswered] as! String == "0"
        {
            status = "1"
        }
        
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(tempdata[ConstantMessage.kPrayerID] as! String, forKey: ConstantMessage.kPrayerID)
        perameter.setValue(status, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebService(ANSWER_PRAYER_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    newNotificationCome = true
                    let prayercurrentStatus = ApplicationDelegate.checkPrayerStatus(prayerData: tempdata)
                    
                    if prayercurrentStatus == 2 || prayercurrentStatus == 4
                    {
                        self.notificationCount = self.notificationCount + 1
                        self.delegate.notificaitonCount!(notificationCount: self.notificationCount)
                        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                    }
                    
                    tempdata.setValue(status, forKey: ConstantMessage.kSetAnswered)
                    tempdata.setValue( dataFromServer.object(forKey: ConstantMessage.kAnsweredTime), forKey: ConstantMessage.kAnsweredTime)
                    tempdata.setValue("1", forKey: ConstantMessage.kStatus)
                    self.prayerListDataArray.replaceObject(at: index, with: tempdata)
                    self.handleOnTapOnBackgroud()
                    
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
    
    func startPrayerWebServices(prayerIndex : Int) {
        
        let tempPrayerIndexdata = (self.prayerListDataArray.object(at: prayerIndex) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let status = ApplicationDelegate.prayerStatusForPraying(prayerData : tempPrayerIndexdata)
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(tempPrayerIndexdata.object(forKey: ConstantMessage.kPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        perameter.setValue(status, forKey: ConstantMessage.kStatus)
        
        var urlString = START_PRAYER_URL
        if tempPrayerIndexdata.object(forKey: ConstantMessage.kTotalTagged) != nil && tempPrayerIndexdata.object(forKey: ConstantMessage.kTotalTagged) is String && tempPrayerIndexdata.object(forKey: ConstantMessage.kTotalTagged) as! String != "0" {
            urlString = PRAY_FOR_ALL
        }
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: ((status == 1) ? ConstantMessage.kPray : ConstantMessage.kPrayed) + "_" + "\(UserManager.shareManger.userName!)_\(tempPrayerIndexdata.value(forKey: ConstantMessage.kSenderName) as! String)",
            AnalyticsEventSelectItem:(status == 1) ? ConstantMessage.kPray : ConstantMessage.kPrayed,
            AnalyticsParameterValue : UserManager.shareManger.userID!,
            AnalyticsParameterItemName : ((status == 1) ? ConstantMessage.kPray : ConstantMessage.kPrayed)
            // AnalyticsEventScreenView:"LoginScreen"
        ])
         
        ServiceUtility.callWebServiceWithoutProgressMessage(urlString, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
   
            if success {
                
                // do chnage in views
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    newNotificationCome = true
                    
                    let prayercurrentStatus = ApplicationDelegate.checkPrayerStatus(prayerData: tempPrayerIndexdata)
                    
                    if prayercurrentStatus == 2 || prayercurrentStatus == 4
                    {
                        tempPrayerIndexdata.setValue("1", forKey: ConstantMessage.kStatus)
                        self.notificationCount = self.notificationCount + 1
                        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
                    }else
                    {
                        tempPrayerIndexdata.setValue("0", forKey: ConstantMessage.kStatus)
                       self.notificationCount = self.notificationCount - 1
                        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
                    }
                    self.delegate.notificaitonCount!(notificationCount: self.notificationCount)
                    if prayercurrentStatus == 1
                    {
                        var count = Int(tempPrayerIndexdata.object(forKey: ConstantMessage.kPrayedCount) as! String)
                        count = count! + 1
                        tempPrayerIndexdata.setValue("\(count!)", forKey: ConstantMessage.kPrayedCount)
                        
                    }else if prayercurrentStatus == 3
                    {
                        
                        var count = Int(tempPrayerIndexdata.object(forKey: ConstantMessage.kPraisedCount) as! String)
                        count = count! + 1
                        tempPrayerIndexdata.setValue("\(count!)", forKey: ConstantMessage.kPraisedCount)
                    }
                    
                    // update prayer status
                    self.prayerListDataArray.replaceObject(at: prayerIndex, with: tempPrayerIndexdata)
                    self.handleOnTapOnBackgroud()
                    
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
    
}




