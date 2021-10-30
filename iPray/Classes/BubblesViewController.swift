
//
//  BubblesViewController.swift
//  iPray
//
//  Created by Saurabh Mishra on 24/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import UserNotifications
var newNotificationCome = true
class BubblesViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var bubbleMainBgView: UIScrollView!
    @IBOutlet var sharePrayImageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Variable
    var userBubblerray = NSMutableArray()
    var bubbleSizeMinValue = Bubbles.kBubbleMinValue
    var bubbleSizeMaxValue = Bubbles.kBubbleMaxValue
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationObserver()
        ApplicationDelegate.registerForPushNotification()
        newNotificationCome = true
        self.collectionView.register(UINib.init(nibName:  Bubbles.kBubbleCollectionViewCell, bundle: nil), forCellWithReuseIdentifier:  Bubbles.kBubbleCollectionViewCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
          self.getBubblesList()
    }
    
    override func viewWillLayoutSubviews() {
        bubbleSizeMaxValue = Int(round(self.view.frame.size.width / 2.0))
        bubbleSizeMinValue = Int(round(self.view.frame.size.width / 3.0))
    }
    
    //MARK: - Button Action
    @IBAction func openConatctScren(_ sender: UIButton) {
        self.pushToVCT(withIdentifier: iPrayIdentifier.kProfileSettingViewController)
    }
    
    @IBAction func openSearchScreen(_ sender: UIButton) {
        self.pushToVCT(withIdentifier: iPrayIdentifier.kSearchIprayViewController)
    }
    
    @IBAction func openListScreen(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddPrayerViewController) as! AddPrayerViewController
        vc.iscallDeligate = true
        vc.deligate = self
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
    
    @objc func refressListForNewPushNotification()
    {
        self.getBubblesList()
    }
    func pushToVCT(withIdentifier : String){
        switch withIdentifier {
        case iPrayIdentifier.kSearchIprayViewController:
            let shareiPray = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kSearchIprayViewController) as! SearchIprayViewController
                self.navigationController?.pushViewController(shareiPray, animated: true)
        case iPrayIdentifier.kProfileSettingViewController:
                newNotificationCome = true
            let searchPrayer = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kProfileSettingViewController) as! ProfileSettingViewController
                self.navigationController?.pushViewController(searchPrayer, animated: true)
        default:break
        }
    }
}

// MARK: - NSlocal notification with in app
extension BubblesViewController
{
    @objc func contactUploaded()
    {
        let alert = UIAlertController(title: Bubbles.kTitle, message: Bubbles.kContactListUpdate, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kOk, style: .cancel, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func newnotification(notification:NSNotification)
    {
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
        }
    }
    
    func errorPopUp(alertString: String)
    {
        let alert = UIAlertController(title: Bubbles.kOh, message: alertString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kCancel, style: .cancel, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: ConstantMessage.kRetry, style: UIAlertAction.Style.default, handler: {
            (alertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
            self.getBubblesList()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Collection Delegate
extension BubblesViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userBubblerray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let bubbleCell = collectionView.dequeueReusableCell(withReuseIdentifier: Bubbles.kBubbleCollectionViewCell, for: indexPath) as! BubbleCollectionViewCell
        let bubleDataAtIndex = userBubblerray.object(at: indexPath.row) as! UserBubble
        bubbleCell.makeCircle(bubbleData: bubleDataAtIndex, tag: indexPath.row)
        bubbleCell.delegate = self
        return bubbleCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var bubblesize = 0
        let uniformNumber : Int = Int(arc4random_uniform(2))
        if uniformNumber == 1
        {
            bubblesize = bubbleSizeMaxValue - 20
        }else if uniformNumber == 2
        {
            bubblesize = bubbleSizeMaxValue/2
        } else
        {
            bubblesize = bubbleSizeMinValue + 15
        }
        if indexPath.item == userBubblerray.count - 2 || indexPath.item == userBubblerray.count - 3
        {
            return CGSize(width: bubbleSizeMaxValue - 5 , height: bubbleSizeMaxValue - 5)
        }
        if indexPath.item == userBubblerray.count - 1
        {
            return CGSize(width: bubbleSizeMinValue + bubbleSizeMinValue/8, height: bubbleSizeMinValue + bubbleSizeMinValue/8)
        }
        let cellSize : CGSize = CGSize(width: bubblesize, height: bubblesize)
        return cellSize
    }
    
    func randomnumber(upperlimit : Int , lowerlimit : Int) -> Int
    {
        let diffrence : UInt32 = UInt32(upperlimit - lowerlimit)
        let lower : UInt32 = UInt32(lowerlimit)
        let randomNumber = arc4random_uniform(diffrence) + lower
        return Int(randomNumber)
    }
}

// MARK: - BubblesUIviewDelegate
extension BubblesViewController : BubblesUIviewDelegate {
    func didSelectBubble(at: NSInteger)
    {
        /* identificationId ->  -1 : request,
                                -2 : adopt,
                                -3 : group ,
                                 0: reques all ,
                                 1 : self ,
                                 2 : copy*/
        // start indexing of bubble view from 10
        let bubleDataAtIndex = self.userBubblerray.object(at: at - 10) as! UserBubble
        switch bubleDataAtIndex.identificationId {
        case 1:
            let prayRequest=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kShowPrayerListViewController) as! ShowPrayerListViewController
                self.navigationController?.pushViewController(prayRequest, animated: true)
        case 2:
                newNotificationCome = true
            let prayRequest=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kCopyPrayerListViewController) as! CopyPrayerListViewController
                self.navigationController?.pushViewController(prayRequest, animated: true)
        case -2:
                newNotificationCome = true
            let adoptedView = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAdoptedPrayerListViewController) as! AdoptedPrayerListViewController
                adoptedView.friendsUSerId = "\(bubleDataAtIndex.bubbleID!)"
                adoptedView.headeruserName = bubleDataAtIndex.bubbleName
                self.navigationController?.pushViewController(adoptedView, animated: true)
        case -3:
                newNotificationCome = true
                let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupWallViewController) as! GroupWallViewController
                let indexData = bubleDataAtIndex.bubbleData
                // open for admin
                if indexData?.object(forKey: ConstantMessage.kIsCoAdmin) as? String == "1"
                {
                    // open for admin
                    vc.isGroupAdmin = true
                }else
                {// open for member
                    vc.isGroupAdmin = false
                }
                vc.groupDiscription = (indexData?.mutableCopy() as! NSMutableDictionary)
                self.navigationController?.pushViewController(vc, animated: true)
          case 3:
                newNotificationCome = true
                let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
            let shareiPray=storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupListViewController) as! GroupListViewController
                self.navigationController?.pushViewController(shareiPray, animated: true)
        default:
            let prayRequest=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kPrayerRequestViewController) as! PrayerRequestViewController
                prayRequest.friendsUSerId = ""
                if (bubleDataAtIndex.identificationId == -1 )
                {
                    prayRequest.friendsUSerId = "\(bubleDataAtIndex.bubbleID!)"
                    prayRequest.headeruserName = bubleDataAtIndex.bubbleName
                }
                self.navigationController?.pushViewController(prayRequest, animated: true)
        }
    }
}

// MARK: - Get user details Webservice
extension BubblesViewController {
    func getBubblesList()
    {
        if(!ServiceUtility.hasConnectivity())
        {
            self.errorPopUp(alertString: ConstantMessage.NoInternetConnection as String)
            return
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        ServiceUtility.callWebService(GET_BUBBLES_LIST_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            ServiceUtility.hideProgressHudInView()
            if success {
                var isTagInvite = false
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true && dataFromServer.object(forKey: ConstantMessage.kInvitations) != nil && dataFromServer.object(forKey: ConstantMessage.kInvitations) is Bool
                {
                    isTagInvite = (dataFromServer.object(forKey: ConstantMessage.kInvitations) as! Bool)
                }
                //Tag notification
                if  DefaultsManager.share.isNotification != nil {
                    if DefaultsManager.share.isNotification! || (isTagInvite && DefaultsManager.share.isShowTagInvitation!) {
                           DefaultsManager.share.isNotification = false
                           DefaultsManager.share.isShowTagInvitation = false
                           self.tagRequestVCTR()
                    }
                }
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true &&
                    dataFromServer.object(forKey: ConstantMessage.kFriendData) is NSArray && dataFromServer.object(forKey: Bubbles.kMyDate) is NSArray
                {
                    newNotificationCome = false
                    if UIApplication.topViewController() is BubblesViewController
                    {
                        self.userBubblerray = self.populateBubbleData(serverData: dataFromServer.mutableCopy() as! NSMutableDictionary)
                        self.collectionView.scrollToItem(at: IndexPath(item: self.userBubblerray.count - 1 , section: 0), at: UICollectionView.ScrollPosition.top, animated: false)
                        self.collectionView.reloadData()
                    }else
                    {
                        newNotificationCome = true
                    }
                }
                else
                {
                    self.errorPopUp(alertString: ConstantMessage.RequestFail as String)
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: 2.0)
            }
        }
    }
    
    func populateBubbleData(serverData : NSMutableDictionary) -> NSMutableArray
    {
        //Step 1: Create collection of mock objects having (UserID, Name, Count, NotificationCount). Create a Model class  having these 4 properties.
        //Step 2: Populate the collection with dummy data. The data should be having random counts & notification counts. When the real webservice is available, remove the dummy data and wire up with webservice. Rest of the logic and method should remain unchanged.
        //Step 3: Sort the collection based on the Count.
        //Step 4: return the sorted collection.
        var badgeCount = 0
        let myData =  (serverData.object(forKey: Bubbles.kMyDate)! as! NSArray).mutableCopy() as! NSMutableArray
        let friendsDataNew = (serverData.object(forKey: ConstantMessage.kFriendDataNew)! as! NSArray).mutableCopy() as! NSMutableArray
        let tempData = NSMutableArray()
        var identificationid : Int!
        for item in friendsDataNew {
            let data = UserBubble()
            let currentData = item as! NSDictionary
            if currentData.object(forKey:Bubbles.kBubbleType) != nil
            {
                if currentData.object(forKey:Bubbles.kBubbleType) as! String == ConstantMessage.kGroup
                {
                    identificationid = -3
                }else if currentData.object(forKey:Bubbles.kBubbleType) as! String == ConstantMessage.kAdoptedPrayer
                {
                    identificationid = -2
                }else
                {
                    identificationid = -1
                }
                
                var profileImageURL = ""
                if let imageURL = currentData.object(forKey: ConstantMessage.kImageURL) as? String,imageURL.count > 0
                {
                    profileImageURL = imageURL
                }
                data.setDataInBubbles(id: currentData.object(forKey:Bubbles.kId) as! String,
                                      totalCount:Int(currentData.object(forKey:Bubbles.kTotalCount) as! String)!,
                                      notificationCount: Int(currentData.object(forKey: Bubbles.kNotificatioCount) as! String)!,
                                      name : currentData.object(forKey: Bubbles.kName) as! String,
                                      identificationId : identificationid,
                                      bubbleDiscription : currentData,profileImg: profileImageURL)
                tempData.add(data)
            }
        }
        // add 3 buble at bottom
        for (index,item) in myData.enumerated()
        {
            let data  = UserBubble()
            let currentData = item as! NSDictionary
            data.setDataInBubbles(id: currentData.object(forKey: Bubbles.kId) as! String,
                                        totalCount:Int(currentData.object(forKey: Bubbles.kTotalCount) as! String)!,
                                        notificationCount: Int(currentData.object(forKey: Bubbles.kNotificatioCount) as! String)!,
                                        name : currentData.object(forKey: Bubbles.kName) as! String,
                                        identificationId : index,
                                        bubbleDiscription : currentData,
                                        profileImg: "")
            tempData.add(data)
            badgeCount = badgeCount + Int(currentData.object(forKey: Bubbles.kNotificatioCount) as! String)!
        }
        let data  = UserBubble()
        let currentData = NSDictionary()
        data.setDataInBubbles(id: "-001",
                              totalCount:0,
                              notificationCount: 0,
                              name : Bubbles.kGroupName,
                              identificationId : 3,
                              bubbleDiscription : currentData,
                              profileImg: "")
        tempData.add(data)
        self.setNotificationBageNumberWith(badgeCount: badgeCount)
        if Int((myData.object(at: 1) as! NSDictionary).object(forKey: Bubbles.kTotalCount) as! String)! <= 2
        {
            self.animateSharePrayImageView()
        }
        return tempData
    }
    
    func setNotificationBageNumberWith(badgeCount : Int){
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
}

//MARK:- TagRequest
extension BubblesViewController{
    func tagRequestVCTR() {
        let  tagRequestVc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagRequestListViewController) as? TagRequestListViewController
        self.view.addSubview(tagRequestVc!.view)
        self.addChild(tagRequestVc!)
    }
}

//MARK:- NotificationCenter
extension BubblesViewController {
    func notificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(BubblesViewController.refressListForNewPushNotification), name: NSNotification.Name(rawValue: ConstantMessage.kRefressBubblePushNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BubblesViewController.contactUploaded), name: NSNotification.Name(rawValue: ConstantMessage.kContactUploaded), object: nil)
    }
}


//MARK:-
extension BubblesViewController{
    func animateSharePrayImageView() {
        self.sharePrayImageView.isHidden = false
        self.sharePrayImageView.frame = CGRect(x: CGFloat(self.view.frame.size.width) / 2  - (self.sharePrayImageView.frame.size.width / 2) , y: CGFloat(self.view.frame.size.height - 250.0), width: self.sharePrayImageView.frame.size.width, height: self.sharePrayImageView.frame.size.height)
        UIView.animate(withDuration: 4, delay: 0.0, options:[], animations: {() -> Void in
            self.sharePrayImageView.frame = CGRect(x: CGFloat(self.view.frame.size.width) / 2  - (self.sharePrayImageView.frame.size.width / 2) , y: CGFloat(self.view.frame.size.height - 120) , width: self.sharePrayImageView.frame.size.width, height: self.sharePrayImageView.frame.size.height)
        }, completion: {(isDone: Bool) -> Void in
            if !self.sharePrayImageView.isHidden && isDone
            {
                self.animateSharePrayImageView()
            }
        })
    }
}


