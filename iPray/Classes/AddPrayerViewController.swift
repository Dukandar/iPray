//
//  AddPrayerViewController.swift
//  iPray
//
//  Created by vivek on 21/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
protocol refressPrayerList {
    func reloadView(ishare:Bool,data : NSDictionary,isTag : Bool,message: String)
}
class AddPrayerViewController: UIViewController, HelpViewDelegate
{
    // MARK: - Outlets
    @IBOutlet weak var saveAndUpdateLable: UILabel!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet var datePikker: UIDatePicker!
    @IBOutlet var pikkerView: UIPickerView!
    @IBOutlet var textViewPlaceholder: UILabel!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var addPrayerView: UIView!
    @IBOutlet weak var prayerTitleView: UIView!
    @IBOutlet weak var prayerTitleTextField: UITextField!
    @IBOutlet weak var prayerView: UIView!
    @IBOutlet weak var writePrayerTextView: UITextView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderImageView: UIImageView!
    @IBOutlet weak var repeatReminderView: UIView!
    @IBOutlet weak var repeatReminderLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var helpBtn: UIButton!
    //NEW CR 18Apri2020
    @IBOutlet weak var prayerImageView: UIImageView!
    @IBOutlet weak var pariseImageView: UIImageView!
    @IBOutlet weak var prayerBtn: UIButton!
    @IBOutlet weak var pariseBtn: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var praise: UILabel!
    @IBOutlet weak var prayer: UILabel!
    var isPraised = false
    // MARK: - Variables
    var  isdropdownMenuOpen = false
    var iscallDeligate = true
    var deligate : refressPrayerList!
    var editedPrayerData = NSDictionary()
    var isUpdatePrayer = false
    var isOnlyreminder = false
    var isTimePickerOpen = false
    var isReminderOn = false
    var intervalReminderSelectedIndex = 0
    var reminderSeletedDate = ""
    var currentDatInString = ""
    var intervalReminderListArray =  [ConstantMessage.kDAILY,ConstantMessage.kWEEKLY, ConstantMessage.kMONTHLY,ConstantMessage.kYEARLY]
    var intervalReminderListArrayNumber =  ["1","2","3","4"]
    var isshare = false
    var isGroupPrayer = false
    var isTag = false
    let kSave = ConstantMessage.kSSave.capitalized
    let kUpdatePrayerReminder = ConstantMessage.kUPDATEYOURPRAYERREMINDER
    let kUpdateReminderBelow = ConstantMessage.kUPDATEYOURREMINDERBELOW
    let kWriteYourPrayerBelow = ConstantMessage.kWRITEYOURPRAYERBELOW
    let kPraiseReminder = ConstantMessage.kPRAISEREMINDER
    let kPrayerReminder = ConstantMessage.kPRAYERREMINDER
    let kPraiseBelow = ConstantMessage.kWRITEYOURPRAISEBELOW
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        textViewPlaceholder.text = ConstantMessage.kDescribe
        addToolBarOnPickerview()
        setCurrentDateTimeOnUI()
        if isUpdatePrayer || isOnlyreminder {
            setUpdatePrayerData()
            saveAndUpdateLable.text = (isOnlyreminder) ? ConstantMessage.kUpdate : (isUpdatePrayer) ? ConstantMessage.kUpdate : self.kSave
            headerLabel.text = (isOnlyreminder) ? self.kUpdatePrayerReminder : (isUpdatePrayer) ? self.kUpdateReminderBelow : self.kWriteYourPrayerBelow
            praise.isHidden = (isOnlyreminder) ? true : false
            pariseImageView.isHidden = (isOnlyreminder) ? true : false
            prayer.isHidden = (isOnlyreminder) ? true : false
            prayerImageView.isHidden = (isOnlyreminder) ? true : false
            if let setAnswered = editedPrayerData.object(forKey: ConstantMessage.kSetAnswered) as? String,setAnswered.count > 0{
                self.prayerBtn.isEnabled = false
                self.pariseBtn.isEnabled = false
                if setAnswered == "1"{
                    prayerImageView.image = UIImage(named: ConstantMessage.kAddUnSelectPrayer)
                    pariseImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
                    headerLabel.text =  self.kUpdateReminderBelow
                    reminderLabel.text = self.kPraiseReminder
                }else{
                    prayerImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
                    pariseImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
                    headerLabel.text =  self.kUpdateReminderBelow
                    reminderLabel.text = self.kPrayerReminder
                }
            }
        }else
        {
            self.reminderOn()
            //NEW CR 18Apri2020
            prayerImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
        }
        if writePrayerTextView.text.count == 0
        {
            textViewPlaceholder.isHidden = false
        }else
        {
            textViewPlaceholder.isHidden = true
        }
        addPrayerView.layer.cornerRadius=10
        prayerTitleView.layer.cornerRadius=21
        prayerView.layer.cornerRadius=10
        repeatReminderView.layer.cornerRadius=3
        repeatReminderView.layer.borderWidth=1
        repeatReminderView.layer.borderColor=UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0).cgColor
        timeView.layer.borderWidth=1
        timeView.layer.cornerRadius=3
        timeView.layer.borderColor=UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1.0).cgColor
        shareView.layer.cornerRadius=21
        saveView.layer.cornerRadius=21
        tagView.layer.cornerRadius=21
        dropDownView.layer.cornerRadius=20
        checkHelpButtonVisibility()
    }
    
    // MARK: - Button Action
    @IBAction func tabButtonPress(_ sender: Any){
        removefromsuperview()
    }
    
    @IBAction func setPrayerReminder(_ sender: UIButton){
        if isReminderOn == false {
            reminderOn()
        }else{
            reminderOff()
        }
    }
    
    @IBAction func repeatReminderBtnClicked(_ sender: UIButton){
        isTimePickerOpen = false
        datePikker.isHidden = true
        pikkerView.isHidden = false
        showDropDown()
        pikkerView.reloadAllComponents()
    }
    
    @IBAction func setTimeBtnCliked(_ sender: UIButton){
        isTimePickerOpen = true
        datePikker.isHidden = false
        pikkerView.isHidden = true
        showDropDown()
        pikkerView.reloadAllComponents()
    }
    
    @IBAction func savePrayerBtnClicked(_ sender: UIButton){
        if isdropdownMenuOpen
        {
            return
        }
        self.saveAndUpdatePrayer(sender: sender)
    }
    
    @IBAction func helpBtnClicked(_ sender: UIButton){
       openHelpPopUp()
    }
    @IBAction func cancel(_ sender: UIButton){
           removefromsuperview()
    }
}

extension AddPrayerViewController{
    func openHelpPopUp(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kHelpViewController) as! HelpViewController
        vc.delegate = self
        vc.isUpdate = isOnlyreminder ? true : isUpdatePrayer ? true : false
        vc.pageType = 1
        self.addChild(vc)
        self.view.addSubview(vc.view)
    }
    func saveAndUpdatePrayer(sender : UIButton){
        if isOnlyreminder {
            self.addPrayerWebService()
            return
        }
        if (prayerTitleTextField.text)?.trimmingCharacters(in: CharacterSet.whitespaces)=="" {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.PrayerTitle,delay: ConstantMessage.kDelay)
            return
        }
        else{
            
            if sender.tag == 2
            {
                self.isshare = true
                self.isTag = false
            }
            if sender.tag == 3
            {
                self.isshare = false
                self.isTag = true
            }else if sender.tag == 1{
                self.isshare = false
                self.isTag = false
            }
            addPrayerWebService()
        }
    }
    
    func setUpdatePrayerData(){
        // set for reminder only
        if isOnlyreminder {
            prayerTitleTextField.isUserInteractionEnabled = false
            writePrayerTextView.isUserInteractionEnabled = false
            shareView.isHidden = true
            tagView.isHidden = true
        }
        if editedPrayerData.object(forKey: ConstantMessage.kCopiedPrayer) != nil && editedPrayerData.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1" {
            self.isGroupPrayer = true
        }else{
            self.isGroupPrayer = false
        }
        prayerTitleTextField.text = editedPrayerData.object(forKey: ConstantMessage.kTitle) as! String?
        writePrayerTextView.text = (editedPrayerData.object(forKey: ConstantMessage.kDescription) as! String)
        if editedPrayerData.object(forKey: ConstantMessage.kIsReminderSet) as! String == "1"
        {
            self.reminderOn()
            let reminderInterval : String = editedPrayerData.object(forKey: ConstantMessage.kReminderType) as! String
            // find reminder index
            for i in 0..<intervalReminderListArray.count {
                if intervalReminderListArrayNumber[i] == reminderInterval {
                    intervalReminderSelectedIndex = i
                    break
                }
            }
            let f:DateFormatter = DateFormatter()
            f.dateFormat = ConstantMessage.kDateForamte
            let tempTimeDate = f.date(from: editedPrayerData.object(forKey: ConstantMessage.kReminderTime) as! String)! as NSDate
            let localtime = supportingfuction.ChangeGmtTimeIntoLocal(date: tempTimeDate)
            f.dateFormat = ConstantMessage.kDateForamte1
            reminderSeletedDate = f.string(from: localtime as Date)
            setreminders()
        }
    }
    func showDropDown(){
        isdropdownMenuOpen = true
        dropDownView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: dropDownView.frame.size.width, height: dropDownView.frame.size.height)
        UIView.animate(withDuration: 0.60, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.dropDownView.frame = CGRect(x: 0, y: self.view.frame.size.height - self.dropDownView.frame.size.height , width: self.dropDownView.frame.size.width, height: self.dropDownView.frame.size.height)
        }) { (flag :Bool) in
            self.dropDownView.frame = CGRect(x: 0, y: self.view.frame.size.height - self.dropDownView.frame.size.height , width: self.dropDownView.frame.size.width, height: self.dropDownView.frame.size.height)
        }
    }
    @objc func donePickerBtnClk(){
        if isTimePickerOpen {
            let selecteddate = datePikker.date
            let f:DateFormatter = DateFormatter()
            f.dateFormat = ConstantMessage.kDateForamte
            let newdateStrig = f.string(from: selecteddate)
            let newdateDate = f.date(from: newdateStrig)
            f.dateFormat = ConstantMessage.kDateForamte1
            let finaldate = f.string(from: newdateDate!)
            reminderSeletedDate = finaldate
        }else{
            intervalReminderSelectedIndex = pikkerView.selectedRow(inComponent: 0)
        }
        setreminders()
        closePikkerView()
    }
    @objc func closePikkerView(){
        isdropdownMenuOpen = false
        dropDownView.frame = CGRect(x: 0, y: self.view.frame.size.height - dropDownView.frame.size.height, width: dropDownView.frame.size.width, height: dropDownView.frame.size.height)
        UIView.animate(withDuration: 0.60, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.dropDownView.frame = CGRect(x: 0, y: self.view.frame.size.height , width: self.dropDownView.frame.size.width, height: self.dropDownView.frame.size.height)
        }) { (flag :Bool) in
            self.dropDownView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.dropDownView.frame.size.width, height: self.dropDownView.frame.size.height)
        }
    }
    func addToolBarOnPickerview(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor .black
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: ConstantMessage.kDone, style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddPrayerViewController.donePickerBtnClk))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: ConstantMessage.kCancel, style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddPrayerViewController.closePikkerView))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        dropDownView.addSubview(toolBar)
    }
}

// MARK: - TextField Delegate
extension AddPrayerViewController : UITextFieldDelegate , UITextViewDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if (textField.text?.count)! > 100 && string != ""
        {
            return false
        }
        if UIPasteboard.general.string != nil && (((UIPasteboard.general.string)?.count)! > 30) && string == (UIPasteboard.general.string)
        {
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        if textView.text.count < 2 && text == "" {
            textViewPlaceholder.isHidden = false
        }
        if textView.text.isEmpty && text != ""
        {
            textViewPlaceholder.isHidden = true
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        if textView.text.isEmpty {
            textViewPlaceholder.isHidden = false
        }else
        {
            textViewPlaceholder.isHidden = true
        }
    }
}

// MARK: - PickerView Delegate
extension AddPrayerViewController : UIPickerViewDelegate,UIPickerViewDataSource
{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return intervalReminderListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        self.view.endEditing(true)
        return intervalReminderListArray[row]
    }
}

// MARK: - Web Service
extension AddPrayerViewController
{
    func answerPrayerWebServices(dataFromServer : NSDictionary){
        let tempdata = dataFromServer.object(forKey: ConstantMessage.kData) as! NSDictionary
        var status = "0"
        if tempdata[ConstantMessage.kSetAnswered] as! String == "0"
        {
            status = "1"
        }
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        perameter.setValue(tempdata[ConstantMessage.kPrayerID] as! String, forKey: ConstantMessage.kPrayerID)
        perameter.setValue(status, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebService(ANSWER_PRAYER_URL, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer1) in
            if success {
                if dataFromServer1.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                    {
                        self.view.isHidden = true
                        if self.isGroupPrayer {
                            self.deligate.reloadView(ishare: false,data: NSDictionary(), isTag: false,message: (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString) as String)
                        }else{
                            if self.deligate != nil
                            {
                                self.deligate.reloadView(ishare: self.isshare,data: dataFromServer.object(forKey: ConstantMessage.kData) as! NSDictionary, isTag: self.isTag,message: (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString) as String)
                            }
                        }
                    }
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
    func addPrayerWebService(){
        let perameter = NSMutableDictionary()
        var isreminder = 0
        var interval = ""
        var time = ""
        if isReminderOn
        {
            isreminder = 1
            interval =   intervalReminderListArrayNumber[intervalReminderSelectedIndex]
            let f:DateFormatter = DateFormatter()
            f.dateFormat = ConstantMessage.kDateForamte
            let tempTime = f.string(from: self.datePikker.date as Date)
            let tempTimeDate = f.date(from: tempTime)! as NSDate
            let gmttime = supportingfuction.ChangeLocalTimeIntoGmt(date: tempTimeDate)
            time = f.string(from: gmttime as Date)
        }
        perameter.setValue(isreminder, forKey: ConstantMessage.kReminder)
        perameter.setValue(interval, forKey: ConstantMessage.kReminderType)
        perameter.setValue(time, forKey: ConstantMessage.kReminderTime)
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        var url : String = ADD_NEW_PRAYER_URL
        if isOnlyreminder {
            if isGroupPrayer {
                url = UPDATE_COPYIED_PRAYER_REMINDER
                perameter.setValue(editedPrayerData.object(forKey: ConstantMessage.kPrayerID), forKey: ConstantMessage.kPrayerID)
            }else{
                url = UPDATE_PRAYER_REMINDER
                perameter.setValue(editedPrayerData.object(forKey: ConstantMessage.kPrayerID), forKey: ConstantMessage.kPrayerID)
            }
        }else
        {
            perameter.setValue(prayerTitleTextField.text, forKey: ConstantMessage.kPrayerTitle)
            perameter.setValue(writePrayerTextView.text, forKey: ConstantMessage.kPrayerDescription)
            if isUpdatePrayer
            {
                perameter.setValue(editedPrayerData.object(forKey: ConstantMessage.kPrayerID), forKey: ConstantMessage.kPrayerID)
                url = UPDATE_PRAYER
                perameter.setValue(self.isPraised ? 1 : "0", forKey:  ConstantMessage.kStatus)
            }
        }
        ServiceUtility.callWebService(url, parameters: perameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if self.isPraised && !self.isUpdatePrayer{
                    self.answerPrayerWebServices(dataFromServer: dataFromServer)
                }else{
                    if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                    {
//                        self.removefromsuperview()
                        self.view.isHidden = true
                        if self.isGroupPrayer {
                            self.deligate.reloadView(ishare: false,data: NSDictionary(), isTag: false,message: (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString) as String)
                        }else{
                            if self.deligate != nil
                            {
                                self.deligate.reloadView(ishare: self.isshare,data: dataFromServer.object(forKey: ConstantMessage.kData) as! NSDictionary, isTag: self.isTag,message: (dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString) as String)
                            }
                        }
                    }else
                    {
                        ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                    }
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay: ConstantMessage.kDelay)
            }
        }
    }
}

// MARK: - TagPrayerPopUpDelegate
extension BubblesViewController : refressPrayerList ,TagPrayerPopUpDelegate,UtilityProtocol
{
    func reloadView(ishare: Bool, data: NSDictionary, isTag: Bool,message : String){
        newNotificationCome = true
        if ishare
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagPrayerPopUpViewController) as! TagPrayerPopUpViewController
            vc.delegate = self
            vc.dataDict = data
            
            vc.type = ConstantMessage.kshare
            vc.isTag = false
            
            vc.view.frame = self.view.frame
            self.view.bringSubviewToFront(vc.view)
            self.addChild(vc)
            self.view.addSubview(vc.view)
            
            
        }else if isTag {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kTagPrayerPopUpViewController) as! TagPrayerPopUpViewController
            vc.delegate = self
            vc.dataDict = data
            vc.isTag = true
            vc.type = ConstantMessage.ktag
            self.addChild(vc)
            self.view.addSubview(vc.view)
        }else
        {
            if(Utility.shareUtility.getPrayerUserDefaults()){
                ServiceUtility.showMessageHudWithMessage(message as NSString, delay: ConstantMessage.kDelay)
            }else{
                Utility.shareUtility.showPopUpWith(title: message, desc:ConstantMessage.kOpenPrayers, buttonName: ConstantMessage.ksubmit, view: self.view,delegate:self)
            }
            self.getBubblesList()
        }
    }
    
    func submitBtnActionWith(isChecked : Bool){
        let subViews = self.view.subviews
        subViews.last?.removeFromSuperview()
        Utility.shareUtility.serPrayerUserUserDefaults(isChecked: isChecked)
    }
       
    func cancel(){
        let subViews = self.view.subviews
        subViews.last?.removeFromSuperview()
    }
    func tagPopUpBtnClicked(actionType: Int, data: NSDictionary,isTagging : Bool) {
        if actionType == 1 {
            self.sharewithContact(prayerData : data, isIprayContact: true, isTag: true)
        }else if actionType == 2 {
            self.sharewithContact(prayerData : data, isIprayContact: false, isTag: true)
        }else if actionType == 1000 {
            
            if (self.navigationController?.viewControllers.count)! > 0{
                let viewControllers = self.navigationController?.viewControllers
                for item in viewControllers![0].children{
                    if item is AddPrayerViewController{
                        let VCTR = item as!AddPrayerViewController
                        VCTR.view.isHidden = false
                    }
                }
            }
    
        }else{
            let newdata : NSMutableDictionary = data.mutableCopy() as! NSMutableDictionary
            if newdata.count > 0{
                newdata.setValue(data.object(forKey: ConstantMessage.kTitle) as! String, forKey: ConstantMessage.kGroupName)
                ApplicationDelegate.shareLinkBeyondTheApp(groupData :newdata, isPrayerTitle: true, isTag: isTagging)
            }
        }
    }
    func sharewithContact(prayerData : NSDictionary,isIprayContact:Bool, isTag:Bool) {
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

//NEW CR 18Apri2020
extension AddPrayerViewController{
    @IBAction func prayerBtnTapped(_ sender : UIButton){
        prayerImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
        pariseImageView.image = UIImage(named: ConstantMessage.kAddUnSelectPrayer)
        headerLabel.text =  (isOnlyreminder) ? self.kUpdatePrayerReminder : (isUpdatePrayer) ? self.kUpdateReminderBelow : self.kWriteYourPrayerBelow
        reminderLabel.text = self.kPrayerReminder
        self.isPraised = false
    }
    @IBAction func pariseBtnTapped(_ sender : UIButton){
       prayerImageView.image = UIImage(named: ConstantMessage.kAddUnSelectPrayer)
       pariseImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
        headerLabel.text = (isOnlyreminder) ? self.kUpdatePrayerReminder : (isUpdatePrayer) ? self.kUpdateReminderBelow : self.kPraiseBelow
        reminderLabel.text = self.kPraiseReminder
       self.isPraised = true
    }
}

extension AddPrayerViewController{
    func removefromsuperview(){
        self.view.removeFromSuperview()
        self.removeFromParent()
        isReminderOn = false
    }
    func isHelpButtonShow(){
        checkHelpButtonVisibility()
    }
    //TODO: Need to check in future
    func checkHelpButtonVisibility(){
        if UserDefaults.standard.object(forKey: ConstantMessage.kIsShowHelp) != nil && UserDefaults.standard.object(forKey: ConstantMessage.kIsShowHelp) as! Bool == false {
           //helpBtn.isHidden = true
       }else{
           //helpBtn.isHidden = false
       }
    }
    func setCurrentDateTimeOnUI(){
       let selecteddate = NSDate()
       let f:DateFormatter = DateFormatter()
        f.dateFormat = ConstantMessage.kDateForamte
       let newdateStrig = f.string(from: selecteddate as Date)
       let newdateDate = f.date(from: newdateStrig)
        f.dateFormat = ConstantMessage.kDateForamte1
       
       currentDatInString = f.string(from: newdateDate!)
       reminderSeletedDate = currentDatInString
       self.timeLabel.text = reminderSeletedDate
    }
}

extension AddPrayerViewController{
    func reminderOn(){
        self.setCurrentDateTimeOnUI()
        reminderView.isHidden=false
        reminderImageView.image = #imageLiteral(resourceName: "addPrayer_select_radio_button_Image")
        isReminderOn = true
    }
    func reminderOff(){
        reminderView.isHidden=true
        reminderImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
        isReminderOn = false
        intervalReminderSelectedIndex = 0
        reminderSeletedDate = currentDatInString
        setreminders()
    }
    func setreminders(){
        self.repeatReminderLabel.text = intervalReminderListArray[intervalReminderSelectedIndex]
        self.timeLabel.text = reminderSeletedDate
    }
}
