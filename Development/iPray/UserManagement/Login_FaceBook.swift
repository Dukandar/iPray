//
//  Login_FaceBook.swift
//  iPray
//
//  Created by Sunilkumar Basappa on 10/02/21.
//  Copyright © 2021 TrivialWorks. All rights reserved.
//

import Foundation

// MARK: - Facebook Login and Sign up function
extension HomeViewController {
    func loginFacebookRequest() {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection as NSString, delay:  ServiceUtility.messageDelay())
            return
        }
        FBSDKAccessToken.setCurrent(nil)
        let FBLoginManager = FBSDKLoginManager()
        FBLoginManager.logIn(withReadPermissions:  [ConstantMessage.kEmail], from: self, handler: { (FBSDKLoginManagerLoginResult, Error) in
        ServiceUtility.hideProgressHudInView()
            if Error != nil
            {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay:  ServiceUtility.messageDelay())
                
            } else if (FBSDKLoginManagerLoginResult?.isCancelled)!
            {
                // Authorization has been canceled by user
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.kRequestCancelled as NSString, delay:  ServiceUtility.messageDelay())
            }else
            {
                // Authorization has been given by user
                debugPrint(" fb response ", FBSDKLoginManagerLoginResult?.grantedPermissions.description as Any)
                self.populateUserDetails()
            }
        })
    }
    /**
     * populateUserDetails Function will return data from facebook.
     *
     */
    func populateUserDetails() {
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: (self.returnParamFields() as NSDictionary as! [AnyHashable: Any]))
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
        ServiceUtility.hideProgressHudInView()
        if ((error) != nil)
        {
            // Process error
            debugPrint("Error: \(String(describing: error))")
        }
        else
        {
            let userFbData = result as! NSDictionary
            if (userFbData[ConstantMessage.kId] == nil && userFbData[ConstantMessage.kId] as! String == "") || (userFbData[ConstantMessage.kName] == nil && userFbData[ConstantMessage.kName] as! String == "") {
                ServiceUtility.showMessageHudWithMessage(ConstantMessage.RequestFail, delay:  ServiceUtility.messageDelay())
                return
            }
            else{
                self.webServiceWith(userFbData: userFbData)
            }
        }
      })
    }
}


//MARK:- Web serivice
extension HomeViewController {
    func webServiceWith(userFbData : NSDictionary!,isLoginWithAppleID : Bool = false) {
        if(!ServiceUtility.hasConnectivity())
        {
            ServiceUtility.showMessageHudWithMessage(ConstantMessage.NoInternetConnection, delay:  ServiceUtility.messageDelay())
            return
        }
        ServiceUtility.callWebService(LOGIN_WITH_FACEBOOK, parameters: returnFaceBookParamsWith(userFbData: userFbData, isLoginWithAppleID: isLoginWithAppleID), PleaseWait: ConstantMessage.PleaseWait as String, Requesting: ConstantMessage.Requesting as String) { (success, dataFromServer) in
            if success {
                if dataFromServer.object(forKey:ConstantMessage.kStatus) as! Bool == true
                {
                    let data = (dataFromServer.object(forKey: ConstantMessage.kData)! as! NSDictionary)
                    var authentication_key = ""
                    if dataFromServer.object(forKey: ConstantMessage.kAPIKEY)  != nil
                        
                    {
                        authentication_key = dataFromServer.object(forKey:ConstantMessage.kAPIKEY) as! String
                    }
                    DefaultsManager.share.authenticationKey = authentication_key
                    DefaultsManager.share.isShowHelp = false
                    DefaultsManager.share.isShowTagHelp = false
                    DefaultsManager.share.isShowGroupHelp = false
                    UserDefaults.standard.synchronize()
                    if dataFromServer.object(forKey: ConstantMessage.kEmail) != nil &&  dataFromServer.object(forKey: ConstantMessage.kMobileNo) as! Bool == false
                    {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kMobileOtpViewController) as! MobileOtpViewController
                        vc.data = data
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else
                    {
                        DefaultsManager.share.loginData = data
                        UserManager.shareManger.setLoginDataWith(data: DefaultsManager.share.loginData)
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kBubblesViewController) as! BubblesViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                        conatactManger.deleteAllRecord()
                    }
                }else
                {
                    ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as! NSString, delay:  ServiceUtility.messageDelay())
                }
            }
            else
            {
                ServiceUtility.showMessageHudWithMessage(dataFromServer.object(forKey: ConstantMessage.kMessage) as!  NSString, delay:  ServiceUtility.messageDelay())
            }
        }
    }
    
    func returnFaceBookParamsWith(userFbData : NSDictionary,isLoginWithAppleID : Bool = false)-> NSMutableDictionary {
        let email = userFbData.value(forKey: ConstantMessage.kEmail) as? String
        var gender = ""
        if let tempValue =  userFbData.value(forKey: ConstantMessage.kGender) as? String{
            gender = (tempValue == ConstantMessage.kMale) ? "1" : (tempValue == ConstantMessage.kFemale) ? "2" : "3"
        }
        var deviceToken = "0"
        if let token = DefaultsManager.share.deviceToken{
            deviceToken = token
        }
        let image = (isLoginWithAppleID) ? iPrayConsant.kAppleLoginURL : "http://graph.facebook.com/\(userFbData[ConstantMessage.kId] as! String)/picture?type=large"
        return [ConstantMessage.kEmail             : email ?? "",
                ConstantMessage.kGender            : gender,
                ConstantMessage.kName              : userFbData[ConstantMessage.kName] as! String,
                ConstantMessage.kDeviceType        : ConstantMessage.kConstDeviceType,
                ConstantMessage.kDeviceToken       : deviceToken,
                ConstantMessage.kSocialID          : userFbData[ConstantMessage.kId] as! String,
                ConstantMessage.kSocialAuthData    : userFbData[ConstantMessage.kId] as! String,
                ConstantMessage.kLoginType         : 2,
                ConstantMessage.kProfilePic        : image]
    }
}
