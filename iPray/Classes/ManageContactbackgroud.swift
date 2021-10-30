//
//  ManageNewContact.swift
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

var conatactMangerBackground = contactManageNewClass()
class contactManageNewClass
{
    // MARK: - Variables
    var db : DatabaseHandler = DatabaseHandler()
    let contactStore = CNContactStore()
    // save already in Db
    var previousConatctArray = NSMutableArray()
    // new fetch array from device
    var newDeviceConatctArray = NSMutableArray()
    //new array uploaded on server
    var uploadNewContactArray = NSMutableArray()
    //delete previous contact
    var deleteConatctArray = NSMutableArray()
    var newContactFromServer = NSMutableArray()
    
    func fetchContactFromList() {
        
        DispatchQueue.global(qos: .background).async {
            
            if conatactMangerBackground.previousConatctArray.count == 0
            {
                let query : String = "SELECT * FROM Contact ORDER BY name"
                conatactMangerBackground.previousConatctArray = self.db.getDataWithQuery(query)
                // update UI object
                conatactManger.previousConatctArray = conatactMangerBackground.previousConatctArray
                // fetch new contact
                if conatactMangerBackground.previousConatctArray.count == 0
                {
                    conatactMangerBackground.getUsercontactContacts()
                }
            }
        }
        
    }
    
    
    func saveContactToDb() {
        
        debugPrint("going to save in local Db in backgroud with -> \( conatactMangerBackground.newContactFromServer.count) New contacts")
        
        
        let insertStatus  = db.insertData(inBulk: ConstantMessage.kContact,  conatactMangerBackground.newContactFromServer)
        
        if insertStatus == -1
            
        {
            debugPrint("error while updating local contat array in local Db  background")
            
        }else
        {
            debugPrint("success fully updated local contat arrayin local Db  background")
        }
    }
    
    func deleteSomeContactsFromDB()
    {
        debugPrint("Going to remove Some data in background")
        for items in conatactMangerBackground.deleteConatctArray
        {
            let temp : String = ((items as! NSDictionary).object(forKey: ConstantMessage.kAddressBookID) as? String)!
            if  db.removeObject(ConstantMessage.kContact, where: "\(ConstantMessage.kAddressBookID) == \(temp)")
            {
                debugPrint("\(temp) remove local DB in background")
                
            }
        }
        
    }
    
    func startBackgroundService()
    {
        conatactMangerBackground.newContactFromServer.removeAllObjects()
        // if user has none contact
        if conatactMangerBackground.newDeviceConatctArray.count == 0
        {
            // remove all previous store conatc from list also from UI
            conatactMangerBackground.deleteAllRecord()
            
        }else //if conatactMangerBackground.previousConatctArray.count == 0
        {
            // upload all contact to the server
            conatactMangerBackground.uploadContactDetailWebService(tag: 1)
        }
        
    }
    
    func changeServerDataIntolocalDbFormat(serverArray:NSArray,isdeleteAll:Bool)
    {
        // save data to the Db from furthur use
        if isdeleteAll
        {
            conatactMangerBackground.deleteAllRecord()
            conatactMangerBackground.newContactFromServer = serverArray.mutableCopy() as! NSMutableArray
            conatactMangerBackground.previousConatctArray = conatactMangerBackground.newContactFromServer
            
        }else
        {
            conatactMangerBackground.newContactFromServer = serverArray.mutableCopy() as! NSMutableArray
            conatactMangerBackground.previousConatctArray.addObjects(from: conatactMangerBackground.newContactFromServer.mutableCopy() as! [Any])
        }
        
        // update contact manager UI object
        conatactManger.previousConatctArray =   conatactMangerBackground.previousConatctArray.mutableCopy() as! NSMutableArray
        // update DB
        conatactMangerBackground.saveContactToDb()
    }
    
    
    func deleteAllRecord()
    {
        conatactMangerBackground.previousConatctArray.removeAllObjects()
        conatactMangerBackground.newDeviceConatctArray.removeAllObjects()
        conatactMangerBackground.uploadNewContactArray.removeAllObjects()
        conatactMangerBackground.deleteConatctArray.removeAllObjects()
        conatactMangerBackground.newContactFromServer.removeAllObjects()
        
        debugPrint("Going to remove local DB in background")
        if  db.removeObject(ConstantMessage.kContact, where: "")
        {
            debugPrint("successfully remove local DB in background")
            
        }
    }
    
    
    
}

// MARK: - Web Service
extension contactManageNewClass
{
    
    func uploadContactDetailWebService(tag : Int)
    {
        
        
        let perameter = NSMutableDictionary()
        perameter.setValue(UserManager.shareManger.userID!, forKey: ConstantMessage.kUserID)
        
        var allcontactString = ""
        var Contact_URL = ""
        if tag == 1
        {  // upload all
            
            allcontactString = ArrayToJSNString(dataArray: conatactMangerBackground.newDeviceConatctArray)
            perameter.setValue(allcontactString, forKey: ConstantMessage.kContacts)
            Contact_URL = SAVE_USER_CONTACT_URL
            
        }else if tag == 2
        {
            // upload new
            allcontactString = ArrayToJSNString(dataArray: conatactMangerBackground.uploadNewContactArray)
            perameter.setValue(allcontactString, forKey: ConstantMessage.kContacts)
            Contact_URL = SAVE_USER_NEW_CONTACT_URL
            
            
        }else
        {  // delete contact from server
            
            for var i in 0..<conatactMangerBackground.deleteConatctArray.count
            {
                i = i + 0
                
                if i != 0
                {
                    allcontactString = allcontactString + ","
                }
                let temp : String = ((conatactMangerBackground.deleteConatctArray.object(at: i) as! NSDictionary).object(forKey: ConstantMessage.kAddressBookID) as? String)!
                allcontactString = allcontactString + temp
                
            }
            Contact_URL = SAVE_USER_DELETE_CONTACT_URL
            perameter.setValue(allcontactString, forKey: ConstantMessage.kContactID)
        }
        if allcontactString == ""
        {
            
            //ServiceUtility.showMessageHudWithMessage(RequestFail, delay: ConstantMessage.kDelay)
            return
        }
        if(!ServiceUtility.hasConnectivity())
        {
            return
        }
        DispatchQueue.global(qos: .background).async
            {
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField: ConstantMessage.kAPIKEY)
        
        manager.post(Contact_URL, parameters: perameter, progress: nil, success:
            {
                requestOperation, response  in
                
                DispatchQueue.global(qos: .background).async {
                    debugPrint("contact uploading success ->webservice")
                    let dataFromServer :NSDictionary = (response as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    if dataFromServer.object(forKey: ConstantMessage.kStatus) as! Bool == true
                    {
                        debugPrint("contact uploading success ->response")
                        if tag == 1
                        {
                            debugPrint("All contact uploaded successfully on server -> \((dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray).count)")
                            // first time upload all
                            conatactMangerBackground.changeServerDataIntolocalDbFormat(serverArray: dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray,isdeleteAll: true)
                        }else if tag == 2
                        {
                            debugPrint("new contact uploaded successfully on server -> \((dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray).count)")
                            // inset new contact
                            conatactMangerBackground.changeServerDataIntolocalDbFormat(serverArray: dataFromServer.object(forKey: ConstantMessage.kData)! as! NSArray,isdeleteAll: false)
                            
                        }else
                        {
                            debugPrint("Delete contact successfully from server -> \(conatactMangerBackground.deleteConatctArray.count)")
                            // delelet contact
                            conatactMangerBackground.deleteSomeContactsFromDB()
                        }
                        
                        
                        if tag == 2 && conatactMangerBackground.deleteConatctArray.count != 0
                        {
                            conatactMangerBackground.uploadContactDetailWebService(tag: 3)
                        }
                    }
                    else
                    {
                        
                        
                    }
                }
                
                
        }, failure: {
            requestOperation, error in
            
            debugPrint("contact uploading error -> \(error)")
            
        })
        
    }
    }
    
    
}
// extra function
extension contactManageNewClass
{
    /**
     *  Function to fetch contacts from Phone contact book
     */
    
    
    
    func getUsercontactContacts()
    {
        conatactMangerBackground.requestForAccess()
        conatactMangerBackground.newDeviceConatctArray.removeAllObjects()
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
                    
                    results.append(contact)
                    
                    // conatactMangerBackground.hideContactLoader()
            }
        }
        catch
        {
            
            debugPrint("Error while adding")
        }
        
        for contact in results
        {
            
            
            if contact.phoneNumbers.count != 0 {
                
                let name = contact.givenName + " " + contact.familyName
                
                for tempcontact in contact.phoneNumbers {
                    
                    var tempnumber = ""
                    var tempcountry_code = ""
                    var modified_number = ""
                    tempnumber = tempcontact.value.value(forKey: ConstantMessage.kDigits) as! String
                    if let x = Int(tempnumber)
                    {
                        if(tempnumber.first == "0")
                        {
                            tempnumber = String(tempnumber.dropFirst())
                            if(tempnumber.first == "0")
                            {
                                tempnumber = String(tempnumber.dropFirst())
                                
                            }
                            tempnumber = "+" + tempnumber
                        }
                        
                        if(tempnumber.first == "+")
                        {
                            modified_number = tempnumber
                            tempcountry_code = ConstantMessage.kNA
                            
                        }else
                        {
                            tempcountry_code = "+" +  supportingfuction.getCountryCallingCode((tempcontact.value.value(forKey: ConstantMessage.kCountryCode) as! String).uppercased())
                            
                            modified_number = tempcountry_code + tempnumber
                        }
                        
                        if (tempnumber != "" && tempnumber.count>6)  && name.trimmingCharacters(in: CharacterSet.whitespaces) != "" && modified_number != UserManager.shareManger.contact!
                        {
                            let temprecord = NSMutableDictionary()
                          //  temprecord.setValue(tempnumber, forKey: "number")
                            temprecord.setValue(modified_number, forKey: ConstantMessage.kModifiedNo)
                          //  temprecord.setValue(tempcountry_code, forKey: "isdCode")
                            temprecord.setValue(name, forKey: ConstantMessage.kName)
                            if !conatactMangerBackground.newDeviceConatctArray.contains(temprecord)
                            {
                                conatactMangerBackground.newDeviceConatctArray.add(temprecord.mutableCopy())
                            }
                            temprecord.removeAllObjects()
                        }
                    }
                    
                }
            }
            
        }
        conatactMangerBackground.startBackgroundService()
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
    
    func requestForAccess() {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authStatus == .denied
        {
            let alertView = UIAlertController(title: ConstantMessage.kAllowContactAccess, message: ConstantMessage.kAllowSetting, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: ConstantMessage.kCancel, style: .cancel, handler: nil))
            alertView.addAction(UIAlertAction(title: ConstantMessage.kOk, style: .default, handler: { (alertAction) -> Void in
                //////////Settings button clicked ///////////////
                let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                if let url = settingsUrl
                {
                    //UIApplication.shared.openURL(url as URL)
                    UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(["":""]), completionHandler: { (bool) in
                        debugPrint("access given for contact")
                    })
                }
            }))
            
            
            ApplicationDelegate.window?.rootViewController?.present(alertView, animated: true, completion: nil)
            
        }
    }
    //MARK: get user details Webservice
    func ArrayToJSNString(dataArray:NSArray) -> String
    {
        var jsonString = ""
        if(dataArray.count>0)
        {
            let jsonData: NSData?
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dataArray, options: []) as NSData?
            } catch let error as NSError {
                jsonData = nil
                
            } catch {
                fatalError()
                
            }
            jsonString = (NSString(data: jsonData! as Data, encoding: String.Encoding.utf8.rawValue)! as NSString) as String
            
        }
        
        return jsonString
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

