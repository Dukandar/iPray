//
//  DefaultsManager.swift
//  iPray
//
//  Created by Ishan Sunilkumar on 25/08/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import Foundation

enum USDKey : String{
    
    case ISLOGGED  =  "ISLOGGED"
    
}

class DefaultsManager : UserDefaults{
    
    static var share =  DefaultsManager()
    
    func isUserLoggedIn() -> Bool{
        return self.bool(forKey: USDKey.ISLOGGED.rawValue)
    }
    
    func setUserAsLoggedIn() {
        self.set(true, forKey: USDKey.ISLOGGED.rawValue)
        self.synchronize()
    }
    
    func setUserAsLoggedOUT() {
        self.set(false, forKey: USDKey.ISLOGGED.rawValue)
        self.synchronize()
    }
    
    var deviceToken : String? {
        set(newValue){
            self.set(newValue, forKey: DefaultsManagerKeys.kDeviceToken)
        }get{
            return self.object(forKey: DefaultsManagerKeys.kDeviceToken) as? String
        }
    }
    
    var authenticationKey : String? {
        set(newValue){
            self.set(newValue, forKey: DefaultsManagerKeys.kAuthenticationKey)
        }get{
            return self.object(forKey: DefaultsManagerKeys.kAuthenticationKey) as? String
        }
    }
    
    var isShowHelp : Bool? {
        set(newValue){
            self.set(newValue, forKey: DefaultsManagerKeys.kIsShowHelp)
        }get{
            return self.object(forKey: DefaultsManagerKeys.kIsShowHelp) as? Bool
        }
    }
    
    var isShowTagHelp : Bool? {
        set(newValue){
            self.set(newValue, forKey: DefaultsManagerKeys.kIsShowTagHelp)
        }get{
            return self.object(forKey: DefaultsManagerKeys.kIsShowTagHelp) as? Bool
        }
    }
    
    var isShowGroupHelp : Bool? {
       set(newValue){
           self.set(newValue, forKey: DefaultsManagerKeys.kIsShowGroupHelp)
       }get{
           return self.object(forKey: DefaultsManagerKeys.kIsShowGroupHelp) as? Bool
       }
    }
    
    var loginData : NSDictionary? {
        set(newValue){
            do {
                let archiveData = try NSKeyedArchiver.archivedData(withRootObject: newValue as Any, requiringSecureCoding: true)
                self.set(archiveData, forKey: DefaultsManagerKeys.kLoginData)
            }catch let error {
                fatalError(error.localizedDescription)
            }
        }get{
            do {
                if let data = self.object(forKey: DefaultsManagerKeys.kLoginData){
                    if(data is Data){
                        let value = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data)
                        return (value as! NSDictionary)
                    }else{
                        return (data as! NSDictionary)
                    }
                }
            }catch let error {
                fatalError(error.localizedDescription)
            }
            return NSDictionary()
        }
    }
    
    var isShowTagInvitation : Bool? {
        set(newValue){
            self.set(newValue, forKey: DefaultsManagerKeys.kShowTagInvitation)
        }get{
            return self.object(forKey: DefaultsManagerKeys.kShowTagInvitation) as? Bool
        }
    }
    
    var isNotification : Bool? {
        set(newValue){
            self.set(newValue, forKey: DefaultsManagerKeys.kNotification)
        }get{
            return self.object(forKey: DefaultsManagerKeys.kNotification) as? Bool
        }
    }
    
}


//MARK:- Keys
class DefaultsManagerKeys{
    static let kDeviceToken         = ConstantMessage.kDeviceToken
    static let kAuthenticationKey   = ConstantMessage.kAuthenticationKey
    static let kIsShowHelp          = ConstantMessage.kIsShowHelp
    static let kIsShowTagHelp       = ConstantMessage.kIsShowTagHelp
    static let kIsShowGroupHelp     = ConstantMessage.kIsShowGroupHelp
    static let kLoginData           = ConstantMessage.kLoginData
    static let kShowTagInvitation   = ConstantMessage.kShowTagInvitation
    static let kNotification        = ConstantMessage.kNotification1
}

