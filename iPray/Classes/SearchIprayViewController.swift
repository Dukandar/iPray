//
//  SearchIprayViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class SearchIprayViewController: UIViewController{
    
    // MARK: - Outlets
    @IBOutlet var prayerView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    var prayerModelView : PrayerListModulerViewController!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPrayerListView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (searchTextField.text!).trimmingCharacters(in: CharacterSet.whitespaces) != ""
        {
            prayerModelView.searchText = (searchTextField.text!).trimmingCharacters(in: CharacterSet.whitespaces)
            prayerModelView.PageNo = 1
            prayerModelView.getprayerListWebService()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addPrayerListView()
    {
        prayerModelView = (self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kPrayerListModulerViewController) as! PrayerListModulerViewController)
        prayerModelView.prayerURL  =  GET_SEARCH_RESULT_URL
        searchView.layer.cornerRadius = 21
        prayerModelView.delegate = self
        prayerModelView.view.frame = CGRect(x: 0, y: 0, width: prayerView.frame.size.width, height: prayerView.frame.size.height)
        prayerView.addSubview(prayerModelView.view)
        self.addChild(prayerModelView)
    }
    
    //MARK: - Button Action
    @IBAction func cancel(_ sender: UIButton) {
        self.view.endEditing(true)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func openAddPrayerView(isupdate : Bool , isreminder : Bool , prayerData : NSDictionary)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kAddPrayerViewController) as! AddPrayerViewController
        vc.deligate = self
        vc.isUpdatePrayer = isupdate
        vc.isOnlyreminder = isreminder
        vc.editedPrayerData = prayerData
        vc.view.frame = self.view.frame
        vc.deligate = self
        
        self.view.bringSubviewToFront(vc.view)
        self.view.addSubview(vc.view)
        self.addChild(vc)
    }
}

//MARK: - TextField Delegate
extension SearchIprayViewController : UITextFieldDelegate
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
        prayerModelView.PageNo = 1
        if text != ""
        {
            prayerModelView.searchText = text.trimmingCharacters(in: CharacterSet.whitespaces)
            prayerModelView.getprayerListWebService()
            
        }else
        {
            prayerModelView.notFoundLable.text = ConstantMessage.kSearchYourPrayersHere
            prayerModelView.searchText = ""
            self.prayerModelView.prayerListDataArray.removeAllObjects()
            prayerModelView.reloadPrayerTableview()
        }
    }
}

extension SearchIprayViewController : refressPrayerList
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

extension SearchIprayViewController : PrayerListModulerDeligate
{
    func openAddprayerPopViewController(prayerData: NSDictionary, isupdate: Bool, isreminder: Bool, isOnlyReminder: Bool)
    {
        self.openAddPrayerView(isupdate: isupdate, isreminder: isreminder, prayerData: prayerData)
    }
    
    func notificaitonCount(notificationCount : Int)
    {}
}




