//
//  AppDelegate.swift
//  iPray
//
//  Created by Manvendra Singh on 10/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import IQKeyboardManager
import AFNetworking
import AVFoundation
import EventKit
import UserNotifications
import Firebase

let ApplicationDelegate = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    let eventStore = EKEventStore()
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UserManager.shareManger.setLoginDataWith(data: DefaultsManager.share.loginData)
        return true
    }

    // MARK: - Did finish Launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
          addNotificationAction()
          FirebaseApp.configure()
          DefaultsManager.share.isShowTagInvitation = true
          DefaultsManager.share.isNotification = false
          center.delegate = self
          IQKeyboardManager.shared().isEnabled = true
          application.registerForRemoteNotifications()
        return true//FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        // Sent whken the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.refressLists()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

//MARK: - Facebook Delegate
extension AppDelegate{
   func application(_ application: UIApplication,
                    open url: URL,
                    sourceApplication: String?,
                    annotation: Any) -> Bool
   {
         FBSDKApplicationDelegate.sharedInstance().application(
           application,
           open: url,
           sourceApplication: sourceApplication,
           annotation: annotation)
       return true
   }
}

// MARK: - addNotificationAction
extension AppDelegate{
    func addNotificationAction(){
        let acceptAction = UNNotificationAction(identifier: ConstantMessage.kACCEPTACTION,
                                                title: ConstantMessage.kAccept,
                                                options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: ConstantMessage.kDECLINEACTION,
                                                 title: ConstantMessage.kDecline,
                                                 options: UNNotificationActionOptions(rawValue: 0))
        let openAction = UNNotificationAction(identifier: ConstantMessage.kOpenNotification,
                                              title: "",
                                              options: UNNotificationActionOptions.foreground)
        
        // Define the notification type
        if #available(iOS 11.0, *) {
            let meetingInviteCategory =
                UNNotificationCategory(identifier: ConstantMessage.kINVITATION,
                                       actions: [acceptAction, declineAction],
                                       intentIdentifiers: [],
                                       hiddenPreviewsBodyPlaceholder: "",
                                       options: .customDismissAction)
            _ = UNNotificationCategory(identifier: ConstantMessage.kCustomPush, actions: [openAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([meetingInviteCategory])
        }
        else {
            // Fallback on earlier versions
        }
        center.requestAuthorization(options: [.sound,.alert,.badge], completionHandler: { (granted, error) in
            // Enable or disable features based on authorization
        })
    }
    func refressLists()
    {
        newNotificationCome = true
        let toopViewController = UIApplication.topViewController()
        if toopViewController is ShowPrayerListViewController
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantMessage.kRefressMyListPushNotification), object: nil)
        }else if toopViewController is PrayerRequestViewController
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantMessage.kRefressRequestPushNotification), object: nil)
        }else if toopViewController is BubblesViewController
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ConstantMessage.kRefressBubblePushNotification), object: nil)
        }
    }
    
    func handleNotifications(userInfo: NSDictionary, response : UNNotificationResponse)
    {
    }
    
    func acceptDeclineWebServices(inviteId : String, isAccept : Int) {
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(inviteId, forKey: ConstantMessage.kInvitationID)
        perameter.setValue(isAccept, forKey: ConstantMessage.kIsAccept)
        ServiceUtility.callWebService(ACCEPT_DECLINE_TAG_REQUEST, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    
                }
            }
            else
            {
                
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        debugPrint(ConstantMessage.kNotificationError)
    }
    
    func askForNotification()
    {
        if(((UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) == nil) || ( (UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) != nil) && (UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) as! String == ""))))
        {
            let alertView = UIAlertController(title: ConstantMessage.kNotification, message:ConstantMessage.kEnableNotification, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: ConstantMessage.kCancel, style: .cancel, handler: nil))
            alertView.addAction(UIAlertAction(title: ConstantMessage.kOk, style: .default, handler: { (alertAction) -> Void in
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl
                {
                    UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(["" : ""]), completionHandler: { (status) in
                        //code
                    })
                }
            }))
            self.window?.rootViewController?.present(alertView, animated: true, completion: nil)
        }
    }
        func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data )
        {
            
            let tokenParts = deviceToken.map { data -> String in
                return String(format: "%02.2hhx", data)
            }
            let token = tokenParts.joined()
            UserDefaults.standard.set(token, forKey: ConstantMessage.kDeviceToken)
            UserDefaults.standard.synchronize()
            DefaultsManager.share.deviceToken = token
            self.updateTokenWebServices()
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        {
            // custom code to handle push while app is in the foreground
            // 1 : Share Lounge
            // 2 : add comment in lounge
            let rootViewController = UIApplication.topViewController()
            if rootViewController is BubblesViewController
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:ConstantMessage.kRefressBubblePushNotification), object: nil)
            }else
            {
                newNotificationCome = true
            }
            //NEW CR 18May 2020
            completionHandler([.alert, .badge, .sound])
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
        {
            let userInfo = response.notification.request.content.userInfo
            // refress list
            let rootViewController = UIApplication.topViewController()
            if rootViewController is BubblesViewController
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:ConstantMessage.kRefressBubblePushNotification), object: nil)
            }else
            {
                newNotificationCome = true
            }
            if (userInfo as NSDictionary).object(forKey: ConstantMessage.kAps) != nil && ((userInfo as NSDictionary).object(forKey: ConstantMessage.kAps) is NSDictionary)
            {
                let payload = (userInfo as NSDictionary).object(forKey: ConstantMessage.kAps) as! NSDictionary
                if (payload.object(forKey: ConstantMessage.kAlert)) != nil {
                    let alert = payload.object(forKey: ConstantMessage.kAlert) as! NSDictionary
                    if (alert.object(forKey: ConstantMessage.kAction) != nil && alert.object(forKey: ConstantMessage.kAction) is String &&
                            alert.object(forKey: ConstantMessage.kAction) as! String != "" && alert.object(forKey: ConstantMessage.kActionID) != nil && alert.object(forKey: ConstantMessage.kActionID) is String && alert.object(forKey: ConstantMessage.kActionID) as! String != "")
                    {
                        let storyboard = UIStoryboard(name: ConstantMessage.kMain, bundle: nil)
                        if alert.object(forKey: ConstantMessage.kAction) as! String == "1" || alert.object(forKey: ConstantMessage.kAction) as! String == "5"
                        {
                            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kShowPrayerListViewController) as! ShowPrayerListViewController
                            vc.prayerId = alert.object(forKey: ConstantMessage.kActionID) as! String
                            let navigationController = self.window?.rootViewController as! UINavigationController
                            navigationController.pushViewController(vc, animated: false)
                        }else if alert.object(forKey: ConstantMessage.kAction) as! String == "2"
                        {
                            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kPrayerRequestViewController) as! PrayerRequestViewController
                            vc.prayerId = alert.object(forKey: ConstantMessage.kActionID) as! String
                            let navigationController = self.window?.rootViewController as! UINavigationController
                            navigationController.pushViewController(vc, animated: false)
                        }else if alert.object(forKey: ConstantMessage.kAction) as! String == "6"
                        {
                            let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupListViewController) as! GroupListViewController
                            let navigationController = self.window?.rootViewController as! UINavigationController
                            navigationController.pushViewController(vc, animated: false)
                        }else if alert.object(forKey: ConstantMessage.kAction) as! String == "4"{
                            let invitationId = (alert.object(forKey: ConstantMessage.kActionID) as! String)
                            switch response.actionIdentifier {
                            case ConstantMessage.kACCEPTACTION:
                                self.acceptDeclineWebServices(inviteId: invitationId, isAccept: 1)
                                break
                            case ConstantMessage.kDECLINEACTION:
                                self.acceptDeclineWebServices(inviteId: invitationId, isAccept: 2)
                                break
                                // Handle other actions…
                            default:
                                let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kBubblesViewController) as! BubblesViewController
                                DefaultsManager.share.isNotification = true
                                DefaultsManager.share.isShowTagInvitation = true
                                let navigationController = self.window?.rootViewController as! UINavigationController
                                navigationController.pushViewController(vc, animated: false)
                                break
                            }
                            // Always call the completion handler wisShowTagInvitationhen done.
                            completionHandler()
                        }else if alert.object(forKey: ConstantMessage.kAction) as! String == "3"{

                        }
                    }
                }
            }
        }
      func registerForPushNotification()
       {
           let types = UIUserNotificationType([UIUserNotificationType.alert, UIUserNotificationType.sound, UIUserNotificationType.badge])
           let settings = UIUserNotificationSettings(types: types, categories: nil)
           UIApplication.shared.registerUserNotificationSettings(settings)
           UIApplication.shared.registerForRemoteNotifications()
       }
    func updateTokenWebServices() {
        if UserManager.shareManger.userID == nil
        {
            return
        }
        
        if(((UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) == nil) || ( (UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) != nil) && (UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) as! String == ""))))
        {
            return
        }
        
        if !(((UserDefaults.standard.object(forKey: ConstantMessage.kIsTokenUpdated) == nil) || ( (UserDefaults.standard.object(forKey:ConstantMessage.kIsTokenUpdated) != nil) && (UserDefaults.standard.object(forKey: ConstantMessage.kIsTokenUpdated) as! Bool == false))))
        {
            return
        }
        
        if(!ServiceUtility.hasConnectivity())
        {
            return
        }
        
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(UserDefaults.standard.object(forKey: ConstantMessage.kDeviceToken) as! String , forKey: ConstantMessage.kDeviceToken)
        perameter.setValue("1" , forKey: ConstantMessage.kDeviceType)
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField: ConstantMessage.kAPIKEY)
        manager.post(UPDATE_TOKE_URL, parameters: perameter, progress: nil, success:
            {
                requestOperation, response  in
                ServiceUtility.hideProgressHudInView()
                let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    UserDefaults.standard.set(true, forKey: ConstantMessage.kIsTokenUpdated)
                }else
                {
                    UserDefaults.standard.set(false, forKey: ConstantMessage.kIsTokenUpdated)
                }
                UserDefaults.standard.synchronize()
        }, failure: {
            requestOperation, error in
        })
    }
}

//MARK:- LogOut
extension AppDelegate{
    func checkForLogoutApi(error :Error) -> Bool
       {
        if  (error.localizedDescription.description == "\(ConstantMessage.kRequestUnauthorized) (401)") ||
                (error.localizedDescription.description == "\(ConstantMessage.kRequestForbidden) (403)") ||
               (error.localizedDescription.description == "\(ConstantMessage.kRequestUnauthorized) (500)")
           {
               return true
           }
           return false
       }
       
       func checkForLogoutApi(dataFromServer :NSDictionary) -> Bool
       {
        if(dataFromServer.object(forKey: ConstantMessage.kMessage) != nil)  && (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString == ConstantMessage.kInvalidAPIkey || dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString == ConstantMessage.kEnoughPermissions ||  dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString ==  ConstantMessage.LogOutMessage )
           {
               self.logOutFunction()
               return true
           }
           return false
       }
       
       func logOutFunction()
       {
           let navigationController = self.window?.rootViewController as! UINavigationController
           if navigationController is BubblesNavigationController
           {
               let storyboard = UIStoryboard(name: ConstantMessage.kMain, bundle: nil)
               if navigationController.viewControllers.count == 0
               {
                let loginVc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kRootNavigationViewController) as! RootNavigationViewController
                   let applicationFrame = UIScreen.main.bounds
                   let window = UIWindow(frame: applicationFrame)
                   if #available(iOS 13.0, *) {
                       window.overrideUserInterfaceStyle = .light
                   } else {
                       // Fallback on earlier versions
                   }
                   loginVc.isNavigationBarHidden = true
                   window.rootViewController = loginVc
                   window.makeKeyAndVisible()
                   self.window = window
               }else
               {
                let loginVc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kHomeViewController) as! HomeViewController
                   let array = NSMutableArray()
                   array.addObjects(from: (navigationController.viewControllers))
                   array.replaceObject(at: 0, with: loginVc)
                   navigationController.viewControllers = array as NSArray as! [UIViewController]
                   navigationController.popToRootViewController(animated: true)
               }
           }else
           {
                let storyboard = UIStoryboard(name: ConstantMessage.kMain, bundle: nil)
            let loginVc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kHomeViewController) as! HomeViewController
                let array = NSMutableArray()
                array.addObjects(from: (navigationController.viewControllers))
                array.replaceObject(at: 0, with: loginVc)
                navigationController.viewControllers = array as NSArray as! [UIViewController]
                navigationController.popToRootViewController(animated: true)
           }
           // clear Drive Data
           conatactManger.deleteAllRecord()
           UIApplication.shared.applicationIconBadgeNumber = 0
           UserDefaults.standard.removeObject(forKey: ConstantMessage.kUserId)
           UserDefaults.standard.removePersistentDomain(forName : Bundle.main.bundleIdentifier!)
           UserDefaults.standard.synchronize()
       }
}

//MARK:- Need to check
extension AppDelegate{
    func shareLinkBeyondTheApp(groupData : NSDictionary, isPrayerTitle:Bool,isTag : Bool,vctr : UIViewController = UIViewController(),isGroupSharing :Bool = false)
        {
            var groupName : String = ConstantMessage.kiPray
            var prayerId = ""
            var isGroup = false
            if groupData.object(forKey: ConstantMessage.kPrayerID) != nil {
                prayerId = (groupData.object(forKey: ConstantMessage.kPrayerID) as! String)
            }
            if groupData.object(forKey: ConstantMessage.kGroupPrayerID) != nil {
                isGroup = true
                prayerId = (groupData.object(forKey: ConstantMessage.kGroupPrayerID) as! String)
            }
            if groupData.object(forKey: ConstantMessage.kCreatorName) != nil
            {
                groupName = (groupData.object(forKey: ConstantMessage.kCreatorName) as? String)!
            }else if groupData.object(forKey: ConstantMessage.kGroupName) != nil
            {
                groupName = (groupData.object(forKey: ConstantMessage.kGroupName) as? String)!
            }else if groupData.object(forKey: ConstantMessage.kName) != nil
            {
                groupName = (groupData.object(forKey: ConstantMessage.kName) as? String)!
            }
            let uniqueCode = self.randomString(length: 6)
            let navigationController = self.window?.rootViewController as! UINavigationController
            var text = ""
            let groupText = (isGroupSharing) ? "This prayer in the iPray Group \"\(groupName)\" is written for me" : ""
            if isPrayerTitle {
                var groupPrayerTitle : String = ""
                if groupData.object(forKey: ConstantMessage.kGroupPrayerTitle) != nil {
                     groupPrayerTitle = (groupData.object(forKey: ConstantMessage.kGroupPrayerTitle) as? String)!
                }else if groupData.object(forKey: ConstantMessage.kTitle) != nil {
                    groupPrayerTitle = (groupData.object(forKey: ConstantMessage.kTitle) as? String)!
                }else if  groupData.object(forKey: ConstantMessage.kDescription) != nil {
                     groupPrayerTitle = (groupData.object(forKey: ConstantMessage.kDescription) as? String)!
                }
                if isTag{
                     text = "I have tagged you for prayer \'\(groupPrayerTitle)\'! \(groupText).\n\n Don't have iPray? Get it here https://www.ipray.me/download and enter code \(uniqueCode) to accept my prayer for you.\n\n Have iPray? Let me know so I can tag you in-app from \"My Phone Contacts\""
                }else{
                     text = "Will you pray for me \'\(groupPrayerTitle)\'? \(groupText).\n\nDon't have iPray? Get it here https://www.ipray.me/download and enter code \"\(uniqueCode)\" to accept my prayer for you.\n\nHave iPray? Let me know so I can tag you in-app from \"My Phone Contacts"
                }
            }else{
                 text = "I would like to share \"\(groupName)\" on iPray with you. Go to My Groups in your iPray on your smartphone and search for \"\(groupName)\".  Don’t have iPray? Get it free at https://www.ipray.me/download"
            }
            //New change on 17-04-2020
            let textToShare = [text]//[text, link]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = navigationController.view
            if isTag{
                activityViewController.setValue(ConstantMessage.kAPrayerForYou, forKey: ConstantMessage.kSubject)
            }
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop]
           // if isTag {
                activityViewController.completionWithItemsHandler = { activity, success, items, error in
                    if isGroup {
                        if vctr is AddPrayerViewController{
                            let tempVCTR =  vctr as! AddPrayerViewController
                            if success{
                                tempVCTR.removefromsuperview()
                            }
                        }else if (self.window!.rootViewController?.children[0].children.count)! > 0{
                            for item in (self.window!.rootViewController?.children[0].children)!{
                                if item is AddPrayerViewController{
                                   if success{
                                    let VCTR = item as! AddPrayerViewController
                                       VCTR.removefromsuperview()
                                   }
                                }
                            }
                        }
                        self.tagGroupPrayer(prayedId: prayerId, shareCode: uniqueCode)
                    }else{
                       if vctr is AddPrayerViewController{
                           let tempVCTR =  vctr as! AddPrayerViewController
                           if success{
                               tempVCTR.removefromsuperview()
                           }else{
                             tempVCTR.view.isHidden = false
                           }
                       }else
                        if (self.window!.rootViewController?.children[0].children.count)! > 0{
                            for item in (self.window!.rootViewController?.children[0].children)!{
                                if item is AddPrayerViewController{
                                  let VCTR = item as! AddPrayerViewController
                                  if success{
                                    VCTR.removefromsuperview()
                                   }else{
                                     VCTR.view.isHidden = false
                                   }
                                }
                            }
                        }else{
                         self.sendInvitationCode(prayedId: prayerId, shareCode: uniqueCode)
                        }
                    }
                }
           // }
            navigationController.present(activityViewController, animated: true, completion: nil)
        }
        
        func randomString(length: Int) -> String {
            return String((0..<length).map{ _ in ConstantMessage.kLetters.randomElement()! })
        }
        
        func tagGroupPrayer(prayedId : String, shareCode : String) {
            let perameter = NSMutableDictionary()
            perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
            perameter.setValue(prayedId, forKey: ConstantMessage.kUserId)
            ServiceUtility.callWebService(TAG_GROUP_PRAYER, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
                if success {
                    if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                    {
                        if dataFromServer.object(forKey: ConstantMessage.kUserId) != nil{
                            let updatedPrayerId = dataFromServer.object(forKey: ConstantMessage.kUserId) as! String
                            self.sendInvitationCode(prayedId: updatedPrayerId, shareCode: shareCode)
                        }
                    }else{
                    }
                }
                else
                {
                }
            }
        }
        
        func sendInvitationCode(prayedId : String, shareCode : String) {
            let perameter = NSMutableDictionary()
            perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
            perameter.setValue(prayedId, forKey: ConstantMessage.kUserId)
            perameter.setValue(shareCode, forKey: ConstantMessage.kShareCode)
            //ServiceUtility.hideProgressHudInView()
            ServiceUtility.callWebService(SEND_TAG_INVITATION_CODE, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
               // ServiceUtility.hideProgressHudInView()
                if success {
                    if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                    {
                        
                    }
                }
                else
                {
                    
                }
            }
        }
        
        func getPrayingCount(data: NSDictionary)-> Int
        {
            var taggingCount = 0
            if data.object(forKey: ConstantMessage.kAlreadyShared) != nil{
                if let taggingArr = data.object(forKey: ConstantMessage.kAlreadyShared) as? NSArray{
                    taggingCount = taggingArr.count
                }else{
                    taggingCount = 0
                }
            }
            return taggingCount
        }
        
        func getPrayingCountinPrayerRequest(data: NSDictionary)-> Int
        {
            var prayingCount = 0
            if data.object(forKey: ConstantMessage.kTotalPraying) != nil
            {
                if data.object(forKey: ConstantMessage.kTotalPraying)  is String
                {
                    prayingCount = Int(data.object(forKey: ConstantMessage.kTotalPraying)  as! String)!
                }else if data.object(forKey: ConstantMessage.kTotalPraying)  is Int
                {
                    prayingCount = data.object(forKey: ConstantMessage.kTotalPraying)  as! Int
                }
            }
            return prayingCount
        }
     func sortPrayerUsingPrayStatus(prayerList: NSArray) -> NSArray
        {
            let newPrayerList = NSMutableArray()
            for i in 0 ..< prayerList.count
            {
                let prayerIndexData = (prayerList[i] as! NSDictionary).mutableCopy()  as! NSMutableDictionary
                let status = ApplicationDelegate.selfcheckPrayerStatus(prayerData : prayerIndexData as NSDictionary)
                let disString = (prayerIndexData.object(forKey: ConstantMessage.kDescription) as! String)
                let heightofdiscription = ApplicationDelegate.heigthOfView(text: disString)
                prayerIndexData.setValue(status, forKey: ConstantMessage.kPrayStatus)
                prayerIndexData.setValue(heightofdiscription, forKey: ConstantMessage.kHeight)
                prayerIndexData.setValue(false, forKey: ConstantMessage.kShowfull)
                newPrayerList.add(prayerIndexData)
            }
            return newPrayerList as NSArray
        }
        
        func sortGroupPrayerUsingPrayStatus(prayerList: NSMutableArray) -> NSArray
        {
            let newPrayerList = NSMutableArray()
            for i in 0 ..< prayerList.count
            {
                let prayerIndexData = (prayerList[i] as! NSDictionary).mutableCopy()  as! NSMutableDictionary
                let disString = (prayerIndexData.object(forKey: ConstantMessage.kGroupPrayerDescription) as! String)
                let heightofdiscription = ApplicationDelegate.heigthOfView(text: disString)
                prayerIndexData.setValue(heightofdiscription, forKey: ConstantMessage.kHeight)
                prayerIndexData.setValue(false, forKey: ConstantMessage.kShowfull)
                newPrayerList.add(prayerIndexData)
            }
            return newPrayerList as NSArray
        }
        
        func selfcheckPrayerStatus(prayerData : NSDictionary) -> Int
        {
            if prayerData[ConstantMessage.kSetAnswered] != nil && prayerData[ConstantMessage.kSetAnswered] as! String == "0"
            {
                if  prayerData[ConstantMessage.kStatus] as! String == "1"
                {
                    return 1
                }else
                {
                    return 3
                }
            }else
            {
                if  prayerData[ConstantMessage.kStatus] as! String == "1"
                {
                    return 2
                }else
                {
                    return 4
                }
            }
        }
        
        func checkPrayerStatus(prayerData : NSDictionary) -> Int
        {
            if prayerData[ConstantMessage.kSetAnswered] != nil && prayerData[ConstantMessage.kSetAnswered] as! String == "0"
            {
                if  prayerData[ConstantMessage.kStatus] as! String == "1"
                {
                    return 1
                }else
                {
                    return 2
                }
            }else
            {
                if  prayerData[ConstantMessage.kStatus] as! String == "1"
                {
                    return 3
                }else
                {
                    return 4
                }
            }
        }
        
        func prayerStatusForPraying(prayerData : NSDictionary) -> Int
        {
            let status = self.checkPrayerStatus(prayerData : prayerData)
            switch status {
            case 1:
                return 2
            case 2:
                return 1
            case 3:
                return 4
            case 4:
                return 3
            default:
                return 1
            }
        }
        
        // calculate the frame of the lable according to text
        func heigthOfView( text:String) -> CGFloat
        {
            let frame =   CGRect(x: 0, y: 0, width: (window?.screen.bounds.width)! - 35 , height: CGFloat.greatestFiniteMagnitude)
            let dataName:UILabel = UILabel(frame: frame)
            dataName.numberOfLines = 0
            dataName.lineBreakMode = .byTruncatingTail
            dataName.font =  UIFont(name: ConstantMessage.kMontserratLight, size: 12.0)
            dataName.textAlignment = .left
            dataName.clipsToBounds = true
            dataName.text = "\(text)"
            dataName.sizeToFit()
            return dataName.frame.size.height
        }
}

//MARK:-
extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension String
{
    func getsubtringFromString(str:String,startingPnt:Int,endPnt:Int ) -> String
    {
        let startIndex = str.index(str.startIndex, offsetBy: startingPnt)
        let endIndex = str.index(str.startIndex, offsetBy: endPnt)
        return String(str[startIndex...endIndex])       // "String"
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


//MARK:-
extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var rootViewController: RootNavigationViewController {
        return window!.rootViewController as! RootNavigationViewController
    }
}

class Application : NSObject{
    static var RootView : RootNavigationViewController{
        return AppDelegate.shared.rootViewController
    }
}

enum AppStoryboard : String{
    case Main   = "Main"
    case Group  = "Group"
    
    var instance : UIStoryboard{
        return UIStoryboard(name: self.rawValue, bundle: .main)
    }
}

