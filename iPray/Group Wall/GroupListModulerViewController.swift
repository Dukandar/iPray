//
//  GroupListModulerViewController.swift
//  iPray
//
//  Created by Zeba on 10/6/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
@objc protocol GroupPrayerListModulerDelegate {
    @objc optional func notificaitonCount(iswall : Bool,notificationCountDic : NSDictionary)
    @objc optional func updateGroupPrayer(prayerData : NSDictionary)
    @objc optional func sharePrayerLinkLink(data : NSDictionary)
    @objc optional func resetNotificaitonCount(iswall : Bool)
    @objc optional func setProfileImage(imgaeURL : String)
}

class GroupListModulerViewController: UIViewController , UIGestureRecognizerDelegate{
    
    // MARK: - variables
    var delegate : GroupPrayerListModulerDelegate!
    let manager = AFHTTPSessionManager()
    var tapGesture = UITapGestureRecognizer()
    var refreshControl: UIRefreshControl!
    var notFoundLable : UILabel!
    var groupPrayerListDataArray = NSMutableArray()
    var groupWallListArray = NSMutableArray()
    var groupBookListArray = NSMutableArray()
    var selectedPopUpIndex : Int = -1
    var groupId :String = ""
    var prayerURL :String = ""
    var searchText : String = ""
    var PageNo = 1
    var isPrayerWall : Bool! = true
    var isGroupAdmin : Bool! = false
    var isSearch = false
    var isWall = true
    var notificationCount : Int = 0
    
    //New changes
    let sharingTitle = ConstantMessage.kiPraySharing;
    let sharingSubTitle = ConstantMessage.kSomeonePray
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 152
        tableView.rowHeight = UITableView.automaticDimension
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(GroupListModulerViewController.handleOnTapOnBackgroud))
        tapGesture.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: ConstantMessage.kPullToRefresh)
        refreshControl.addTarget(self, action: #selector(pulltoRrefresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        let nib = UINib.init(nibName: iPrayIdentifier.kGroupPrayerTableViewCell, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: iPrayIdentifier.kGroupPrayerTableViewCell)
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if !isSearch
        {
            self.getprayerListWebService()
        }
    }
    
    func reloadPrayerTableview()
    {
        if isSearch
        {
            self.tableView.reloadData()
        }else{
            if isPrayerWall
            {
                self.groupPrayerListDataArray = self.groupWallListArray
                self.view.removeGestureRecognizer(tapGesture)
            }else
            {
                if isGroupAdmin && selectedPopUpIndex != -1
                {
                    self.view.addGestureRecognizer(tapGesture)
                }
                self.groupPrayerListDataArray = self.groupBookListArray
            }
            self.tableView.reloadData()
            self.getprayerListWebService()
        }
    }
    
    @objc func pulltoRrefresh(sender:AnyObject) {
        self.PageNo = 1
        refreshControl.endRefreshing()
        self.getprayerListWebService()
    }
}

// MARK: - TableView Delegate
extension GroupListModulerViewController: UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupPrayerListDataArray.count == 0
        {
            return 1
        }
        return groupPrayerListDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         1 :self view
         2 :pulish view
         3 :Copy view
         4 :Adopt view
         5 :Adopt remove view
         */
        if groupPrayerListDataArray.count == 0
        {
            let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kNoCell)! as UITableViewCell
            notFoundLable = (cell.viewWithTag(1) as! UILabel)
            cell.selectionStyle = .none
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: iPrayIdentifier.kGroupPrayerTableViewCell)! as! GroupPrayerTableViewCell
            cell.tag = indexPath.row
            cell.delegate = self
            let temp  = groupPrayerListDataArray.object(at: indexPath.row) as! NSDictionary
            cell.loadData(data : temp, indexPath : indexPath.row, selectedPopUpIndex : selectedPopUpIndex,isPrayerWall : isPrayerWall,isGroupAdmin : isGroupAdmin)
            cell.selectionStyle = .none
            if self.groupPrayerListDataArray.count == indexPath.row + 1 && self.groupPrayerListDataArray.count % 10 == 0
            {
                PageNo = PageNo + 1
                self.getprayerListWebService()
            }
            return cell
        }
    }
}

// MARK: - TagPrayer Popup Delegate
extension GroupListModulerViewController: GroupPrayerTableViewCellProtocol, TagPrayerPopUpDelegate
{
    func PrayerActionButtonCliked(index : Int,action : Int)
    {
        switch action {
        case 1:
            debugPrint(ConstantMessage.kSeeMore)
            seeMoreBtncliked(cellIndex: index)
            break
        case 2:
            debugPrint("open pop up")
            self.selectedPopUpIndex = index
            editPrayerPopUpMenuBtnCliked()
            break
        case 3:
            debugPrint("Adoption btn")
            self.adoptPrayerWebServices(prayerIndex: index)
            break
        case 4:
            debugPrint("Copy prayer")
            let alert = UIAlertController(title: "", message: ConstantMessage.kMyPrayers, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: ConstantMessage.kYes, style: .default, handler: {
                (alertAction) -> Void in
                 self.copyPrayerWebServices(prayerIndex: index)
            }))
            alert.addAction(UIAlertAction(title: ConstantMessage.kNo, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case 6:
            debugPrint("Publish")
            self.publishPrayerWebServices(prayerIndex: index)
            break
        case 7:
            debugPrint("shareLInk")
            let tempPrayerIndexdata = (self.groupPrayerListDataArray.object(at: index) as! NSDictionary)
           // ApplicationDelegate.shareLinkBeyondTheApp(groupData : tempPrayerIndexdata, isPrayerTitle: true)
            self.openShareViewController(prayerData: tempPrayerIndexdata)
            //self.delegate.sharePrayerLinkLink!(data: tempPrayerIndexdata)
            //delegate.sharePrayerLinkLink!(data : tempPrayerIndexdata)
            break
        case 8:
            debugPrint("Tag Prayer")
            self.openTagViewController(prayerData: self.groupPrayerListDataArray[index] as! NSDictionary)
            break
        case 9: debugPrint("start prayer")
        self.startPrayerWebServices(prayerIndex: index)
            break
        default:
            prayerPopUpActionBtnCliked(indexRow : index, Buttontag : action)
            break
        }
    }
    
    func openShareViewController(prayerData : NSDictionary) {
        let alert = UIAlertController(title: self.sharingTitle, message: self.sharingSubTitle, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kMyContacts, style: .default, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.sharewithContact(prayerData : prayerData, isIprayContact: false, isTag: false)
        }))
        alert.addAction(UIAlertAction(title: ConstantMessage.kExternal, style: .default, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            let newdata : NSMutableDictionary = prayerData.mutableCopy() as! NSMutableDictionary
            newdata.setValue(prayerData.object(forKey: ConstantMessage.kGroupPrayerTitle) as! String, forKey: ConstantMessage.kGroupName)
            ApplicationDelegate.shareLinkBeyondTheApp(groupData :newdata, isPrayerTitle: true, isTag: false,isGroupSharing: true)
        }))
        alert.addAction(UIAlertAction(title: ConstantMessage.kCancel, style: .destructive, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openTagViewController(prayerData : NSDictionary) {
        let storyboard = UIStoryboard(name: ConstantMessage.kMain, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kTagPrayerPopUpViewController) as! TagPrayerPopUpViewController
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
        if actionType == 1 {
            self.sharewithContact(prayerData : data, isIprayContact: true, isTag: true)
        }else if actionType == 2 {
            self.sharewithContact(prayerData : data, isIprayContact: false, isTag: true)
        }else{
            let newdata : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
            if newdata.count > 0 {
                newdata.setValue(data.object(forKey: ConstantMessage.kGroupPrayerTitle) as! String, forKey: ConstantMessage.kGroupName)
                ApplicationDelegate.shareLinkBeyondTheApp(groupData :newdata, isPrayerTitle: isTagging, isTag: isTagging,isGroupSharing: true)
            }
        }
    }
    
    func sharewithContact(prayerData : NSDictionary,isIprayContact:Bool, isTag:Bool)
    {
        let shareiPray=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kShareGroupPrayerViewController) as! ShareGroupPrayerViewController
        shareiPray.SharePrayerID = prayerData.object(forKey: ConstantMessage.kGroupPrayerID) as! String
        shareiPray.createrId = (prayerData.object(forKey: ConstantMessage.kCreatorID) as! String)
        shareiPray.SharePrayerTitle = prayerData.object(forKey: ConstantMessage.kGroupPrayerTitle) as! String
        shareiPray.prayingCount = ApplicationDelegate.getPrayingCount(data: prayerData)
        shareiPray.isTag = isTag
        shareiPray.isIprayContact = isIprayContact
        if isTag{
            if prayerData.object(forKey: ConstantMessage.kAlreadyTagged) != nil
            {
                shareiPray.alreadyShareContactArrayList = (prayerData.object(forKey: ConstantMessage.kAlreadyTagged) as! NSArray).mutableCopy() as! NSMutableArray
            }
        }else{
            if prayerData.object(forKey: ConstantMessage.kAlreadyShared) != nil
            {
                shareiPray.alreadyShareContactArrayList = (prayerData.object(forKey: ConstantMessage.kAlreadyShared) as! NSArray).mutableCopy() as! NSMutableArray
            }
        }
        shareiPray.modalPresentationStyle = .fullScreen
        self.present(shareiPray, animated: true, completion: nil)
    }
    
    //MARK:- Prayer functionality
    func seeMoreBtncliked(cellIndex : Int) {
        let data = (self.groupPrayerListDataArray[cellIndex] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        if data.object(forKey: ConstantMessage.kShowfull) as! Bool
        {
            data.setValue(false, forKey: ConstantMessage.kShowfull)
        }else
        {
            data.setValue(true, forKey: ConstantMessage.kShowfull)
        }
        self.groupPrayerListDataArray.replaceObject(at: cellIndex, with: data)
        self.tableView.reloadData()
        scroltableviewToIndex(Index: cellIndex)
    }
    
    func editPrayerPopUpMenuBtnCliked() {
        self.tableView.reloadData()
        scroltableviewToIndex(Index: self.selectedPopUpIndex)
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func prayerPopUpActionBtnCliked(indexRow : Int, Buttontag : Int) {
        switch Buttontag{
        case 5:
            debugPrint("remove publishing")
            self.openRemovePrayerPrompt(prayerIndex: indexRow)
            break
        case -11:
            debugPrint(ConstantMessage.kUpdate)
            handleOnTapOnBackgroud()
            guard let tempdata = self.groupPrayerListDataArray[indexRow] as? NSDictionary else {return}
            self.delegate.updateGroupPrayer!(prayerData: tempdata )
            break
        case -12:
            debugPrint("Ans")
            self.answerPrayerWebServices(index: indexRow)
            break
        case -13:
            debugPrint("Remove self prayer")
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
    
    @objc func handleOnTapOnBackgroud(){
        self.selectedPopUpIndex = -1
        self.tableView.reloadData()
        self.view.removeGestureRecognizer(tapGesture)
    }
    
    func scroltableviewToIndex(Index : Int){
        if Index + 1 < 10
        {
            self.tableView.selectRow(at: IndexPath(item: Index + 1 , section: 0) , animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
}

// MARK: - Web Service
extension GroupListModulerViewController
{
    func getprayerListWebService()
    {
        self.selectedPopUpIndex = -1
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(PageNo, forKey: ConstantMessage.kPage)
        parameter.setValue(groupId, forKey: ConstantMessage.kGroupID)
        if isSearch
        {
            parameter.setValue(searchText, forKey: ConstantMessage.kSearchText)
        }
        if notFoundLable != nil
        {
            notFoundLable.text = ConstantMessage.kSearchingPrayers
        }
        ServiceUtility.callWebService(prayerURL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    var serverData = NSMutableArray()
                    serverData = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray).mutableCopy() as! NSMutableArray
                    let serverdata =  ApplicationDelegate.sortGroupPrayerUsingPrayStatus(prayerList:serverData)
                    serverData = serverdata.mutableCopy() as! NSMutableArray
                    
                    //new Soarting based on date (NEW CR 15THAPRILSB)
                    let soartDescriptor = NSSortDescriptor(key: ConstantMessage.kUpdatedOn, ascending: false)
                    let soartserverData  = serverData.sortedArray(using: [soartDescriptor])
                    serverData = NSMutableArray(array: soartserverData)
                    
                    
                    if self.PageNo == 1
                    {
                        if self.isSearch
                        {
                            self.groupPrayerListDataArray.removeAllObjects()
                            self.groupPrayerListDataArray = serverData.mutableCopy() as! NSMutableArray
                        }else
                        {
                            if self.isPrayerWall
                            {
                                self.groupWallListArray.removeAllObjects()
                                self.groupWallListArray = serverData.mutableCopy() as! NSMutableArray
                            }else
                            {
                                self.groupBookListArray.removeAllObjects()
                                self.groupBookListArray = serverData.mutableCopy() as! NSMutableArray
                            }
                        }
                    }else
                    {
                        if self.isSearch
                        {
                            self.groupPrayerListDataArray.addObjects(from: serverData.mutableCopy() as! [Any])
                        }else
                        {
                            if self.isPrayerWall
                            {
                                self.groupWallListArray.addObjects(from: serverData.mutableCopy() as! [Any])
                            }else
                            {
                                self.groupBookListArray.addObjects(from: serverData.mutableCopy() as! [Any])
                            }
                        }
                    }
                    if !self.isSearch
                    {
                        if self.isPrayerWall
                        {
                            self.groupPrayerListDataArray = self.groupWallListArray
                        }else
                        {
                            self.groupPrayerListDataArray = self.groupBookListArray
                        }
                    }
                    if self.delegate != nil && !(self.delegate is SearchGroupPrayerViewController)
                    {
                        if dataFromServer.object(forKey: ConstantMessage.kStatsCount) != nil && dataFromServer.object(forKey: ConstantMessage.kStatsCount) is NSDictionary
                        {
                            let noificationCount = dataFromServer.object(forKey: ConstantMessage.kStatsCount) as! NSDictionary
                            self.delegate.notificaitonCount!(iswall: self.isWall, notificationCountDic: noificationCount)
                        }
                    }
                    if self.delegate is SearchGroupPrayerViewController && self.searchText.trimmingCharacters(in: CharacterSet.whitespaces) == ""
                    {
                        self.groupPrayerListDataArray.removeAllObjects()
                    }
                    self.tableView.reloadData()
                }
                else
                {
//                                        if self.delegate is SearchIprayViewController
                    if self.delegate is SearchGroupPrayerViewController
                    {
                        self.groupPrayerListDataArray.removeAllObjects()
                        self.tableView.reloadData()
                    }
                }
                //   setProfileImage
                if self.delegate != nil && !(self.delegate is SearchGroupPrayerViewController) && dataFromServer.object(forKey: ConstantMessage.kGroupImage) != nil &&  dataFromServer.object(forKey: ConstantMessage.kGroupImage) is String
                {
                    self.delegate.setProfileImage!(imgaeURL: dataFromServer.object(forKey: ConstantMessage.kGroupImage) as! String)
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
            if self.notFoundLable != nil &&  self.groupPrayerListDataArray.count == 0
            {
                self.notFoundLable.text = ConstantMessage.NotFound as String
                if self.delegate != nil && !(self.delegate is SearchGroupPrayerViewController)
                {
                    self.delegate.resetNotificaitonCount!(iswall: self.isWall)
                }
            }
        }
        
    }
    
    func startPrayerWebServices(prayerIndex : Int) {
        let tempPrayerIndexdata = (self.groupPrayerListDataArray.object(at: prayerIndex) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        var status = "1"
        if((tempPrayerIndexdata[ConstantMessage.kIsAnswered] as! String) == "1"){
            if (tempPrayerIndexdata[ConstantMessage.kStatus] as! String) == "4" {
                status = "3"
            }else{
                status = "4"
            }
        }else{
            if (tempPrayerIndexdata[ConstantMessage.kStatus] as! String) == "1" {
                status = "2"
            }else{
                status = "1"
            }
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(tempPrayerIndexdata.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        perameter.setValue(status, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebService(START_PRAYER_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    newNotificationCome = true
                    if status == "1"
                    {
                        var count = Int(tempPrayerIndexdata.object(forKey: ConstantMessage.kPrayedCount) as! String)
                        count = count! - 1
                        tempPrayerIndexdata.setValue("\(count!)", forKey: ConstantMessage.kPrayedCount)
                        tempPrayerIndexdata.setValue(status, forKey: ConstantMessage.kStatus)
                    }
                    if status == "2"
                    {
                        var count = Int(tempPrayerIndexdata.object(forKey: ConstantMessage.kPrayedCount) as! String)
                        count = count! + 1
                        tempPrayerIndexdata.setValue("\(count!)", forKey: ConstantMessage.kPrayedCount)
                        tempPrayerIndexdata.setValue("0", forKey: ConstantMessage.kStatus)
                    }else if status == "4" || status == "3"
                    {
                        var count = Int(tempPrayerIndexdata.object(forKey: ConstantMessage.kPrayedCount) as! String)
                       count = count! + 1
                       tempPrayerIndexdata.setValue("\(count!)", forKey: ConstantMessage.kPrayedCount)
                       tempPrayerIndexdata.setValue(status, forKey: ConstantMessage.kStatus)
                    }
                    self.groupPrayerListDataArray.replaceObject(at: prayerIndex, with: tempPrayerIndexdata)
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
    
    func removePrayerWebServices(prayerIndex : Int)
    {
        let tempdata = (self.groupPrayerListDataArray[prayerIndex] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue(tempdata.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        ServiceUtility.callWebService(REMOVE_GROUP_PRAYER_URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.groupPrayerListDataArray.removeObject(at: prayerIndex)
                    self.handleOnTapOnBackgroud()
                    self.getprayerListWebService()
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
    
    func answerPrayerWebServices(index : Int)
    {
        let tempdata = (self.groupPrayerListDataArray[index] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        var status = "0"
        if tempdata[ConstantMessage.kIsAnswered] as! String == "0"
        {
            status = "1"
        }
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue(tempdata.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        parameter.setValue(status, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebService(ANSWER_PRAYER_URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    tempdata.setValue(status, forKey: ConstantMessage.kIsAnswered)
                    tempdata.setValue("1", forKey: ConstantMessage.kStatus)
                    self.groupPrayerListDataArray.replaceObject(at: index, with: tempdata)
                    self.handleOnTapOnBackgroud()
                    self.getprayerListWebService()
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
    
    func adoptPrayerWebServices(prayerIndex : Int)
    {
        let tempPrayerIndexdata = (self.groupPrayerListDataArray.object(at: prayerIndex) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue(tempPrayerIndexdata.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        parameter.setValue("1", forKey: ConstantMessage.kisAdopt)
        ServiceUtility.callWebService(ADOPT_GROUP_PRAYER_URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.getprayerListWebService()
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
    
    func publishPrayerWebServices(prayerIndex : Int)
    {
        let tempPrayerIndexdata = (self.groupPrayerListDataArray.object(at: prayerIndex) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue(tempPrayerIndexdata.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        ServiceUtility.callWebService(PUBLISH_GROUP_PRAYER_URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.getprayerListWebService()
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
    
    func copyPrayerWebServices(prayerIndex : Int)
    {
        let tempdata = (self.groupPrayerListDataArray[prayerIndex] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        var status = "0"
        if tempdata[ConstantMessage.kIsCopied] as! String == "0"
        {
            status = "1"
        }
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue(tempdata.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
        parameter.setValue(status, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebService(COPY_GROUP_PRAYER_URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.getprayerListWebService()
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

