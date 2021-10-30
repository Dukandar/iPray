//
//  DonationViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

class DonationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var pikkerview: UIPickerView!
    @IBOutlet var pikkerUIview: UIView!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var categorytextview: UITextField!
    @IBOutlet var planview: UIView!
    @IBOutlet var plantextview: UITextField!
    @IBOutlet var paymentBgview: UIView!
    
    // MARK: - Variables
    var isPlanPickkerViewOpen : Bool!
    var categoryListArray = NSMutableArray()
    var planArrayList = NSMutableArray()
    var planAmoutList = NSMutableArray()
    var isdropdownMenuOpen = false
    var defaulCategoryIndex = 0
    var defaultplanindex = 1
    var ServerList = NSMutableArray()
    var selectedCategoryIndex = -1
    var selectedPlanIndex = -1
    var paymentAmount : Decimal = 1.0
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        isPlanPickkerViewOpen = false
        categoryView.layer.cornerRadius = 20.0
        planview.layer.cornerRadius = 20.0
        paymentBgview.layer.cornerRadius = 20.0
        addToolBarOnPickerview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button Action
    @IBAction func categorySelection(_ sender: Any) {
        isPlanPickkerViewOpen = false
        pikkerview.reloadAllComponents()
        showDropDown()
    }
    
    @IBAction func planSelection(_ sender: Any) {
        if !(selectedCategoryIndex == -1)
        {
            isPlanPickkerViewOpen = true
            planArrayList = ((ServerList.object(at: selectedCategoryIndex) as! NSDictionary).object(forKey: ConstantMessage.kTextList) as! NSArray).mutableCopy() as! NSMutableArray
            planAmoutList = ((ServerList.object(at: selectedCategoryIndex) as! NSDictionary).object(forKey: ConstantMessage.kPriceList) as! NSArray).mutableCopy() as! NSMutableArray
            pikkerview.reloadAllComponents()
            showDropDown()
        }
    }
    
    @IBAction func cancleBtnCliked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playmentBtnCliked(_ sender: UIButton)
    {
        if selectedCategoryIndex != -1 &&  selectedPlanIndex != -1 && !isdropdownMenuOpen
        {
            let  priceString : String = (planAmoutList[selectedPlanIndex] as! String)
            let preiceDecimal : Decimal = Decimal(Double(priceString)!)
            paymentAmount = preiceDecimal
        }
    }
    
    func setDonationListOnline(serverList : NSArray)
    {
        ServerList.removeAllObjects()
        categoryListArray.removeAllObjects()
        planArrayList.removeAllObjects()
        planAmoutList.removeAllObjects()
        ServerList = serverList.mutableCopy() as! NSMutableArray
        for item in serverList
        {
            categoryListArray.add((item as! NSDictionary).object(forKey: ConstantMessage.kName) as! String)
        }
        selectedCategoryIndex = defaulCategoryIndex
        selectedPlanIndex = defaultplanindex
        planAmoutList = ((ServerList.object(at: selectedCategoryIndex) as! NSDictionary).object(forKey: ConstantMessage.kPriceList) as! NSArray).mutableCopy() as! NSMutableArray
        planArrayList = ((ServerList.object(at: selectedCategoryIndex) as! NSDictionary).object(forKey: ConstantMessage.kTextList) as! NSArray).mutableCopy() as! NSMutableArray
        categorytextview.text = categoryListArray[selectedCategoryIndex] as? String
        plantextview.text = planArrayList[selectedPlanIndex] as? String
        pikkerview.reloadAllComponents()
    }
}

// MARK: - PickerView Delegate
extension DonationViewController : UIPickerViewDelegate,UIPickerViewDataSource
{
    
    func showDropDown(){
        isdropdownMenuOpen = true
        pikkerUIview.frame = CGRect(x: 0, y: self.view.frame.size.height, width: pikkerUIview.frame.size.width, height: pikkerUIview.frame.size.height)
        UIView.animate(withDuration: 0.60, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.pikkerUIview.frame = CGRect(x: 0, y: self.view.frame.size.height - self.pikkerUIview.frame.size.height , width: self.pikkerUIview.frame.size.width, height: self.pikkerUIview.frame.size.height)
        }) { (flag :Bool) in
            self.pikkerUIview.frame = CGRect(x: 0, y: self.view.frame.size.height - self.pikkerUIview.frame.size.height , width: self.pikkerUIview.frame.size.width, height: self.pikkerUIview.frame.size.height)
        }
    }
    
    /**
     *  Function to select data from UIPickerView
     */
    
    @objc func donePickerBtnClk() {
        if isPlanPickkerViewOpen == false{
            
            selectedCategoryIndex = pikkerview.selectedRow(inComponent: 0)
            categorytextview.text = categoryListArray[selectedCategoryIndex] as? String
            
        }else{
            
            selectedPlanIndex = pikkerview.selectedRow(inComponent: 0)
            plantextview.text = planArrayList[selectedPlanIndex] as? String
            
            
        }
        
        closePikkerView()
    }
    
    /**
     *  Function to close UIPickerView
     */
    
    @objc func closePikkerView()
    {
        isdropdownMenuOpen = false
        pikkerUIview.frame = CGRect(x: 0, y: self.view.frame.size.height - pikkerUIview.frame.size.height, width: pikkerUIview.frame.size.width, height: pikkerUIview.frame.size.height)
        UIView.animate(withDuration: 0.60, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.pikkerUIview.frame = CGRect(x: 0, y: self.view.frame.size.height , width: self.pikkerUIview.frame.size.width, height: self.pikkerUIview.frame.size.height)
        }) { (flag :Bool) in
            self.pikkerUIview.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.pikkerUIview.frame.size.width, height: self.pikkerUIview.frame.size.height)
        }
        
    }
    
    /**
     *  Function to add toolBar within UIPickerView
     */
    
    func addToolBarOnPickerview(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor .black
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: ConstantMessage.kDone, style: UIBarButtonItem.Style.plain, target: self, action: #selector(DonationViewController.donePickerBtnClk))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: ConstantMessage.kCancel, style: UIBarButtonItem.Style.plain, target: self, action: #selector(DonationViewController.closePikkerView))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        pikkerUIview.addSubview(toolBar)
    }
    
    /**
     *  Function to set number of components in UIPickerView
     */
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    /**
     *  Function to set number of rows with in UIPickerView
     */
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        if isPlanPickkerViewOpen == false
        {
            return   categoryListArray.count
            
        }else
        {
            return   planArrayList.count
            
        }
    }
    
    /**
     *  Function to set data in UIPIckerView
     */
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        if isPlanPickkerViewOpen == false
        {
            return   categoryListArray[row] as? String
        }else
        {
            return  planArrayList[row] as? String
        }
    }
}




