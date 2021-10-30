//
//  CopyPrayerListViewController.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 17/01/18.
//  Copyright © 2018 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class CopyPrayerListViewController: UIViewController,UITextFieldDelegate , UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var prayerContainerView: UIView!
    
    //MARK: - Variables
    var prayerId = ""
    var prayerModelView : PrayerListModulerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPrayerListView()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
       // NotificationCenter.default.removeObserver("refressMyListPushNotification")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // NotificationCenter.default.addObserver(self, selector: #selector(CopyPrayerListViewController.refressListForNewPushNotification), name: NSNotification.Name(rawValue: "refressMyListPushNotification"), object: nil)
        
        prayerModelView.PageNo = 1
        prayerModelView.getprayerListWebService()
    }
    
    func refressListForNewPushNotification()
    {
        prayerModelView.PageNo = 1
        prayerModelView.getprayerListWebService()
    }
    
    func addPrayerListView()
    {
        prayerModelView = (self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kPrayerListModulerViewController) as! PrayerListModulerViewController)
        prayerModelView.prayerURL  =  COPY_PRAYER_URl
        prayerModelView.delegate = self
        prayerModelView.prayerId  = prayerId
        prayerModelView.view.frame = CGRect(x: 0, y: 0, width: prayerContainerView.frame.size.width, height: prayerContainerView.frame.size.height)
        prayerContainerView.addSubview(prayerModelView.view)
        self.addChild(prayerModelView)
    }
    
    /**
     *  Action to navigate SearchIprayViewController to search prayer by name or words
     */
    
    @IBAction func searchIpray(_ sender: UIButton) {
        let searchPrayer = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kSearchIprayViewController) as! SearchIprayViewController

        self.navigationController?.pushViewController(searchPrayer, animated: true)
    }
    
    func openAddPrayerView( prayerData : NSDictionary,isupdate : Bool)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddPrayerViewController) as! AddPrayerViewController
        vc.deligate = self
        vc.isUpdatePrayer = isupdate
        vc.editedPrayerData = prayerData
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
        
    }
    
    
    /**
     *  Action to show add prayer popUp screen
     */
    
    @IBAction func showAddPrayerPopup(_ sender: UIButton) {
        let data =  NSDictionary()
        openAddPrayerView(prayerData: data,isupdate: false)
    }
    
    
    //
    @IBAction func crossBtnClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

extension CopyPrayerListViewController : refressPrayerList
{
    func reloadView(ishare: Bool, data: NSDictionary, isTag: Bool,message: String) {
        newNotificationCome = true
        if ishare
        {
            prayerModelView.openShareViewController(prayerData: data)
            
        }else
        {
            prayerModelView.PageNo = 1
            prayerModelView.getprayerListWebService()
        }
    }
}
extension CopyPrayerListViewController : PrayerListModulerDeligate
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
    
    func openAddprayerPopViewController(prayerData: NSDictionary, isupdate: Bool, isreminder: Bool, isOnlyReminder: Bool) {
        self.openAddPrayerView( prayerData: prayerData,isupdate: true)
    }
}


