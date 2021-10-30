//
//  GroupWallViewController.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 21/11/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit

class GroupWallViewController: UIViewController,HelpViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet var bookStatsLable: UILabel!
    @IBOutlet var wallStatsLable: UILabel!
    @IBOutlet var addprayerBgview: UIView!
    @IBOutlet var mainViewContraint: NSLayoutConstraint!
    @IBOutlet var adminWallSubheader: UIView!
    @IBOutlet var memberWallSubheader: UIView!
    @IBOutlet var adminBookSubheader: UIView!
    @IBOutlet var notification2: UILabel!
    @IBOutlet var notification1: UILabel!
    @IBOutlet var suggestionWall: UIButton!
    @IBOutlet var prayerWall: UIButton!
    @IBOutlet weak var prayerContainerView: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var groupHeader: UILabel!
    @IBOutlet weak var submitPrayerLbl: UILabel!
    @IBOutlet weak var postPrayerLbl: UILabel!
    
    //NEW CR 18APR2020
    @IBOutlet weak var prayerRequestView : UIView!
    @IBOutlet weak var groupParayerView : UIView!
    
    // MARK: - Variables
    var prayerGroupModelView : GroupListModulerViewController!
    var isPrayerWall = true
    var isGroupAdmin = true
    var prayerId = ""
    var groupDiscription : NSMutableDictionary!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
  
        checkHelpButtonVisibility()
        addPrayerModuleListView()
        prayerWall.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        if isGroupAdmin
        {
            adminWallSubheader.isHidden = false
            memberWallSubheader.isHidden = true
            adminBookSubheader.isHidden = true
        }else
        {
            adminWallSubheader.isHidden = true
            memberWallSubheader.isHidden = false
            adminBookSubheader.isHidden = true
        }
        if groupDiscription != nil
        {
           if groupDiscription.object(forKey: ConstantMessage.kGroupProfilePic) != nil && (groupDiscription.object(forKey: ConstantMessage.kGroupProfilePic) as? String) != ""
            {
                let urlString = (groupDiscription.object(forKey: ConstantMessage.kGroupProfilePic) as? String)!
                profileImage.setImageWith(URL(string: urlString)!, placeholderImage: #imageLiteral(resourceName: "groupDefault"))
            }else
           {
            profileImage.image = #imageLiteral(resourceName: "groupDefault")
            }
            if groupDiscription.object(forKey: ConstantMessage.kGroupName) != nil
            {
                groupHeader.text = groupDiscription.object(forKey: ConstantMessage.kGroupName) as? String
            }else  if groupDiscription.object(forKey: ConstantMessage.kName) != nil
            {
                groupHeader.text = groupDiscription.object(forKey: ConstantMessage.kName) as? String
                groupDiscription.setValue(groupDiscription.object(forKey: ConstantMessage.kName) as? String, forKey: ConstantMessage.kGroupName)
            }else
            {
                groupHeader.text = ConstantMessage.kiPray
                groupDiscription.setValue(ConstantMessage.kiPray, forKey: ConstantMessage.kGroupName)
            }
            if groupDiscription.object(forKey: ConstantMessage.kId) != nil
            {
               groupDiscription.setValue(groupDiscription.object(forKey: ConstantMessage.kId) as? String, forKey: ConstantMessage.kGroupID)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Action
    @IBAction func backButtonPress(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func ProfileButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupSettingViewController) as! GroupSettingViewController
        vc.groupProfileDic = groupDiscription
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func searchButtonPress(_ sender: Any) {
        let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kSearchGroupPrayerViewController) as! SearchGroupPrayerViewController
        vc.groupDiscription = self.groupDiscription
        vc.isPrayerWall = self.isPrayerWall
        vc.isGroupAdmin = self.isGroupAdmin
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func prayerWallButtonPress(_ sender: Any) {
        mainViewContraint.constant = 50
        addprayerBgview.isHidden = false
        if isGroupAdmin
        {
            adminWallSubheader.isHidden = false
            memberWallSubheader.isHidden = true
            adminBookSubheader.isHidden = true
        }else
        {
            adminWallSubheader.isHidden = true
            memberWallSubheader.isHidden = false
            adminBookSubheader.isHidden = true
        }
        prayerRequestView.backgroundColor = UIColor.white
        prayerWall.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        suggestionWall.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        groupParayerView.backgroundColor = UIColor.clear
        self.isPrayerWall = true
        prayerGroupModelView.prayerURL  =  GET_GROUP_WALL_LIST_URL
        prayerGroupModelView.isPrayerWall = true
        prayerGroupModelView.reloadPrayerTableview()
    }
    
    @IBAction func suggestionButtonPress(_ sender: Any) {
        if isGroupAdmin
        {
            mainViewContraint.constant = 50
            addprayerBgview.isHidden = false
            adminWallSubheader.isHidden = true
            memberWallSubheader.isHidden = true
            adminBookSubheader.isHidden = false
        }else
        {
            mainViewContraint.constant = 0
            addprayerBgview.isHidden = true
            adminWallSubheader.isHidden = true
            memberWallSubheader.isHidden = true
            adminBookSubheader.isHidden = true
        }
        prayerRequestView.backgroundColor = UIColor.clear
        groupParayerView.backgroundColor = UIColor.white
        suggestionWall.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
        prayerWall.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        self.isPrayerWall = false
        prayerGroupModelView.prayerURL  =  GET_GROUP_BOOK_LIST_URL
        prayerGroupModelView.isPrayerWall = false
        prayerGroupModelView.reloadPrayerTableview()
    }
    
    @IBAction func addPrayerButtonPress(_ sender: Any) {
      let temp =  NSDictionary()
      openAddPrayerView(prayerData: temp, isupdate: false)
    }
    
    @IBAction func copyLinkButtonPress(_ sender: UIButton) {
        ApplicationDelegate.shareLinkBeyondTheApp(groupData: groupDiscription, isPrayerTitle: false, isTag: false)
    }
    
    @IBAction func helpBtnClicked(_ sender: UIButton) {
        openHelpPopUp()
    }
    
    func openHelpPopUp(){
        let storyboard = UIStoryboard(name: ConstantMessage.kMain, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kHelpViewController) as! HelpViewController
        vc.delegate = self
        vc.isUpdate = false
        vc.pageType = (self.isPrayerWall) ? 1000 : 2000
        self.addChild(vc)
        self.view.addSubview(vc.view)
    }
    
    func isHelpButtonShow() {
        checkHelpButtonVisibility()
    }
    
    func checkHelpButtonVisibility(){
        if UserDefaults.standard.object(forKey: ConstantMessage.kIsShowGroupHelp) != nil && UserDefaults.standard.object(forKey: ConstantMessage.kIsShowGroupHelp) as! Bool == false {
        }else{
        }
    }
    
    func addPrayerModuleListView()    {
        prayerGroupModelView = (self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupListModulerViewController) as! GroupListModulerViewController)
        prayerGroupModelView.prayerURL  =  GET_GROUP_WALL_LIST_URL
        prayerGroupModelView.isPrayerWall = true
        prayerGroupModelView.isGroupAdmin = isGroupAdmin
        prayerGroupModelView.delegate = self
        if groupDiscription.object(forKey: ConstantMessage.kGroupID) != nil
        {
             prayerGroupModelView.groupId = (groupDiscription.object(forKey: ConstantMessage.kGroupID) as? String)!
        }else
        {
             prayerGroupModelView.groupId = (groupDiscription.object(forKey: ConstantMessage.kId) as? String)!
            
        }
       
        prayerGroupModelView.view.frame = CGRect(x: 0, y: 0, width: prayerContainerView.frame.size.width, height: prayerContainerView.frame.size.height)
        prayerContainerView.addSubview(prayerGroupModelView.view)
        self.addChild(prayerGroupModelView)
        
    }
    
    func openAddPrayerView( prayerData : NSDictionary,isupdate : Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddGroupPrayerViewController) as! AddGroupPrayerViewController
        vc.delegate = self
        if groupDiscription.object(forKey: ConstantMessage.kGroupID) != nil
        {
               vc.groupId = (groupDiscription.object(forKey: ConstantMessage.kGroupID) as? String)!
        }else
        {
            vc.groupId = (groupDiscription.object(forKey: ConstantMessage.kId) as? String)!
        }
        vc.isMyGroupPrayer=isGroupAdmin
        vc.isWall = isPrayerWall
        vc.isUpdate = isupdate
        vc.updatePrayerData = prayerData
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
}

// MARK: - Group Prayer Delegate
extension GroupWallViewController :AddGroupPrayerDelegate , GroupPrayerListModulerDelegate ,GroupSettingViewControllerDelegate
{
    func navigateToPreviousScreen()
    {
      self.navigationController?.popViewController(animated: false)
    }
    
    // Add Group Prayer Delegate
    func newGroupPrayerAdded()
    {
         prayerGroupModelView.reloadPrayerTableview()
        
    }
    
    func resetNotificaitonCount(iswall : Bool)
    {
        if iswall
        {
             notification1.text = ""
            notification1.isHidden =  true
            
        }else
        {
             notification2.text = ""
            notification2.isHidden =  true
        }
        
        
    }
    
    
    //GroupPrayerListModulerDelegate
    func setProfileImage(imgaeURL : String)
    {
        if imgaeURL != ""
        {
            profileImage.setImageWith(URL(string: imgaeURL)!, placeholderImage: #imageLiteral(resourceName: "groupDefault"))
            
        }
    }
    func notificaitonCount(iswall : Bool,notificationCountDic : NSDictionary)
    {
       
        var wallString = ""
        var bookString = ""
        
        if notificationCountDic.object(forKey: ConstantMessage.kAdoptedCount) as! String != "0"
        {
            wallString = "\(notificationCountDic.object(forKey: ConstantMessage.kAdoptedCount) as! String) \(ConstantMessage.kAdoptions), "
        }
        if notificationCountDic.object(forKey: ConstantMessage.kPrayerOnWall) as! String != "0"
        {
            wallString = wallString + "\(notificationCountDic.object(forKey: ConstantMessage.kPrayerOnWall) as! String) \(ConstantMessage.kprayers)"
        }
        
        if notificationCountDic.object(forKey: ConstantMessage.kPrayerOnBook) as! String != "0"
        {
            bookString = "\(notificationCountDic.object(forKey: ConstantMessage.kPrayerOnBook) as! String) \(ConstantMessage.kprayers), "
        }
        if notificationCountDic.object(forKey: ConstantMessage.kPrayedCount) as! String != "0"
        {
            bookString = bookString +  "\(ConstantMessage.kPrayed.lowercased()) \(notificationCountDic.object(forKey: ConstantMessage.kPrayedCount) as! String) \(ConstantMessage.kTimes)"
        }
        if notificationCountDic.object(forKey: ConstantMessage.kUnreadWallPrayers) as! String != "0"
        {
            notification1.text = "\(notificationCountDic.object(forKey: ConstantMessage.kUnreadWallPrayers) as! String)"
            notification1.isHidden = false
            
        }else
        {
            notification1.isHidden = true
             notification1.text = ""
        }
        if notificationCountDic.object(forKey: ConstantMessage.kUnreadBookPrayer) as! String != "0"
        {
            notification2.text = "\(notificationCountDic.object(forKey: ConstantMessage.kUnreadBookPrayer) as! String)"
            notification2.isHidden = false
        }else
        {
            notification2.isHidden = true
             notification2.text = ""
           
        }
        bookStatsLable.text = bookString
        wallStatsLable.text =  wallString
        
    }
    // protocol
    func sharePrayerLinkLink(data: NSDictionary)
    {
        let newdata : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
        if newdata.count > 0{
            newdata.setValue(groupDiscription.object(forKey: ConstantMessage.kGroupName) as! String, forKey: ConstantMessage.kGroupName)
            
            ApplicationDelegate.shareLinkBeyondTheApp(groupData : newdata, isPrayerTitle: true, isTag: false)
        }
    }
    //GroupPrayerListModulerDelegate : Update prayer
    func updateGroupPrayer(prayerData : NSDictionary)
    {
        
        self.openAddPrayerView(prayerData: prayerData, isupdate: true)
    }
}

