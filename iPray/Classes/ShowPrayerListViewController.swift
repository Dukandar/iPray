//
//  ShowPrayerListViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class ShowPrayerListViewController: UIViewController,UITextFieldDelegate , UIGestureRecognizerDelegate, TagPrayerPopUpDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var prayerContainerView: UIView!
    @IBOutlet weak var tagRequestCountLbl: UILabel!
    
    //MARK: - Variables
    var prayerId = ""
    var prayerModelView : PrayerListModulerViewController!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        notificationLabel.layer.cornerRadius=11
        tagRequestCountLbl.layer.cornerRadius = tagRequestCountLbl.frame.height / 2
        addPrayerListView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(ConstantMessage.kRefressMyListPushNotification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ShowPrayerListViewController.refressListForNewPushNotification), name: NSNotification.Name(rawValue: ConstantMessage.kRefressMyListPushNotification), object: nil)
        showProfileImage()
        prayerModelView.PageNo = 1
        prayerModelView.getprayerListWebService()
    }
    
    @objc func refressListForNewPushNotification()
    {
        prayerModelView.PageNo = 1
        prayerModelView.getprayerListWebService()
    }
    
    func addPrayerListView()
    {
        prayerModelView = (self.storyboard?.instantiateViewController(withIdentifier:iPrayIdentifier.kPrayerListModulerViewController ) as! PrayerListModulerViewController)
        prayerModelView.prayerURL  =  GET_USER_PRAYER_LIST_URL
        prayerModelView.delegate = self
        prayerModelView.prayerId  = prayerId
        prayerModelView.view.frame = CGRect(x: 0, y: 0, width: prayerContainerView.frame.size.width, height: prayerContainerView.frame.size.height)
        prayerContainerView.addSubview(prayerModelView.view)
        self.addChild(prayerModelView)
    }
    
    func showProfileImage(){
        userName.text = UserManager.shareManger.userName!
        if UserManager.shareManger.profileImage != nil  && UserManager.shareManger.profileImage!.count > 0{
            let imageUrl:URL = URL(string: UserManager.shareManger.profileImage!)!
            profileImage.setImageWith(imageUrl, placeholderImage: UIImage(named: ConstantMessage.kPlaceholderProfileImage))
            profileImage.layoutIfNeeded()
        }else
        {
            profileImage.image = UIImage(named: ConstantMessage.kPlaceholderProfileImage)
        }
        profileImage.layoutIfNeeded()
    }
    
    //MARK: - Button Action
       @IBAction func tagRequestBtnClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagRequestListViewController) as! TagRequestListViewController
           vc.isMyPrayer = true
           self.navigationController?.pushViewController(vc, animated: true)
       }
    
    /**
     *  Action to navigate ProfileSettingViewController to edit User Profile
     */
    
    @IBAction func profileSetting(_ sender: UIButton) {
        let profileSetting = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kProfileSettingViewController) as! ProfileSettingViewController
        self.navigationController?.pushViewController(profileSetting, animated: true)
    }
    
    /**
     *  Action to navigate SearchIprayViewController to search prayer by name or words
     */
    
    @IBAction func searchIpray(_ sender: UIButton) {
        let searchPrayer = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kSearchIprayViewController) as! SearchIprayViewController
        self.navigationController?.pushViewController(searchPrayer, animated: true)
    }
    
    func openAddPrayerView( prayerData : NSDictionary,isupdate : Bool,isOnlyReminder : Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddPrayerViewController) as! AddPrayerViewController
        vc.deligate = self
        vc.isUpdatePrayer = isupdate
        vc.editedPrayerData = prayerData
        vc.isOnlyreminder = isOnlyReminder
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
    
    /**
     *  Action to navigate PrayerRequestViewController to see pryaer request of me
     */
    
    @IBAction func prayerRequest(_ sender: UIButton) {
        let prayRequest=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kPrayerRequestViewController) as! PrayerRequestViewController
        self.navigationController?.pushViewController(prayRequest, animated: true)
    }
    /**
     *  Action to show add prayer popUp screen
     */
    
    @IBAction func showAddPrayerPopup(_ sender: UIButton) {
            let data =  NSDictionary()
        openAddPrayerView(prayerData: data,isupdate: false, isOnlyReminder: false)
    }

    
    //
    @IBAction func crossBtnClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}

extension ShowPrayerListViewController : refressPrayerList
{
    func reloadView(ishare: Bool, data: NSDictionary, isTag: Bool,message: String) {
        newNotificationCome = true
        if ishare
        {
            prayerModelView.openShareViewController(prayerData: data)
        }else if isTag {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagPrayerPopUpViewController) as! TagPrayerPopUpViewController
            vc.delegate = self
            vc.dataDict = data
            vc.type = ConstantMessage.kTag.lowercased()
            vc.isTag = true
            vc.view.frame = self.view.frame
            self.view.bringSubviewToFront(vc.view)
            self.addChild(vc)
            self.view.addSubview(vc.view)
        }else
        {
            if(Utility.shareUtility.getPrayerUserDefaults()){
                ServiceUtility.showMessageHudWithMessage(message as NSString, delay: ConstantMessage.kDelay)
            }else{
                Utility.shareUtility.showPopUpWith(title: message, desc:ConstantMessage.kOpenMyPrayer, buttonName: ConstantMessage.kSubmit.capitalized, view: self.view,delegate:self)
            }
            prayerModelView.PageNo = 1
            prayerModelView.getprayerListWebService()
        }
    }
    
    func tagPopUpBtnClicked(actionType: Int, data: NSDictionary,isTagging : Bool) {
        if actionType == 1 {
            self.sharewithContact(prayerData : data, isIprayContact: true, isTag: true)
        }else if actionType == 2 {
            self.sharewithContact(prayerData : data, isIprayContact: false, isTag: true)
        }else if actionType == 1000 {
            if (self.navigationController?.viewControllers.count)! > 0{
                let viewControllers = self.navigationController?.viewControllers
                for id in viewControllers!{
                    if id == self{
                        for item in id.children{
                            if item is AddPrayerViewController{
                                let VCTR = item as!AddPrayerViewController
                                VCTR.view.isHidden = false
                            }
                        }
                    }
                }
                   
             }
            }else{
            let newdata : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
            if newdata.count > 0{
                newdata.setValue(data.object(forKey: ConstantMessage.kTitle) as! String, forKey: ConstantMessage.kGroupName)
                var vctr = UIViewController()
                if (self.navigationController?.viewControllers.count)! > 0{
                    let viewControllers = self.navigationController?.viewControllers
                    for id in viewControllers!{
                        if id == self{
                          for item in  id.children{
                               if item is AddPrayerViewController{
                                   vctr = item
                               }
                           }
                        }
                    }
                }
                ApplicationDelegate.shareLinkBeyondTheApp(groupData :newdata, isPrayerTitle: true, isTag: isTagging,vctr : vctr)
            }
           
        }
    }
    
    func sharewithContact(prayerData : NSDictionary,isIprayContact:Bool, isTag:Bool)
    {
        let shareiPray=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kSharePrayerViewController) as! SharePrayerViewController
        shareiPray.SharePrayerID = prayerData.object(forKey: ConstantMessage.kPrayerID) as! String
        shareiPray.SharePrayerTitle = prayerData.object(forKey: ConstantMessage.kTitle) as! String
        shareiPray.prayingCount = ApplicationDelegate.getPrayingCount(data: prayerData)
        shareiPray.isTag = isTag
        shareiPray.isIprayContact = isIprayContact
        if (self.navigationController?.viewControllers.count)! > 0{
            let viewControllers = self.navigationController?.viewControllers
            if viewControllers!.count > 0{
                for item in viewControllers![0].children{
                    if item is AddPrayerViewController{
                        shareiPray.vctr = item
                    }
                }
            }
        }
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
}

extension ShowPrayerListViewController : PrayerListModulerDeligate
{
    func notificaitonCount(notificationCount : Int)
    {
        if notificationCount < 1
        {
            self.notificationLabel.text = ""
            self.notificationLabel.isHidden = true
        }else
        {
            self.notificationLabel.text = "\(notificationCount)"
            self.notificationLabel.isHidden = false
        }
    }
    
    func invitationCount(invitationCount: Int) {
        if invitationCount < 1
        {
            self.tagRequestCountLbl.text = ""
            self.tagRequestCountLbl.isHidden = true
        }else
        {
            self.tagRequestCountLbl.text = "\(invitationCount)"
            self.tagRequestCountLbl.isHidden = false
        }
    }
    
    func openAddprayerPopViewController(prayerData: NSDictionary, isupdate: Bool, isreminder: Bool, isOnlyReminder: Bool) {
        
         self.openAddPrayerView(prayerData: prayerData, isupdate: true, isOnlyReminder: isOnlyReminder)
    }
}

extension ShowPrayerListViewController : UtilityProtocol{
    func submitBtnActionWith(isChecked : Bool){
        let subViews = self.view.subviews
        subViews.last?.removeFromSuperview()
        Utility.shareUtility.serPrayerUserUserDefaults(isChecked: isChecked)
    }
    
    func cancel(){
        let subViews = self.view.subviews
        subViews.last?.removeFromSuperview()
    }
}

