//
//  PrayerRequestViewController.swift
//  iPray
//
//  Created by vivek on 17/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class PrayerRequestViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet  var notificationLabel: UILabel!
    @IBOutlet var headerName: UILabel!
    @IBOutlet weak var prayerContainerView: UIView!
    
    // MARK: - Variables
    var prayerModelView : PrayerListModulerViewController!
    var friendsUSerId : String = ""
    var headeruserName: String = ""
    var prayerId : String = ""
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setHeaderName()
        self.addPrayerListView()
        notificationLabel.layer.cornerRadius=11
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(ConstantMessage.kRefressRequestPushNotification)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(PrayerRequestViewController.refressListForNewPushNotification), name: NSNotification.Name(rawValue: ConstantMessage.kRefressRequestPushNotification), object: nil)
        prayerModelView.PageNo = 1
        prayerModelView.getprayerListWebService()
    }
    
    @objc func refressListForNewPushNotification()
    {
        prayerModelView.PageNo = 1
        prayerModelView.getprayerListWebService()
    }

    //MARK: - Button Action
    @IBAction func cancel(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchIpray(_ sender: UIButton) {
        let searchPrayer = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kSearchIprayViewController) as! SearchIprayViewController
        self.navigationController?.pushViewController(searchPrayer, animated: true)
    }
    
    @IBAction func showAddPrayerPopup(_ sender: UIButton) {
        let data =  NSDictionary()
        openAddPrayerView(prayerData: data,isOnlyreminder : false)
    }
    
    func addPrayerListView()
    {
        prayerModelView = (self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kPrayerListModulerViewController) as! PrayerListModulerViewController)
        prayerModelView.prayerURL  =  GET_OTHER_USER_PRAYER_LIST_URL
        prayerModelView.delegate = self
        prayerModelView.friendsUSerId  = friendsUSerId
        prayerModelView.prayerId  = prayerId
        prayerModelView.view.frame = CGRect(x: 0, y: 0, width: prayerContainerView.frame.size.width, height: prayerContainerView.frame.size.height)
        prayerContainerView.addSubview(prayerModelView.view)
        self.addChild(prayerModelView)
    }
    
    func openAddPrayerView(prayerData : NSDictionary,isOnlyreminder : Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddPrayerViewController) as! AddPrayerViewController
        vc.deligate = self
        vc.isOnlyreminder = isOnlyreminder
        vc.isUpdatePrayer = false
        vc.editedPrayerData = prayerData
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
    
    func setHeaderName()
    {
        if self.headeruserName != ""
        {
            self.headerName.text = self.headeruserName
        }else
        {
            self.headerName.text = ConstantMessage.kPRAYERREQUESTSOFME
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PrayerRequestViewController : refressPrayerList
{
    func reloadView(ishare: Bool, data: NSDictionary, isTag: Bool,message: String) {
        newNotificationCome = true
        if ishare
        {
            prayerModelView.openShareViewController(prayerData: data)
        } else
        {
            prayerModelView.PageNo = 1
            prayerModelView.getprayerListWebService()
        }
    }
}

extension PrayerRequestViewController : PrayerListModulerDeligate
{
    func changeHeaderName(name : String)
    {
        headeruserName = name
        self.setHeaderName()
    }
    
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
    func openAddprayerPopViewController(prayerData: NSDictionary, isupdate: Bool, isreminder: Bool, isOnlyReminder: Bool) {
         openAddPrayerView(prayerData : prayerData,isOnlyreminder : true)
    }
}

