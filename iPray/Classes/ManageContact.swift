//
//  ManageContact.swift
//  iPray
//
//  Created by Saurabh Mishra on 27/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI
import Contacts
import ContactsUI
import AFNetworking
           
var conatactManger = contactManageClass()
protocol contactfetchSuccesFully
{
    func reloadview()
}

class contactManageClass
{
    // MARK: - Variables
    var db : DatabaseHandler = DatabaseHandler()
    let contactStore = CNContactStore()
    // save already in DB
    var previousConatctArray = NSMutableArray()
    // new fetch array from device
    var newDeviceConatctArray = NSMutableArray()
    //new array uploaded on server
    var uploadNewContactArray = NSMutableArray()
    //delete previous contact
    var deleteConatctArray = NSMutableArray()
    // fetch latest list from server
    var newContactFromServer = NSMutableArray()
    var deligate :contactfetchSuccesFully?
    var processStart = false
    func fetchContactFromList()
    {
        let query : String = "SELECT * FROM Contact ORDER BY name"
        conatactManger.previousConatctArray = db.getDataWithQuery(query)
    }
    
    // MARK: - Save Contact List
    func saveContactToList() {
        DispatchQueue.global(qos: .background).async {
            if  self.db.removeObject(ConstantMessage.kContact, where: "")
            {
            }else
            {
            }
            let insertStatus  = self.db.insertData(inBulk: ConstantMessage.kContact,  conatactManger.newContactFromServer)
            if insertStatus == -1
            {
            }else
            {
            }
        }
    }
    
    // MARK: - start Background Service
    func startBackgroundService()
    {
        conatactManger.newContactFromServer.removeAllObjects()
        // if user has none contact
        if conatactManger.newDeviceConatctArray.count == 0
        {
            // remove all previous store conatc from list also from UI
            conatactManger.newContactFromServer.removeAllObjects()
            conatactManger.deligate?.reloadview()
            conatactManger.processStart = false
            // delete all record from local db and objects
            conatactManger.deleteAllRecord()
        }else
        {
            // upload all contact to the server
            conatactManger.uploadContactDetailWebService()
        }
    }
    
    // MARK: -  Function to fetch contacts from Phone contact book
    func getUsercontactContacts()
    {
        if conatactManger.processStart
        {
            return
        }
        ServiceUtility.hideProgressHudInView()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        let delayInSeconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
       conatactManger.getContacts()
        }
    }
    
    func getContacts()
    {
        conatactManger.processStart = true
        conatactManger.requestForAccess()
        conatactManger.newDeviceConatctArray.removeAllObjects()
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        var results: [CNContact] = []
        do {
            try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor
                ])) {
                    (contact, cursor) -> Void in
                    ServiceUtility.hideProgressHudInView()
                    results.append(contact)
            }
        }
        catch
        {
            ServiceUtility.hideProgressHudInView()
            conatactManger.processStart = false
        }
        ServiceUtility.hideProgressHudInView()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        self.processContacts(results: results)
        ServiceUtility.hideProgressHudInView()
        conatactManger.startBackgroundService()
    }
    
    func processContacts(results: [CNContact]  )
    {
        for contact in results
        {
            if contact.phoneNumbers.count != 0 {
                var name = contact.givenName
                if name == ""
                {
                    name =  contact.familyName
                }else
                {
                    name =  name  + " " + contact.familyName
                }
                for tempcontact in contact.phoneNumbers {
                    var tempnumber = ""
                    var tempcountry_code = ""
                    var modified_number = ""
                    tempnumber = tempcontact.value.value(forKey: ConstantMessage.kDigits) as! String
                   // if let x = Int(tempnumber){
                        if(tempnumber.first == "0") {
                            tempnumber = String(tempnumber.dropFirst())
                            if(tempnumber.first == "0")
                            {
                                tempnumber = String(tempnumber.dropFirst())
                            }
                            tempnumber = "+" + tempnumber
                        }
                        if(tempnumber.first == "+")  {
                            modified_number = tempnumber
                            tempcountry_code = "N/A"
                        }else
                        {
                            if (tempcontact.value.value(forKey: ConstantMessage.kCountryCode) as? String) != nil{
                                tempcountry_code = "+" +  supportingfuction.getCountryCallingCode((tempcontact.value.value(forKey: ConstantMessage.kCountryCode) as! String).uppercased())
                                modified_number = tempcountry_code + tempnumber
                            }else{
                            }
                        }
                    if (tempnumber != "" && tempnumber.count>6)  && name.trimmingCharacters(in: CharacterSet.whitespaces) != "" && modified_number != UserManager.shareManger.contact!
                        {
                            let temprecord = NSMutableDictionary()
                            // temprecord.setValue(tempnumber, forKey: "number")
                            temprecord.setValue(modified_number, forKey: ConstantMessage.kModifiedNo)
                            // temprecord.setValue(tempcountry_code, forKey: "isdCode")
                            temprecord.setValue(name, forKey: ConstantMessage.kName)
                            if !conatactManger.newDeviceConatctArray.contains(temprecord)
                            {
                                conatactManger.newDeviceConatctArray.add(temprecord.mutableCopy())
                            }
                            temprecord.removeAllObjects()
                        }
                    //}
                }
            }
        }
    }
}

// MARK: - Web Service
extension contactManageClass
{
    func changeServerDataIntolocalDbFormat(serverArray:NSArray)
    {
        conatactManger.newContactFromServer = serverArray.mutableCopy() as! NSMutableArray
        conatactManger.previousConatctArray = serverArray.mutableCopy() as! NSMutableArray
        // show updated data to the user via UI
        conatactManger.deligate?.reloadview()
        conatactManger.processStart = false
        // save data to the DB from furthur use
        conatactManger.saveContactToList()
    }
    
    //MARK: get user details Webservice
    func uploadContactDetailWebService()
    {
        ServiceUtility.hideProgressHudInView()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        let  allcontactString = arrayToJSNString(dataArray: conatactManger.newDeviceConatctArray)
        perameter.setValue(allcontactString, forKey: ConstantMessage.kContacts)
        let Contact_URL = SAVE_USER_CONTACT_URL
        if allcontactString == ""
        {
            conatactManger.processStart = false
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay: ConstantMessage.kDelay)
            return
        }
        if(!ServiceUtility.hasConnectivity())
        {
            conatactManger.processStart = false
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay: ConstantMessage.kDelay)
            return
        }
                let manager = AFHTTPSessionManager()
                manager.responseSerializer = AFJSONResponseSerializer()
                manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:ConstantMessage.kAPIKEY)
                manager.post(Contact_URL, parameters: perameter, progress: nil, success:
                    {
                        requestOperation, response  in
                        ServiceUtility.hideProgressHudInView()
                            let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
                            ServiceUtility.hideProgressHudInView()
                            if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                            {
                                conatactManger.changeServerDataIntolocalDbFormat(serverArray: dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray )
                            }
                            else
                            {
                                conatactManger.processStart = false
                                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay: ConstantMessage.kDelay)
                            }
                }, failure: {
                    requestOperation, error in
                    conatactManger.processStart = false
                    ServiceUtility.hideProgressHudInView()
                })
        }
    }

    func arrayToJSNString(dataArray:NSArray) -> String
    {
        var jsonString = ""
        if(dataArray.count>0)
        {
            let jsonData: NSData?
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dataArray, options: []) as NSData?
            } catch _ as NSError {
                jsonData = nil
            } catch {
                fatalError()
            }
            jsonString = (NSString(data: jsonData! as Data, encoding: String.Encoding.utf8.rawValue)! as NSString) as String
        }
        return jsonString
    }
    
//MARK:- request contact access
extension contactManageClass
{
    func requestForAccess() {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authStatus == .denied
        {
            let alertView = UIAlertController(title: ConstantMessage.kAllowContactAccess, message:ConstantMessage.kAllowSetting, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: ConstantMessage.kCancel, style: .cancel, handler: nil))
            alertView.addAction(UIAlertAction(title: ConstantMessage.kOk, style: .default, handler: { (alertAction) -> Void in
                //////////Settings button clicked ///////////////
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl
                {
                    //UIApplication.shared.openURL(url as URL)
                    UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(["":""]), completionHandler: { (bool) in
                    })
                }
            }))
            ApplicationDelegate.window?.rootViewController?.present(alertView, animated: true, completion: nil)
        }
    }
    
    func contactRequestStatus() -> Bool
    {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authStatus == .authorized
        {
            return true
        }
        return false
    }
    
    func deleteAllRecord()
    {
        conatactManger.previousConatctArray.removeAllObjects()
        conatactManger.newDeviceConatctArray.removeAllObjects()
        conatactManger.uploadNewContactArray.removeAllObjects()
        conatactManger.deleteConatctArray.removeAllObjects()
        conatactManger.newContactFromServer.removeAllObjects()
            // remove all local DB
            if  self.db.removeObject(ConstantMessage.kContact, where: "")
            {
            }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

