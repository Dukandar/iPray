//
//  Login_Apple.swift
//  iPray
//
//  Created by Sunilkumar Basappa on 10/02/21.
//  Copyright © 2021 TrivialWorks. All rights reserved.
//

import Foundation
import AuthenticationServices
//MARK:- Sign In With Apple
@available(iOS 13.0, *)
extension HomeViewController:ASAuthorizationControllerPresentationContextProviding,ASAuthorizationControllerDelegate {
    
    func signInWithApple(cell : UITableViewCell) {
        //Sign In With Apple
         let appleBtn = cell.viewWithTag(2000) as! ASAuthorizationAppleIDButton
         appleBtn.isHidden = false
         (cell.viewWithTag(1)!).backgroundColor = UIColor.clear
         cell.viewWithTag(13)?.isHidden = true
         appleBtn.addTarget(self, action: #selector(appleBtnTapped), for: .touchUpInside)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // unique ID for the user
            let userID = appleIDCredential.user
            let userAppleData : NSMutableDictionary = NSMutableDictionary()
            userAppleData.setValue(appleIDCredential.fullName?.givenName, forKey: ConstantMessage.kName)
            userAppleData.setValue(appleIDCredential.email, forKey: ConstantMessage.kEmail)
            userAppleData.setValue(ConstantMessage.kMale, forKey: ConstantMessage.kGender )
            userAppleData.setValue(userID, forKey: ConstantMessage.kId)
            self.webServiceWith(userFbData: userAppleData,isLoginWithAppleID: true)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
           guard let error = error as? ASAuthorizationError else {
               return
           }
           switch error.code {
           case .canceled:break
           case .unknown:break
           case .invalidResponse:break
           case .notHandled:break
           case .failed:break
           @unknown default:break
           }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
    
    //IBAction
    // this is the function that will be executed when user tap the button
    @IBAction func appleBtnTapped(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
              let request = appleIDProvider.createRequest()
              request.requestedScopes = [.fullName, .email]
              let authorizationController = ASAuthorizationController(authorizationRequests: [request])
              authorizationController.delegate = self
              authorizationController.presentationContextProvider = self
              authorizationController.performRequests()
    }
}
