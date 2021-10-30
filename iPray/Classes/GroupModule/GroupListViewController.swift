//
//  GroupListViewController.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 20/11/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//
import UIKit
import AFNetworking

class GroupListViewController: UIViewController
{
    // MARK: - Outlets
    @IBOutlet var searchGroups: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var splitView: UISegmentedControl!
    @IBOutlet var shareView: UIView!
  
    // MARK: - Variables
    var refreshControl: UIRefreshControl!
    var allGroupList = NSMutableArray()
    var myGrouptArrayList = NSMutableArray()
    var PageNo = 1
    var isForNewList = false
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        shareView.layer.cornerRadius = 20
        shareView.layer.borderColor = UIColor.white.cgColor
        shareView.layer.borderWidth = 1.0
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: ConstantMessage.kPullToRefresh)
        refreshControl.addTarget(self, action: #selector(pulltoRrefresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableView.automaticDimension
        splitView.selectedSegmentIndex = 1
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        PageNo = 1
        isForNewList = true
        self.getAllGroupListWebService(text : (searchGroups.text?.trimmingCharacters(in: CharacterSet.whitespaces))!)
    }
    
    // MARK: - Button Action
    @objc func pulltoRrefresh(sender:AnyObject)
    {
        PageNo = 1
        if self.searchGroups.text != ""
        {
            isForNewList = true
        }
        self.searchGroups.text = ""
        refreshControl.endRefreshing()
        self.getAllGroupListWebService(text : (searchGroups.text?.trimmingCharacters(in: CharacterSet.whitespaces))!)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    /**
     *  Action to send message to contacts to share prayer
     */
    
    @IBAction func splitViewValuechange(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        searchGroups.text = ""
        self.PageNo = 1
        self.getAllGroupListWebService(text : (searchGroups.text?.trimmingCharacters(in: CharacterSet.whitespaces))!)
    }

    @IBAction func addNewGroup(_ sender: UIButton) {
        self.view.endEditing(true)
        let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
        let shareiPray=storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kCreateGroupViewController) as! CreateGroupViewController
        self.navigationController?.pushViewController(shareiPray, animated: true)
    }
    
    @IBAction func openGroupProfile(_ sender: UIButton) {
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)! as IndexPath
        var indexData : NSDictionary!
        let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupSettingViewController) as! GroupSettingViewController
        if splitView.selectedSegmentIndex == 0
        {
            indexData = (allGroupList.object(at: cellIndexPath.row) as! NSDictionary)
        }else
        {
            indexData = (myGrouptArrayList.object(at: cellIndexPath.row) as! NSDictionary)
        }
        vc.isFromGroupList = true
        vc.groupProfileDic = indexData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func requestAndWallButtonCliked(_ sender: UIButton) {
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)! as IndexPath
        let storyboard = UIStoryboard(name: ConstantMessage.kGroup, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupWallViewController) as! GroupWallViewController
        if splitView.selectedSegmentIndex == 0
        {
            let indexData = allGroupList.object(at: cellIndexPath.row) as! NSDictionary
            if indexData.object(forKey: ConstantMessage.kIsMember) as? String == "0"
            {
                if indexData.object(forKey: ConstantMessage.kIsPublic) as? String == "0"
                {
                    // password
                   openPasswordView(index :cellIndexPath.row )
                }else
                {
                    // send request
                    self.sendRequestToAddGroupWebServices(index :cellIndexPath.row ,password : "")
                }
              // (indexData.object(forKey: "groupID") as? String)!
            }else
            {
                if indexData.object(forKey: ConstantMessage.kIsCoAdmin) as? String == "1"
                {
                    // open for admin
                    vc.isGroupAdmin = true
                }else
                {// open for member
                    vc.isGroupAdmin = false
                }
                vc.groupDiscription = (indexData.mutableCopy() as! NSMutableDictionary)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else
        {
            let indexData = myGrouptArrayList.object(at: cellIndexPath.row) as! NSDictionary
            // open for admin
            if indexData.object(forKey: ConstantMessage.kIsCoAdmin) as? String == "1"
            {
                // open for admin
                vc.isGroupAdmin = true
            }else
            {// open for member
                vc.isGroupAdmin = false
            }
            vc.groupDiscription = (indexData.mutableCopy() as! NSMutableDictionary)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func shareGroupButtonCliked(_ sender: UIButton) {
        let pointInTable : CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)! as IndexPath
        let indexData : NSDictionary!
        if splitView.selectedSegmentIndex == 0 {
            if allGroupList.object(at: cellIndexPath.row) is NSDictionary {
                indexData = (allGroupList.object(at: cellIndexPath.row) as! NSDictionary)
            }else{
                return
            }
        }else{
            if myGrouptArrayList.object(at: cellIndexPath.row) is NSDictionary {
                indexData = (myGrouptArrayList.object(at: cellIndexPath.row) as! NSDictionary)
            }else{
                return
            }
        }
        ApplicationDelegate.shareLinkBeyondTheApp(groupData: indexData, isPrayerTitle: false, isTag: false)
    }
    
    func openPasswordView(index : Int)
    {
        let actionSheetController: UIAlertController = UIAlertController(title: ConstantMessage.kPRIVATEGROUP, message: ConstantMessage.kEnterGroupPassword, preferredStyle: .alert)
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: ConstantMessage.kCancel, style: .cancel) { action -> Void in
            //Do some stuff
        }
        let nextAction: UIAlertAction = UIAlertAction(title: ConstantMessage.ksubmit, style: .default) { action -> Void in
            if let field : UITextField  = actionSheetController.textFields![0] as? UITextField
            {
                let text : String = field.text!
                    if text.count == 0
                    {
                        ServiceUtility.showMessageHudWithMessage("\(ConstantMessage.kEnterGroupPassword)" as NSString, delay: ConstantMessage.kDelay)
                    }else
                    {
                         self.sendRequestToAddGroupWebServices(index : index,password : text)
                    }
            }
        }
        //Add a text field
        actionSheetController.addTextField { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.black
            textField.delegate = self
            textField.tag = 51
            textField.keyboardType = .default
            textField.placeholder = ConstantMessage.kPasswordPlaceHolder
            textField.textAlignment = .center
        }
        actionSheetController.addAction(nextAction)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}

// MARK: - TextField Delegate
extension GroupListViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // password text field
        if textField.tag == 51
        {
            return true
        }
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
    }
    
    func searchFunction(text : String)
    {
            PageNo = 1
            self.getAllGroupListWebService(text : text.trimmingCharacters(in: CharacterSet.whitespaces))
    }
}

// MARK: - TableView Delegate
extension GroupListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if splitView.selectedSegmentIndex == 0
        {
            if allGroupList.count == 0
            {
                return 1
            }
             return allGroupList.count
        }else
        {
            if myGrouptArrayList.count == 0
            {
                return 1
            }
             return myGrouptArrayList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (splitView.selectedSegmentIndex == 0 && allGroupList.count == 0) || (splitView.selectedSegmentIndex == 1 && myGrouptArrayList.count == 0)
        {
            // no group
                let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kNoCell)! as UITableViewCell
                cell.selectionStyle = .none
                return cell
        }
        let cell=tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kReuseCell)! as UITableViewCell
        let name = cell.viewWithTag(2) as! UILabel
        let groupImage = cell.viewWithTag(1) as! UIImageView
        let tick = cell.viewWithTag(3) as! UIImageView
        let shareImage = cell.viewWithTag(4) as! UIImageView
        let shareButton = cell.viewWithTag(5) as! UIButton
        let privteImg = cell.viewWithTag(6) as! UIImageView
        var indexData : NSDictionary!
        if splitView.selectedSegmentIndex == 0
        {
            indexData = (allGroupList.object(at: indexPath.row) as! NSDictionary)
            if  indexData.object(forKey: ConstantMessage.kIsPublic) as? String == "0"
            {
                privteImg.isHidden = false
            }else{
                privteImg.isHidden = true
            }
            if indexData.object(forKey: ConstantMessage.kIsMember) as? String == "1" || indexData.object(forKey: ConstantMessage.kIsCoAdmin) as? String == "1"
            {
                tick.isHidden = false
                shareImage.isHidden = false
                shareButton.isHidden = false
                if  indexData.object(forKey: ConstantMessage.kIsCoAdmin) as? String == "1"
                {
                    tick.image =  #imageLiteral(resourceName: "group_admin")   //group_admin
                }else
                {
                    tick.image =  #imageLiteral(resourceName: "shareIptay_check_image")     //shareIptay_check_image
                }
            }else
            {
                tick.isHidden = true
                shareImage.isHidden = true
                shareButton.isHidden = true
            }
            if self.allGroupList.count == indexPath.row + 1 && self.allGroupList.count % 100 == 0
            {
                PageNo = PageNo + 1
                self.getAllGroupListWebService(text : (searchGroups.text?.trimmingCharacters(in: CharacterSet.whitespaces))!)
            }
        }else
        {
            privteImg.isHidden = true
            shareImage.isHidden = false
            shareButton.isHidden = false
            indexData = (myGrouptArrayList.object(at: indexPath.row) as! NSDictionary)
            if  indexData.object(forKey: ConstantMessage.kIsCoAdmin) as? String == "1"
            {
                tick.isHidden = false
                tick.image =  #imageLiteral(resourceName: "group_admin")   //group_admin
            }else
            {
                tick.isHidden = true
            }
            if self.myGrouptArrayList.count == indexPath.row + 1 && self.myGrouptArrayList.count % 100 == 0
            {
                PageNo = PageNo + 1
                self.getAllGroupListWebService(text : (searchGroups.text?.trimmingCharacters(in: CharacterSet.whitespaces))!)
            }
        }
        name.text = indexData.object(forKey: ConstantMessage.kGroupName) as? String
        
        if indexData.object(forKey: ConstantMessage.kGroupProfilePic) as? String != ""
        {
            let url = URL(string: (indexData.object(forKey: ConstantMessage.kGroupProfilePic) as? String)!)
            groupImage.setImageWith(url!, placeholderImage: #imageLiteral(resourceName: "groupDefault"))
            groupImage.layoutIfNeeded()
        }else
        {
           groupImage.image = #imageLiteral(resourceName: "groupDefault")
        }
        cell.selectionStyle = .none
        return cell
    }
}

//MARK:- Web Service
extension GroupListViewController
{
    func getAllGroupListWebService(text : String)
    {
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(self.PageNo, forKey: ConstantMessage.kPage)
        perameter.setValue(text, forKey: ConstantMessage.kSearchText)
        var url = GET_ALL_GROUP_LIST
        if splitView.selectedSegmentIndex == 1
        {
            url = GET_MY_GROUP_LIST
        }
        manager.operationQueue.cancelAllOperations()
        ServiceUtility.callWebService(url, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            //print(dataFromServer)
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                   let serverData = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray).mutableCopy() as! NSMutableArray
                   if self.PageNo == 1
                    {
                        if self.splitView.selectedSegmentIndex == 0
                        {
                            self.allGroupList.removeAllObjects()
                            self.allGroupList = serverData.mutableCopy() as! NSMutableArray
                        }else
                        {
                            self.myGrouptArrayList.removeAllObjects()
                            self.myGrouptArrayList = serverData.mutableCopy() as! NSMutableArray
                        }
                    }else
                    {
                        if  self.splitView.selectedSegmentIndex == 0
                        {
                            self.allGroupList.addObjects(from: serverData.mutableCopy() as! [Any])
                        }else
                        {
                            self.myGrouptArrayList.addObjects(from: serverData.mutableCopy() as! [Any])
                        }
                    }
                    
                }
                else
                {
                    self.isForNewList = true
                    self.removeAllDataWhileSearch()
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
                }
            }
            else
            {
                self.isForNewList = true
                self.removeAllDataWhileSearch()
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
          self.tableView.reloadData()
        }
    }
    
    func removeAllDataWhileSearch()
    {
        if (self.searchGroups.text)?.trimmingCharacters(in: CharacterSet.whitespaces) != "" && self.PageNo == 1
        {
            if  self.splitView.selectedSegmentIndex == 0
            {
                self.allGroupList.removeAllObjects()
            }else
            {
                self.myGrouptArrayList.removeAllObjects()
            }
             self.tableView.reloadData()
        }
    }
    
    func sendRequestToAddGroupWebServices(index : Int,password : String)
    {
        let indexData = (allGroupList.object(at: index) as! NSDictionary).mutableCopy() as! NSMutableDictionary
        let parameter = NSMutableDictionary()
        parameter.setValue((indexData.object(forKey: ConstantMessage.kGroupID) as? String)!, forKey: ConstantMessage.kGroupID)
        parameter.setValue(password, forKey: ConstantMessage.kGroupPassword)
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        ServiceUtility.callWebService(REQUEST_TO_JOIN_GROUP, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success && dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
            {
                ServiceUtility.hideProgressHudInView()
                self.isForNewList = true
                indexData.setValue("1", forKey: ConstantMessage.kIsMember)
                self.allGroupList.replaceObject(at: index, with: indexData)
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            }else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
}





