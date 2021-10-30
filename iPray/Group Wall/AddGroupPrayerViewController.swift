//
//  AddGroupPrayerViewController.swift
//  iPray
//
//  Created by Sunil on 21/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking
import SafariServices
protocol AddGroupPrayerDelegate {
    func newGroupPrayerAdded()
}
class AddGroupPrayerViewController: UIViewController
{
    // MARK: - Outlets
    @IBOutlet var headerText: UILabel!
    @IBOutlet weak var prayerTitleTextField: UITextField!
    @IBOutlet weak var writePrayerTextView: UITextView!
    @IBOutlet var textViewPlaceholder: UILabel!
    
    // Reminder Layer
    @IBOutlet weak var isreminderOnImageView: UIImageView!
    @IBOutlet weak var repeatReminderLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var showReminderView: UIView!
    @IBOutlet var hideReminderConsraint: NSLayoutConstraint! // 73 40
    
   // shareableview
    @IBOutlet var isrShreablerOnImageView: UIImageView!
    @IBOutlet var shareableTextLable: UILabel!
    
    // publish
    @IBOutlet var isPublishOnImageView: UIImageView!
    @IBOutlet var publishDateLable: UILabel!
    @IBOutlet var imaginerTextField: UITextField!
    @IBOutlet var publishLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var publishLaterDateView: UIView!
    @IBOutlet var publishBgView: UIView!
    @IBOutlet var submitLable: UILabel!
    @IBOutlet var groupRulefotterview: UIView!
    @IBOutlet var fotterViewContraint: NSLayoutConstraint!
    
    //Admin Anonymous
    @IBOutlet weak var adminAnonymousView: UIView!
    @IBOutlet weak var isadminAnonymousOnImageView: UIImageView!
    
    //NEW CR 18May2020
    @IBOutlet weak var prayerImageView: UIImageView!
    @IBOutlet weak var pariseImageView: UIImageView!
    @IBOutlet weak var prayerBtn: UIButton!
    @IBOutlet weak var pariseBtn: UIButton!
    @IBOutlet weak var groupReminder : UILabel!
    @IBOutlet weak var prayerAnonymous : UILabel!
    @IBOutlet weak var shareView : UIView!
    var isPrayer = false
    var isPraise = false
    
    
    // MARK: - Variables
    var isReminderOn = true
    var pickerOpenType = 0  // 1 : Date time , 2 : Date , 3 : List
    var datePikker : UIDatePicker!
    var pickerView : UIPickerView!
    var delegate : AddGroupPrayerDelegate!
    var reminderSeletedTime = ""
    var currentDatInString = ""
    var intervalReminderSelectedIndex = 0
    var intervalReminderListArray =  ["DAILY","WEEKLY", "MONTHLY","YEARLY"]
    var intervalReminderListArrayNumber =  ["1","2","3","4"]
    var isshareOn = true
    var isCopy = false
    var ispublishOn = true
    var isAdminAnonymousOn = false
    var publishDateTime = ""
    var isMyGroupPrayer = true
    var groupId : String!
    var isUpdate = false
    var updatePrayerData : NSDictionary!
    var isWall = true
    let kCreateAPrayer = ConstantMessage.kCREATEAPRAYER
    let kAddGroupPrayer = ConstantMessage.kADDGROUPPRAYER
    let kUpdateGropuPrayer = ConstantMessage.kUPDATEGROUPPRAYER
    let kGroupPraiseReminder = ConstantMessage.kGROUPPRAISEREMINDER
    let kPraiseAnonymous = ConstantMessage.kMAKEMYPRAISEANONYMOUS
    
    
    // MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        textViewPlaceholder.text = ConstantMessage.kDescribe
        setCurrentDateTimeOnUi()
        setToolBar()
        if !isMyGroupPrayer
        {
            shareView.isHidden = true
            headerText.text = ConstantMessage.kPrayerRequest
            shareableTextLable.text = ConstantMessage.kPrayerAnonymous
            publishLayoutConstraint.constant = 0.0
            publishBgView.isHidden = true
            submitLable.text = ConstantMessage.kPrayerRequest
            groupRulefotterview.isHidden = false
            fotterViewContraint.constant = 30
            isshareOn = false
            adminAnonymousView.isHidden = true
            isrShreablerOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
        } else if isMyGroupPrayer && isWall{
            shareView.isHidden = true
            
            headerText.text = ConstantMessage.kSubmitPrayerRequest
            shareableTextLable.text = ConstantMessage.kPrayerAnonymous
            publishLayoutConstraint.constant = 0.0
            publishBgView.isHidden = true
            submitLable.text = ConstantMessage.kSubmitPrayerRequest
            groupRulefotterview.isHidden = false
            fotterViewContraint.constant = 30
            isshareOn = false
            adminAnonymousView.isHidden = true
            isrShreablerOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
            
        }else if isMyGroupPrayer && isWall {
//            headerText.text = "POST PRAYER"
            headerText.text = self.kCreateAPrayer
            adminAnonymousView.isHidden = false
            isadminAnonymousOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
        }else{
            headerText.text = self.kAddGroupPrayer
        }
        if isUpdate
        {
            setUpdatePrayerData()
        }
        
        //NEW CR 18MAY2020
        prayerImageView.image = UIImage(named: ConstantMessage.kAddPrayerBtnImage)
        pariseImageView.image = UIImage(named: ConstantMessage.kAddUnSelectPrayer)
        groupReminder.text = ConstantMessage.kGroupPrayerReminder
        prayerAnonymous.text = ConstantMessage.kPrayerAnonymous
        self.isPrayer = true
        self.isPraise = false
        if self.isUpdate{
            self.headerText.text = self.kUpdateGropuPrayer
            self.submitLable.text = ConstantMessage.kUpdate
        }
    }
    
    func setUpdatePrayerData()
    {
        prayerTitleTextField.text = updatePrayerData.object(forKey: ConstantMessage.kGroupPrayerTitle) as? String
        writePrayerTextView.text = updatePrayerData.object(forKey: ConstantMessage.kGroupPrayerDescription) as? String
        if updatePrayerData.object(forKey: ConstantMessage.kGroupPrayerDescription) as? String != ""
        {
            textViewPlaceholder.isHidden = true
        }
        if updatePrayerData.object(forKey: ConstantMessage.kIsReminderSet) as? String == "1"
        {
            self.reminderOn()
            let reminderInterval : String = updatePrayerData.object(forKey: ConstantMessage.kReminderType) as! String
            // find reminder index
            for i in 0..<intervalReminderListArray.count {
                if intervalReminderListArrayNumber[i] == reminderInterval {
                    intervalReminderSelectedIndex = i
                    break
                }
            }
            let f:DateFormatter = DateFormatter()
            f.dateFormat = ConstantMessage.kDateForamte
            let tempTimeDate = f.date(from: updatePrayerData.object(forKey: ConstantMessage.kReminderTime) as! String)! as NSDate
            let localtime = supportingfuction.ChangeGmtTimeIntoLocal(date: tempTimeDate)
            f.dateFormat = ConstantMessage.kDateForamte1
            reminderSeletedTime = f.string(from: localtime as Date)
            setreminders()
        }
        if updatePrayerData.object(forKey: ConstantMessage.kIsShareble) as? String == "1"
        {
            isshareOn = true
        }else
        {
             isshareOn = false
        }
        if updatePrayerData.object(forKey: ConstantMessage.kIsPublished) != nil && updatePrayerData.object(forKey: ConstantMessage.kIsPublished) as? String == "1"
        {
            ispublishOn = true
        }else
        {
            ispublishOn = false
        }
    }
    
    // MARK: - Button Action
    @IBAction func reminderOnOffButtonPress(_ sender: UIButton)
    {
        if isReminderOn == false {
            reminderOn()
        }else{
            reminderOff()
        }
    }
    
    @IBAction func repeatReminderBtnClicked(_ sender: UIButton)
    {
        pickerOpenType = 3
        setPikkerForTextFiled()
    }
    
    @IBAction func setTimeBtnCliked(_ sender: UIButton)
    {
        pickerOpenType = 2
        setPikkerForTextFiled()
    }
    
    @IBAction func shareOnOffButtonPress(_ sender: Any) {
        if isshareOn {
            isshareOn = false
            isCopy = false
            isrShreablerOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
        }else{
            isrShreablerOnImageView.image = #imageLiteral(resourceName: "addPrayer_select_radio_button_Image")
            isshareOn = true
        }
    }
    
    @IBAction func adminAnonymousOnOffButtonPress(_ sender: Any) {
        if isAdminAnonymousOn {
            isAdminAnonymousOn = false
            isadminAnonymousOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
        }else{
            isadminAnonymousOnImageView.image = #imageLiteral(resourceName: "addPrayer_select_radio_button_Image")
            isAdminAnonymousOn = true
        }
    }
    
    @IBAction func publishOnOffButtonPress(_ sender: Any) {
        if ispublishOn{
            ispublishOn = false
            publishLaterDateView.isHidden = false
            isPublishOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
            publishDateTime = currentDatInString
            publishDateLable.text = currentDatInString
        }else{
            ispublishOn = true
            publishLaterDateView.isHidden = true
            isPublishOnImageView.image = #imageLiteral(resourceName: "addPrayer_select_radio_button_Image")
        }
    }
    
    @IBAction func publishTimeButtonPress(_ sender: UIButton) {
         pickerOpenType =  1
         setPikkerForTextFiled()
    }

    @IBAction func publishButtonPress(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if pickerOpenType != 0
        {
            return
        }
        if (prayerTitleTextField.text)?.trimmingCharacters(in: CharacterSet.whitespaces)=="" {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.PrayerTitle,delay: ConstantMessage.kDelay)
            return
        }
        else{
            addPrayerWebService()
        }
    }
    
    @IBAction func cancel(_ sender: UIButton)
    {
        removefromsuperview()
    }
    
    @IBAction func tabButtonPress(_ sender: Any)
    {
        removefromsuperview()
    }
    
    @IBAction func groupRuleButtonPress(_ sender: Any) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: URL(string: iPrayConsant.kiPrayHome)!, configuration: config)
        present(vc, animated: true)
    }
    
    func removefromsuperview()
    {
        self.view.removeFromSuperview()
        self.removeFromParent()
        isReminderOn = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Web Service
extension AddGroupPrayerViewController
{
    func addPrayerWebService()
    {
        let f:DateFormatter = DateFormatter()
        f.dateFormat = ConstantMessage.kDateForamte1
        if reminderSeletedTime != ""
        {
            let tempTimeDate = f.date(from: reminderSeletedTime)! as NSDate
            let gmttime = supportingfuction.ChangeLocalTimeIntoGmt(date: tempTimeDate)
            reminderSeletedTime = f.string(from: gmttime as Date)
        }
        if publishDateTime != ""
        {
            let tempTimeDate = f.date(from: publishDateTime)! as NSDate
            let gmttime = supportingfuction.ChangeLocalTimeIntoGmt(date: tempTimeDate)
            publishDateTime = f.string(from: gmttime as Date)
        }
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(self.groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue(prayerTitleTextField.text, forKey: ConstantMessage.kPrayerTitle)
        parameter.setValue(writePrayerTextView.text, forKey: ConstantMessage.kPrayerDescription)
        parameter.setValue(isReminderOn, forKey: ConstantMessage.kReminder)
        parameter.setValue(intervalReminderListArray[intervalReminderSelectedIndex], forKey: ConstantMessage.kReminderType)
        parameter.setValue(reminderSeletedTime, forKey: ConstantMessage.kReminderTime)
        parameter.setValue(ispublishOn, forKey: ConstantMessage.kPublishNow)
        parameter.setValue(publishDateTime, forKey: ConstantMessage.kPublishTime)
        parameter.setValue(isshareOn, forKey: ConstantMessage.kShareable)
        parameter.setValue(isCopy, forKey: ConstantMessage.kisCopy)
        if isMyGroupPrayer{
            parameter.setValue(isAdminAnonymousOn, forKey: ConstantMessage.kIsAnonymous)
        }else{
            parameter.setValue(isshareOn, forKey: ConstantMessage.kIsAnonymous)
        }
        if isWall
        {
            parameter.setValue(isWall, forKey: ConstantMessage.kIsWall)
        }else
        {
             parameter.setValue("2", forKey: ConstantMessage.kIsWall)
        }
        var URL = ADD_GROUP_URL
        if isUpdate
        {
            URL = UPDATE_GROUP_URL
            parameter.setValue(updatePrayerData.object(forKey: ConstantMessage.kGroupPrayerID) as! String, forKey: ConstantMessage.kPrayerID)
            parameter.setValue(self.isPraise ? 1 : "0", forKey:  ConstantMessage.kStatus)
        }
        ServiceUtility.callWebService(URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                    if self.isPraise && !self.isPrayer && !self.isUpdate{
                        if let groupId = (dataFromServer.object(forKey: ConstantMessage.kData) as! [String : AnyObject])[ConstantMessage.kGroupPrayerID]{
                            self.answerPrayerWebServices(groupPrayerID: groupId as! Int)
                        }else{
                            self.removefromsuperview()
                            ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                            let delayInSeconds = 1.0
                               DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                                  if self.delegate != nil
                                   {
                                       self.delegate.newGroupPrayerAdded()
                                   }
                            }
                        }
                    }else{
                        self.removefromsuperview()
                        ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                        let delayInSeconds = 1.0
                          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                             if self.delegate != nil
                              {
                                  self.delegate.newGroupPrayerAdded()
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
    
    func answerPrayerWebServices(groupPrayerID : Int)
    {
        let status = "1"
        let parameter = NSMutableDictionary()
        parameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        parameter.setValue(self.groupId, forKey: ConstantMessage.kGroupID)
        parameter.setValue("\(groupPrayerID)", forKey: ConstantMessage.kPrayerID)
        parameter.setValue(status, forKey: ConstantMessage.kStatus)
        ServiceUtility.callWebService(ANSWER_PRAYER_URL, parameters: parameter, PleaseWait: ConstantMessage.Requesting as String, Requesting: ConstantMessage.PleaseWait as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                {
                   self.removefromsuperview()
                    ServiceUtility.showMessageHudWithMessage("\(ConstantMessage.kPraiseRequest)" as NSString, delay: ConstantMessage.kDelay)
                       let delayInSeconds = 1.0
                         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                            if self.delegate != nil
                             {
                                 self.delegate.newGroupPrayerAdded()
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
}



// MARK: - TextField Delegate
extension AddGroupPrayerViewController : UITextFieldDelegate , UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if textView.text.count < 2 && text == "" {
            textViewPlaceholder.isHidden = false
        }
        if textView.text.isEmpty && text != ""
        {
            textViewPlaceholder.isHidden = true
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty {
            textViewPlaceholder.isHidden = false
        }else
        {
            textViewPlaceholder.isHidden = true
        }
    }
}

// MARK: - PickerView Delegate
extension AddGroupPrayerViewController : UIPickerViewDelegate,UIPickerViewDataSource
{
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return   intervalReminderListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return intervalReminderListArray[row]
    }
}


// MARK: - reminder view
extension AddGroupPrayerViewController
{
    func reminderOn()
    {
        self.setCurrentDateTimeOnUi()
        showReminderView.isHidden=false
        isreminderOnImageView.image = #imageLiteral(resourceName: "addPrayer_select_radio_button_Image")
        isReminderOn = true
        hideReminderConsraint.constant = 73
    }
    func reminderOff()
    {
        showReminderView.isHidden=true
        isreminderOnImageView.image = #imageLiteral(resourceName: "addPrayer_unselect_radio_button")
        isReminderOn = false
        hideReminderConsraint.constant = 40
        // reset reminder values
        intervalReminderSelectedIndex = 0
        reminderSeletedTime = currentDatInString
        // reflect that value in UI
        setreminders()
    }
    func setreminders()
    {
        self.repeatReminderLabel.text = intervalReminderListArray[intervalReminderSelectedIndex]
        self.timeLabel.text = reminderSeletedTime
    }
    
    func setCurrentDateTimeOnUi()
    {
        let selecteddate = NSDate()
        let f:DateFormatter = DateFormatter()
        f.dateFormat = ConstantMessage.kDateForamte
        let newdateStrig = f.string(from: selecteddate as Date)
        let newdateDate = f.date(from: newdateStrig)
        f.dateFormat = ConstantMessage.kDateForamte1
        currentDatInString = f.string(from: newdateDate!)
        reminderSeletedTime = currentDatInString
        publishDateTime  = currentDatInString
        intervalReminderSelectedIndex = 0
        setreminders()
    }

    func setPikkerForTextFiled()
    {
        imaginerTextField.resignFirstResponder()
       let frame = CGRect(x: 0, y: 0.0, width: self.view.frame.size.width, height: 220.0)
        if pickerOpenType == 3
        {
            pickerView = supportingfuction.UIpikkerview(frame: frame)
            pickerView.dataSource = self
            pickerView.delegate = self
            imaginerTextField.inputView = pickerView
            pickerView.reloadAllComponents()
        }else
        {
            datePikker = supportingfuction.datePikkerView(mode: UIDatePicker.Mode.dateAndTime, frame: frame)
            imaginerTextField.inputView = datePikker
        }
          imaginerTextField.becomeFirstResponder()
    }
   
    
    @objc func doneBtnCliked() {
       imaginerTextField.resignFirstResponder()
        if pickerOpenType == 3
        {
            // interval
            intervalReminderSelectedIndex = pickerView.selectedRow(inComponent: 0)
            setreminders()
        }else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.system
            dateFormatter.dateFormat = ConstantMessage.kDateForamte1
            let dateString = dateFormatter.string(from: datePikker.date)
            
            if pickerOpenType == 1
            {
                // publish
                publishDateTime = dateString
                publishDateLable.text = dateString
                
            }else
            {
                // reminder
                reminderSeletedTime = dateString
                setreminders()
            }
        }
        pickerOpenType = 0
    }
    
    func setToolBar()
    {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40)
        toolbar.barStyle = .default
        let flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: ConstantMessage.kDone, style: .done, target: self, action: #selector(self.doneBtnCliked))
        let cancelButton = UIBarButtonItem(title: ConstantMessage.kCancel, style: .done, target: self, action: #selector(self.cancelbuttonCliked))
        toolbar.items = [cancelButton,flexibleSpaceLeft, doneButton]
        imaginerTextField.inputAccessoryView = toolbar
    }
    @objc func cancelbuttonCliked()
    {
         pickerOpenType = 0
         imaginerTextField.resignFirstResponder()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension AddGroupPrayerViewController{
    
    @IBAction func prayerBtnTapped(_ sender : UIButton){
       self.isPrayer = true
       self.isPraise = false
       prayerImageView.image = UIImage(named:  ConstantMessage.kAddPrayerBtnImage)
       pariseImageView.image = UIImage(named:  ConstantMessage.kAddUnSelectPrayer)
       groupReminder.text = ConstantMessage.kGroupPrayerReminder
       prayerAnonymous.text = ConstantMessage.kPrayerAnonymous
        if isMyGroupPrayer && isWall{
            shareableTextLable.text = ConstantMessage.kPrayerAnonymous
        }
       
    }
    
    @IBAction func pariseBtnTapped(_ sender : UIButton){
        self.isPrayer = false
        self.isPraise = true
        prayerImageView.image = UIImage(named:  ConstantMessage.kAddUnSelectPrayer)
        pariseImageView.image = UIImage(named:  ConstantMessage.kAddPrayerBtnImage)
        groupReminder.text = self.kGroupPraiseReminder
        prayerAnonymous.text = self.kPraiseAnonymous
       if isMyGroupPrayer && isWall{
            shareableTextLable.text = self.kPraiseAnonymous
        }
    }
}

