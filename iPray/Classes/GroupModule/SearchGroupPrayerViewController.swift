//
//  SearchGroupPrayerViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class SearchGroupPrayerViewController: UIViewController{
    
    // MARK: - Outlets
    @IBOutlet var prayerView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var header: UILabel!
    
    // MARK: - Variables
    var isGroupAdmin = false
    var isPrayerWall = true
    var prayerGroupModelView : GroupListModulerViewController!
    var groupDiscription : NSDictionary!
    let kSearchPrayer = ConstantMessage.kSearchPrayerRequests
    let kSearchGroup = ConstantMessage.kSearchGroupPrayers
    let kSearchYourPrayers = ConstantMessage.kSearchYourPrayersHere
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPrayerModuleListView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (searchTextField.text!).trimmingCharacters(in: CharacterSet.whitespaces) != ""
        {
            prayerGroupModelView.searchText = (searchTextField.text!).trimmingCharacters(in: CharacterSet.whitespaces)
            prayerGroupModelView.PageNo = 1
            prayerGroupModelView.getprayerListWebService()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addPrayerModuleListView()    {
        prayerGroupModelView = (self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kGroupListModulerViewController) as! GroupListModulerViewController)
        prayerGroupModelView.isSearch  = true
        if isPrayerWall
        {
            prayerGroupModelView.prayerURL  =  GET_GROUP_WALL_LIST_URL
            //header.text = "Search for Prayer Wall"
            header.text = self.kSearchPrayer
        }else
        {
            prayerGroupModelView.prayerURL  =  GET_GROUP_BOOK_LIST_URL
            //header.text = "Search for Prayer Book"
            header.text = self.kSearchGroup
        }
        prayerGroupModelView.isPrayerWall =  isPrayerWall
        prayerGroupModelView.isGroupAdmin = isGroupAdmin
        prayerGroupModelView.delegate = self
        if groupDiscription.object(forKey: ConstantMessage.kGroupID) != nil
        {
            prayerGroupModelView.groupId = (groupDiscription.object(forKey: ConstantMessage.kGroupID) as? String)!
        }else
        {
            prayerGroupModelView.groupId = (groupDiscription.object(forKey: ConstantMessage.kId) as? String)!
            
        }
        prayerGroupModelView.view.frame = CGRect(x: 0, y: 0, width: prayerView.frame.size.width, height: prayerView.frame.size.height)
        prayerView.addSubview(prayerGroupModelView.view)
        self.addChild(prayerGroupModelView)
        
    }
    
    // MARK: - Button Action
    @IBAction func cancel(_ sender: UIButton) {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func openAddPrayerView(isupdate : Bool , isreminder : Bool , prayerData : NSDictionary)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddGroupPrayerViewController) as! AddGroupPrayerViewController
        vc.delegate = self
        vc.isUpdate = isupdate
        vc.updatePrayerData = prayerData
        vc.view.frame = self.view.frame
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
}

// MARK: - TextField Delegate
extension SearchGroupPrayerViewController : UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var tempstring : String = textField.text!
        if string != "" && tempstring.count > 25
        {
            return false
        }
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
    
    func searchFunction(text : String)
    {
        prayerGroupModelView.PageNo = 1
        if text != ""
        {
            prayerGroupModelView.searchText = text.trimmingCharacters(in: CharacterSet.whitespaces)
            prayerGroupModelView.getprayerListWebService()
        }else
        {
            prayerGroupModelView.notFoundLable.text = self.kSearchYourPrayers
            prayerGroupModelView.searchText = ""
            self.prayerGroupModelView.groupPrayerListDataArray.removeAllObjects()
            prayerGroupModelView.reloadPrayerTableview()
        }
    }
}

// MARK: - Group Prayer Delegate
extension SearchGroupPrayerViewController :AddGroupPrayerDelegate , GroupPrayerListModulerDelegate
{
    // Add Group Prayer Delegate
    func newGroupPrayerAdded()
    {
        prayerGroupModelView.reloadPrayerTableview()
    }
    
    func shareLink(data : NSDictionary)
    {
        let newdata : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
        if newdata.count > 0{
            newdata.setValue(groupDiscription.object(forKey: ConstantMessage.kGroupName) as! String, forKey: ConstantMessage.kGroupName)
            ApplicationDelegate.shareLinkBeyondTheApp(groupData: newdata, isPrayerTitle: true, isTag: false)
        }
    }
    
    //GroupPrayerListModulerDelegate : Update prayer
    func updateGroupPrayer(prayerData : NSDictionary)
    {
        self.openAddPrayerView(prayerData: prayerData, isupdate: true)
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
 

