//
//  Utility.swift
//  iPray
//
//  Created by Sunilkumar Bassappa on 04/06/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import UIKit

protocol UtilityProtocol {
    func submitBtnActionWith(isChecked : Bool)
    func cancel()
}
private var utilityInstance : Utility? = nil

class Utility: NSObject {
    
    var isChecked = false
    var delegate : UtilityProtocol?
    static var shareUtility : Utility{
        if (utilityInstance == nil){
            utilityInstance = Utility()
        }
        return utilityInstance!
    }
    
    func showPopUpWith(title : String , desc : String , buttonName : String,view : UIView,delegate : UtilityProtocol){
        self.delegate = delegate
        isChecked = false
        let descHeight = returnLableHeightWithDesc(desc: desc, width:  UIScreen.main.bounds.size.width)
        let popView = UIView(frame: UIScreen.main.bounds)
               popView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
               //middView
               let midViewWidth : CGFloat = 300.0
               let midViewHeight : CGFloat = 100 + descHeight
               let midView = UIView(frame: CGRect(x: (popView.frame.size.width - midViewWidth) / 2.0, y: (popView.frame.size.height - midViewHeight)/2.0 ,width: midViewWidth, height: midViewHeight));
               midView.backgroundColor = UIColor.white
               midView.layer.cornerRadius = 10.0
               midView.layer.masksToBounds = true
               popView.addSubview(midView)
               //topView
               let topView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: midView.frame.size.width, height: 44.0))
               //Cancel image
               let imageWidthHeight : CGFloat = 32.0
               let cancelImageView = UIImageView(frame: CGRect(x: 8.0, y: (topView.frame.size.height - imageWidthHeight) /  2.0, width: imageWidthHeight, height: imageWidthHeight))
               cancelImageView.image = UIImage(named:ConstantMessage.kCancelImg)
               topView.addSubview(cancelImageView)
               //Close gesture
               topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeGestureTapped(_:))))
               //Title
               let labelHeight : CGFloat = 40.0
               let titleLable = UILabel(frame: CGRect(x: (cancelImageView.frame.origin.x + cancelImageView.frame.size.width) + 4.0, y: (topView.frame.size.height - labelHeight) / 2.0, width: topView.frame.size.width - cancelImageView.frame.size.width, height: labelHeight))
               titleLable.text = title
               titleLable.font = UIFont.boldSystemFont(ofSize: 14.0)
               titleLable.textColor = UIColor.black
               titleLable.textAlignment = .left
               topView.addSubview(titleLable)
               midView.addSubview(topView)
               //Bottom View
               let bottomHeight : CGFloat = 44.0
               let bottomView = UIView(frame: CGRect(x: 0.0, y: midView.frame.size.height - bottomHeight, width: midView.frame.size.width, height: bottomHeight))
               midView.addSubview(bottomView)
               view.addSubview(popView)
               //CheckBox view
               let checkBoxView = UIView(frame: CGRect(x: 6.0, y: 0.0, width: bottomView.frame.size.width - 120.0, height: bottomView.frame.size.height))
               //CheckBoxImage
               let checkBoxImageHeightWidth : CGFloat = 24.0
               let checkBoxImageView = UIImageView(frame: CGRect(x: 6.0, y: (bottomView.frame.size.height - checkBoxImageHeightWidth) /  2.0, width: checkBoxImageHeightWidth, height: checkBoxImageHeightWidth))
               checkBoxImageView.image = UIImage(named: ConstantMessage.kHelpUnCheckImg)
               checkBoxView.addSubview(checkBoxImageView)
               //Label
               let showAgian = UILabel(frame: CGRect(x: checkBoxImageView.frame.size.width + 18.0, y: 0.0, width: (checkBoxView.frame.size.width - imageWidthHeight), height: checkBoxView.frame.size.height))
               showAgian.text = ConstantMessage.kDontShowAgain
               showAgian.textColor = UIColor.black
               showAgian.font = UIFont(name: ConstantMessage.kMontserratLight, size: 14.0)
               checkBoxView.addSubview(showAgian)
               //Close gesture
               checkBoxView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkBoxGestureTapped(_:))))
               bottomView.addSubview(checkBoxView)
               //Submit button
               let buttonHeigth : CGFloat = 28.0
               let submitButton = UIButton(frame: CGRect(x: checkBoxView.frame.size.width + 4.0 , y:( bottomView.frame.size.height - buttonHeigth) / 2.0, width: bottomView.frame.size.width - checkBoxView.frame.size.width, height:buttonHeigth))
               submitButton.setTitle(buttonName, for: .normal)
               submitButton.setTitleColor(UIColor.blue, for: .normal)
               submitButton.addTarget(self, action: #selector(btn_button(_ :)), for: .touchUpInside)
               bottomView.addSubview(submitButton)
               
               //DescLabel
               let padding : CGFloat = 8.0
        let descLabel = UILabel(frame: CGRect(x: padding, y: (topView.frame.size.height - ((descHeight > 80.0) ? 18.0 : 12.0)), width: midView.frame.size.width - padding, height: midView.frame.size.height - (topView.frame.size.height + bottomView.frame.size.height)))
               descLabel.text = desc
               descLabel.numberOfLines = 0
               descLabel.sizeToFit()
               descLabel.textColor = UIColor.black
               descLabel.font = UIFont(name: ConstantMessage.kMontserratLight, size: 12.0)
               midView.addSubview(descLabel)
    }
    
    //MARK: Action
    @IBAction  func btn_button(_ sender : UIButton){
       if self.delegate != nil {
            self.delegate?.submitBtnActionWith(isChecked: self.isChecked)
        }
    }
    
    @objc func checkBoxGestureTapped(_ gestureView : UITapGestureRecognizer){
        if(gestureView.view?.superview?.subviews[0].subviews[0]  is UIImageView){
            let imageView = gestureView.view?.superview?.subviews[0].subviews[0] as! UIImageView
            if self.isChecked{
                self.isChecked = false
                imageView.image = UIImage(named: ConstantMessage.kHelpUnCheckImg)
            }else{
                self.isChecked = true
                imageView.image = UIImage(named: ConstantMessage.kHelpCheckImg)
            }
            
        }
    }
    
    @objc func closeGestureTapped(_ tapped : UITapGestureRecognizer){
        if self.delegate != nil {
            self.delegate?.cancel()
        }
    }
    
}

extension Utility{
    
    //MARK: Check version
    func checkLatestVersion()
    {
        let currentAppVersion = (Bundle.main.infoDictionary! as NSDictionary).object(forKey: ConstantMessage.kCFBundleShortVersionString) as! String
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.post("\(iPrayConsant.kItunes)", parameters: nil, progress: nil, success: {  requestOperation , response in
            let dataFromServer :NSDictionary = (response as! NSDictionary)
            let responseArray = (dataFromServer.object(forKey: ConstantMessage.kResults) as! NSArray)
            if let appStoreVersion = (responseArray.object(at: 0) as! NSDictionary).object(forKey: ConstantMessage.kVersion)
            {
                if appStoreVersion as! String != currentAppVersion
                {
                    var days = 1
                    if UserDefaults.standard.object(forKey: ConstantMessage.kApplicationUpdateTime) != nil && UserDefaults.standard.object(forKey:ConstantMessage.kApplicationUpdateTime) is NSDate
                    {
                        let lastdate =  UserDefaults.standard.object(forKey: ConstantMessage.kApplicationUpdateTime) as! NSDate
                        let now = Date()
                        let calendar = Calendar.current
                        let ageComponents = calendar.dateComponents([.day], from: lastdate as Date, to: now)
                        days  = ageComponents.day ?? 1
                    }
                    if days >= 1
                    {
                        self.openUpdateVersionPopUp()
                    }
                }
            }
        }) { requestOperation, error in
            debugPrint(error.localizedDescription)
        }
    }
    
    func openUpdateVersionPopUp()
    {
        let date = NSDate()
        UserDefaults.standard.set(date, forKey:ConstantMessage.kApplicationUpdateTime)
        let alertString : String = ConstantMessage.kNewVersion
        let alert = UIAlertController(title: ConstantMessage.kNewVersionAvailable, message: alertString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: ConstantMessage.kNOTHANKS, style: .cancel, handler: {
               (alertAction) -> Void in
               //self.dismiss(animated: true, completion: nil)
              // self.getbubblesListWebService()
           }))
        alert.addAction(UIAlertAction(title: ConstantMessage.kUpdate.uppercased(), style: UIAlertAction.Style.default, handler: {
               (alertAction) -> Void in
               //self.dismiss(animated: true, completion: nil)
              let url = URL(string: iPrayConsant.kAppUrl)!
               UIApplication.shared.open(url, options: [:])
           }))
         //  self.present(alert, animated: true, completion: nil)
    }
}

extension Utility {
    
    func returnLableHeightWithDesc(desc : String,width : CGFloat) -> CGFloat{
        let padding : CGFloat = 8.0
        let descLabel = UILabel(frame: CGRect(x: padding, y: 0.0, width: width, height: 100))
        descLabel.text = desc
        descLabel.numberOfLines = 0
        descLabel.sizeToFit()
        return descLabel.frame.size.height
    }
    
    func serPrayerUserUserDefaults(isChecked : Bool){
        UserDefaults.standard.set(isChecked, forKey: ConstantMessage.kIsPrayer)
        UserDefaults.standard.synchronize()
    }
    
    func getPrayerUserDefaults()-> Bool{
           if(UserDefaults.standard.object(forKey: ConstantMessage.kIsPrayer) != nil){
               return UserDefaults.standard.object(forKey: ConstantMessage.kIsPrayer) as! Bool
           }
           return false
       }
       
       func setShareUserDefaults(isChecked : Bool){
           UserDefaults.standard.set(isChecked, forKey: ConstantMessage.kIsShare)
           UserDefaults.standard.synchronize()
       }
       
       func getShareUserDefaults()-> Bool{
           if(UserDefaults.standard.object(forKey: ConstantMessage.kIsShare) != nil){
             return UserDefaults.standard.object(forKey: ConstantMessage.kIsShare) as! Bool
           }
          return false
       }
       
       func setTagUserDefaults(isChecked : Bool){
        UserDefaults.standard.set(isChecked, forKey: ConstantMessage.kIsTag)
           UserDefaults.standard.synchronize()
       }
       
       func getTagUserDefaults()-> Bool{
           if(UserDefaults.standard.object(forKey: ConstantMessage.kIsTag) != nil){
             return UserDefaults.standard.object(forKey: ConstantMessage.kIsTag) as! Bool
           }
         return false
       }
       
       func updateCorenerBezierPathWith(view : UIView , tag : Int){
           let path = UIBezierPath(roundedRect:view.bounds,
                                   byRoundingCorners:[((tag == 1) ? .topRight : .bottomRight), ((tag == 1) ? .topLeft : .bottomLeft)],
                                   cornerRadii: CGSize(width: 10, height:  10))
           let maskLayer = CAShapeLayer()
           maskLayer.path = path.cgPath
           view.layer.mask = maskLayer
       }
    
}

