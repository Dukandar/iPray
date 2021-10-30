//
//  TagRequestListViewController.swift
//  iPray
//
//  Created by zeba on 16/04/19.
//  Copyright © 2019 TrivialWorks. All rights reserved.
//

import UIKit

class TagRequestListViewController: UIViewController, HelpViewDelegate {
    
    //MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helpBtn: UIButton!
    
    //MARK: - Variable
    var isMyPrayer = false
    var tagReqListArray = NSMutableArray()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 56.0
        self.tableView.rowHeight = UITableView.automaticDimension
        checkHelpButtonVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tagRequestListWebServices()
    }
    
    //MARK: - Button Action
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
       backToPrevious()
    }
    
    @IBAction func helpBtnClicked(_ sender: UIButton) {
       openHelpPopUp()
    }
    
    @IBAction func acceptDeclineBtnClicked(_ sender: UIButton) {
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)
        if let data = self.tagReqListArray.object(at: cellIndexPath!.row) as? NSDictionary {
            if let invitationId = data.object(forKey: ConstantMessage.kInvitationID) as? String {
                if sender.tag == 13 {
                    acceptDeclineWebServices(inviteId: invitationId, isAccept: true, index: cellIndexPath!.row,prayerID: data.object(forKey: ConstantMessage.kPrayerID) as! String)
                }else{
                    acceptDeclineWebServices(inviteId: invitationId, isAccept: false, index: cellIndexPath!.row,prayerID: data.object(forKey: ConstantMessage.kPrayerID) as! String)
                }
            }else{
                return
            }
        }else{
            return
        }
    }
    
    func openHelpPopUp(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kHelpViewController) as! HelpViewController
        vc.delegate = self
        vc.isUpdate = false
        vc.pageType = 2
        self.addChild(vc)
        self.view.addSubview(vc.view)
    }
    
    func backToPrevious(){
        if isMyPrayer {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func isHelpButtonShow() {
        checkHelpButtonVisibility()
    }
    
    func checkHelpButtonVisibility(){
        if UserDefaults.standard.object(forKey: ConstantMessage.kIsShowTagHelp) != nil && UserDefaults.standard.object(forKey: ConstantMessage.kIsShowTagHelp) as! Bool == false {
            //helpBtn.isHidden = true
        }else{
            //helpBtn.isHidden = false
        }
    }
}

//MARK: - TableView Delegate
extension TagRequestListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagReqListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "RequestCell")!
        let userImage = cell.viewWithTag(11) as! UIImageView
        let message = cell.viewWithTag(12) as! UILabel
        let acceptBtn = cell.viewWithTag(13) as! UIButton
        let declineBtn = cell.viewWithTag(14) as! UIButton
        let prayerTitle = cell.viewWithTag(15) as! UILabel
        
        userImage.layer.cornerRadius = userImage.frame.height / 2
        
        acceptBtn.layer.cornerRadius = acceptBtn.frame.height / 2
        acceptBtn.layer.borderWidth = 1
        acceptBtn.layer.borderColor = UIColor(red: 26.0/255.0, green: 177.0/255.0, blue: 94.0/255.0, alpha: 1).cgColor
        
        declineBtn.layer.cornerRadius = acceptBtn.frame.height / 2
        declineBtn.layer.borderWidth = 1
        declineBtn.layer.borderColor = UIColor(red: 255.0/255.0, green: 0, blue: 0, alpha: 1).cgColor
        
        if let data = self.tagReqListArray.object(at: indexPath.row) as? NSDictionary{
            if data.object(forKey: ConstantMessage.kSenderImage) != nil && data.object(forKey: ConstantMessage.kSenderImage) as! String != "" {
                userImage.setImageWith(URL(string: (data.object(forKey: ConstantMessage.kSenderImage) as! String))!, placeholderImage: UIImage(named: ConstantMessage.kPlaceholderProfileImage))
            }else{
                userImage.image = UIImage(named: ConstantMessage.kPlaceholderProfileImage)
            }
            if data.object(forKey: ConstantMessage.kMessage) != nil && data.object(forKey: ConstantMessage.kMessage) as! String != "" {
                message.text = (data.object(forKey: ConstantMessage.kMessage) as! String)
            }else{
                message.text = ""
            }
            if data.object(forKey: ConstantMessage.kPrayerTitle) != nil && data.object(forKey: ConstantMessage.kPrayerTitle) as! String != "" {
                prayerTitle.text = (data.object(forKey: ConstantMessage.kPrayerTitle) as! String)
            }else{
                prayerTitle.text = ""
            }
        }
        
        return cell
    }
}

//MARK: - WebService
extension TagRequestListViewController{
    func tagRequestListWebServices() {
        
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        
        ServiceUtility.callWebService(GET_INVITETION_LIST, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                
                
                // do chnage in views.
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    let data = dataFromServer.object(forKey: ConstantMessage.kData) as! NSArray
                    let tempArray = data.mutableCopy() as! NSMutableArray
                    for i in (0..<tempArray.count).reversed(){
                            self.tagReqListArray.add(tempArray.object(at: i))
                    }
                    
                    self.tableView.reloadData()
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

    func acceptDeclineWebServices(inviteId : String, isAccept : Bool,index : Int,prayerID : String) {
        
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(inviteId, forKey: ConstantMessage.kInvitationID)
        if isAccept{
            perameter.setValue(1, forKey: ConstantMessage.kIsAccept)
        }else{
            perameter.setValue(2, forKey: ConstantMessage.kIsAccept)
        }
        
        ServiceUtility.callWebService(ACCEPT_DECLINE_TAG_REQUEST, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    self.tagReqListArray.removeObject(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
    
    //MARK: - Pay for all request
    func payForAllRequest(prayerID : String,index : Int){
       let perameter = NSMutableDictionary()
       perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
       perameter.setValue(prayerID, forKey: ConstantMessage.kPrayerID)
       perameter.setValue(2, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebServiceWithoutProgressMessage(START_PRAYER_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                self.tagReqListArray.removeObject(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
}




