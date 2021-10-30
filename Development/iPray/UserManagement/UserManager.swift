//
//  UserManager.swift
//  iPray
//
//  Created by Ishan Sunilkumar on 26/09/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import UIKit

private var userManager : UserManager? = nil
class UserManager: NSObject {
    
   var countryCode : String?
   var contact : String?
   var gender : String?
   var profileImage : String?
   var userName : String?
   var userID : String?
   var userEmail : String?
    
    static var shareManger : UserManager {
        
        if (userManager == nil) {
            userManager = UserManager()
        }
        return userManager!
    }
    
    func setLoginDataWith(data : NSDictionary?){
        
        if let name = data?.value(forKey: LoginDataKey.kName){
            self.userName = name as? String ?? ""
        }
        if let email = data?.value(forKey: LoginDataKey.kEmail){
            self.userEmail = email as? String ?? ""
        }
        if let userID = data?.value(forKey: LoginDataKey.kUserID){
            self.userID = userID as? String ?? ""
        }
        if let gender = data?.value(forKey: LoginDataKey.kGender){
            self.gender = gender as? String ?? ""
        }
        if let imageURL = data?.value(forKey: LoginDataKey.kImageURL){
            self.profileImage = imageURL as? String ?? ""
        }
        if let countryCode = data?.value(forKey: LoginDataKey.kCountryCode){
            self.countryCode = countryCode as? String ?? ""
        }
        if let mobileNumber = data?.value(forKey: LoginDataKey.kMobileNo){
            self.contact = mobileNumber as? String ?? ""
        }
    }
    
    func updateProfileImageWith(newURL : String){
        self.profileImage = newURL
    }
}


struct LoginDataKey {
    static let kName            = ConstantMessage.kName
    static let kEmail           = ConstantMessage.kEmail
    static let kUserID          = ConstantMessage.kUserID
    static let kGender          = ConstantMessage.kGender
    static let kImageURL        = ConstantMessage.kImageURL
    static let kCountryCode     = ConstantMessage.kCountryCode
    static let kMobileNumber    = ConstantMessage.kMNumber
    static let kMobileNo        = ConstantMessage.kMobileNo
}


