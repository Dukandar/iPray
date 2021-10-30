
//
//  ServiceUtility.swift
//  Unifi
//
//  Created by Manvendra on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import AFNetworking

//MARK:- Variables
var hud: MBProgressHUD!
let manager = AFHTTPSessionManager()

class ServiceUtility: NSObject {
    //MARK:- Web service Requests
    
    typealias completionHandler = (_ success:Bool,_ resp:NSDictionary) -> Void
    typealias successHandler = (_ success:Bool)->Void
    typealias errorHandler = (_ success:Bool)->Void
    typealias authHandler = (_ success:Bool)->Void
    
    //MARK:- Web Service Function [Normal]
    class func callWebService(_ URL:String , parameters:NSMutableDictionary ,PleaseWait:String , Requesting:String , completionHandler: @escaping completionHandler)
    {
        if(!ServiceUtility.hasConnectivity())
        {
            completionHandler(false,self.setErrorMessage(message: ConstantMessage.kNoInternetConnection))
        }
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:ConstantMessage.kAPIKEY)
        ServiceUtility.hideProgressHudInView()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        manager.post(URL, parameters: parameters, progress: nil,
                     success: {
                        requestOperation , response in
                        ServiceUtility.hideProgressHudInView()
                        let dataFromServer :NSDictionary = (response as! NSDictionary)
                        if ApplicationDelegate.checkForLogoutApi(dataFromServer : dataFromServer)
                        {
                            ApplicationDelegate.logOutFunction() //New added
                            completionHandler(false,self.setErrorMessage(message: ConstantMessage.LogOutMessage))
                        }else
                        {
                            completionHandler(true,dataFromServer)
                        }
        },
                     failure: {
                        requestOperation, error in
                        ServiceUtility.hideProgressHudInView()
                        debugPrint(error.localizedDescription)
                        if (ConstantMessage.kRequestFailed == error.localizedDescription)
                        {
                            ApplicationDelegate.logOutFunction()
                            completionHandler(false,self.setErrorMessage(message: ConstantMessage.LogOutMessage))
                        }else
                        {
                            completionHandler(false,self.setErrorMessage(message: ConstantMessage.kRequestFail))
                        }
        })
    }
    
    //MARK:- Web Service Function [Without Progress Bar]
    class func callWebServiceWithoutProgressMessage(_ URL:String , parameters:NSMutableDictionary ,PleaseWait:String , Requesting:String , completionHandler: @escaping completionHandler)
    {
        if(!ServiceUtility.hasConnectivity())
        {
            completionHandler(false,self.setErrorMessage(message: ConstantMessage.kNoInternetConnection))
        }
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:ConstantMessage.kAPIKEY)
        ServiceUtility.hideProgressHudInView()
        manager.post(URL, parameters: parameters, progress: nil,
                     success: {
                        requestOperation , response in
                        ServiceUtility.hideProgressHudInView()
                        let dataFromServer :NSDictionary = (response as! NSDictionary)
                        if ApplicationDelegate.checkForLogoutApi(dataFromServer : dataFromServer)
                        {
                            ApplicationDelegate.logOutFunction() //New added
                            completionHandler(false,self.setErrorMessage(message: ConstantMessage.LogOutMessage))
                        }else
                        {
                            completionHandler(true,dataFromServer)
                        }
        },
                     failure: {
                        requestOperation, error in
                        ServiceUtility.hideProgressHudInView()
                        debugPrint(error.localizedDescription)
                        if (ConstantMessage.kRequestFailed  == error.localizedDescription)
                        {
                            ApplicationDelegate.logOutFunction()
                            completionHandler(false,self.setErrorMessage(message: ConstantMessage.LogOutMessage))
                        }else
                        {
                            completionHandler(false,self.setErrorMessage(message: ConstantMessage.kRequestFail))
                        }
        })
    }
    
    //MARK:- Web Service Function [Image MultiPart]
    class func callWebService(_ URL:String , parameters:NSMutableDictionary , uploadImage:NSArray ,imageParam: NSArray ,PleaseWait:String , Requesting:String ,completionHandler: @escaping completionHandler){
        if(!ServiceUtility.hasConnectivity())
        {
            completionHandler(false,self.setErrorMessage(message: ConstantMessage.kNoInternetConnection))
        }
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.requestSerializer.setValue(DefaultsManager.share.authenticationKey, forHTTPHeaderField:ConstantMessage.kAPIKEY)
        ServiceUtility.hideProgressHudInView()
        ServiceUtility.showProgressHud(ServiceUtility.getRandomString() as NSString, labelText:"")
        manager.post(URL, parameters: parameters, constructingBodyWith: { (formData) in
            for i in 0..<uploadImage.count
            {
                formData.appendPart(
                    withFileData: (uploadImage.object(at: i) as! UIImage).jpegData(compressionQuality: 0.1)!,
                    name: imageParam.object(at: i) as! String,
                    fileName: ConstantMessage.kImgJPG,
                    mimeType: ConstantMessage.kIMGSJPG)
            }
        }, progress: { (Progress) in
            debugPrint(Progress.totalUnitCount)
        }, success:
            {
                requestOperation , response in
                ServiceUtility.hideProgressHudInView()
                let dataFromServer :NSDictionary = (response as! NSDictionary)
                if ApplicationDelegate.checkForLogoutApi(dataFromServer : dataFromServer)
                {
                    ApplicationDelegate.logOutFunction()
                    completionHandler(false,self.setErrorMessage(message: ConstantMessage.LogOutMessage))
                }else
                {
                    completionHandler(true,dataFromServer)
                }
        },
           failure: {
            requestOperation, error in
            ServiceUtility.hideProgressHudInView()
            debugPrint(error.localizedDescription)
            if (ConstantMessage.kRequestFailed  == error.localizedDescription)
            {
                completionHandler(false,self.setErrorMessage(message: ConstantMessage.LogOutMessage))
            }else
            {
                completionHandler(false,self.setErrorMessage(message: ConstantMessage.kRequestFail))
            }
        })
    }
}

extension ServiceUtility{
    //MARK:- Other Functions
    class func setErrorMessage(message : NSString) -> NSDictionary
    {
        let err = NSMutableDictionary()
        err.setValue(message, forKey: ConstantMessage.kMessage)
        return (err) as NSDictionary
    }
    
    
    class func getRandomString()->String{
        let randomNumber = Int.random(in: 0...7)
        let toastMessageString = ConstantMessage.kToastMessageArray[randomNumber]
        return toastMessageString
    }
}

extension ServiceUtility
{
    // MARK: - MBProgressHud Methods
    class  func showProgressHud (_ withDetailsLabel:NSString, labelText:NSString)
    {
        hud = MBProgressHUD.showAdded(to: (UIApplication.shared.delegate as! AppDelegate).window, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.color = UIColor(red:113.0 / 255.0, green: 85.0 / 255.0, blue: 148.0 / 255.0, alpha: 0.9)
        hud.detailsLabelText = withDetailsLabel as String
        hud.detailsLabelFont = UIFont.boldSystemFont(ofSize: 15.0)
        hud.labelText = labelText as String
    }
    
    //MARK: - showMessageHudWithMessage Methods
    class func showMessageHudWithMessage(_ message:NSString, delay:CGFloat)
    {
        hud = MBProgressHUD.showAdded(to: (UIApplication.shared.delegate as! AppDelegate).window, animated: true)
        hud.color = UIColor(red:113.0 / 255.0, green: 85.0 / 255.0, blue: 148.0 / 255.0, alpha: 0.9)
        hud.mode = MBProgressHUDMode.text
        hud.detailsLabelText = message as String
        hud.detailsLabelColor = UIColor.white
        let delay = TimeInterval(delay)
        _ = [hud .hide(true, afterDelay: delay)]
    }
    
    class func messageDelay()-> CGFloat{
        return 2.0
    }
    
    class func hideProgressHudInView()
    {
        if hud != nil
        {
            _ = [hud .hide(true)]
            hud = nil
        }
    }
    
    //MARK: Reachable
    class  func hasConnectivity() -> Bool
    {
        let reachability: Reachability = Reachability.forInternetConnection()
        let networkStatus: NetworkStatus = reachability.currentReachabilityStatus()
        return networkStatus != NetworkStatus.NotReachable
    }
}


