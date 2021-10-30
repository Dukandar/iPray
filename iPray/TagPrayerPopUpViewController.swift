//
//  TagPrayerPopUpViewController.swift
//  iPray
//
//  Created by zeba on 30/04/19.
//  Copyright © 2019 TrivialWorks. All rights reserved.
//

import UIKit

protocol TagPrayerPopUpDelegate {
    func tagPopUpBtnClicked(actionType : Int, data : NSDictionary,isTagging : Bool)
}
class TagPrayerPopUpViewController: UIViewController {
    // MARK: - Outlet
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var iPrayHeadingLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    let kiPrayTagging = ConstantMessage.kiPrayTagging
    let kiPraySharing = ConstantMessage.kiPraySharing
    // MARK: - Variables
    var delegate : TagPrayerPopUpDelegate!
    var dataDict = NSDictionary()
    var type = ""
    var isTag = false
    var isIprayContact = false
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        popView.layer.cornerRadius = 20
        if type == ConstantMessage.ktag{
            iPrayHeadingLbl.text = self.kiPrayTagging
            detailsLbl.text = ConstantMessage.kWhoThisPrayer
        }else if type == ConstantMessage.kshare{
            iPrayHeadingLbl.text = self.kiPraySharing
            detailsLbl.text = ConstantMessage.kAskSomeoneToPrayYou
        }
    }
    
    // MARK: - Button Action
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.removeFromParent()
        self.view.removeFromSuperview()
        self.delegate.tagPopUpBtnClicked(actionType: 1000, data: NSDictionary(),isTagging: false)
    }
    
    @IBAction func popUpBtnAction(_ sender: UIButton) {
        //Issue fixed on 15th April 2020
        if sender.tag == 3 {
            delegate.tagPopUpBtnClicked(actionType: 3, data: dataDict,isTagging: (type == ConstantMessage.ktag) ? true : false)
              self.view.removeFromSuperview()
        }else{
            let shareiPray=self.storyboard?.instantiateViewController(withIdentifier: iPrayIdentifier.kSharePrayerViewController) as! SharePrayerViewController
            shareiPray.delegate = self
            
            if (self.navigationController?.viewControllers.count)! > 0{
                let viewControllers = self.navigationController?.viewControllers
                if viewControllers!.count > 1{
                    for item in viewControllers![1].children{
                        if item is AddPrayerViewController{
                             shareiPray.vctr = item
                        }
                    }
                }else if viewControllers!.count > 0 {
                    for item in viewControllers![0].children{
                        if item is AddPrayerViewController{
                           shareiPray.vctr = item
                        }
                    }
                }
            }
            var prayerID = ""
            if let _ =  dataDict.object(forKey: ConstantMessage.kPrayerID){
                prayerID = dataDict.object(forKey: ConstantMessage.kPrayerID) as! String
            }else if let _ =  dataDict.object(forKey: ConstantMessage.kGroupPrayerID){
                prayerID = dataDict.object(forKey: ConstantMessage.kGroupPrayerID) as! String
            }
            shareiPray.SharePrayerID = prayerID
            var title = ""
            if let _ =  dataDict.object(forKey: ConstantMessage.kTitle){
                title = dataDict.object(forKey: ConstantMessage.kTitle) as! String
            }else if (dataDict.object(forKey: ConstantMessage.kGroupPrayerTitle) != nil){
                title = dataDict.object(forKey: ConstantMessage.kGroupPrayerTitle) as! String
            }
              shareiPray.SharePrayerTitle = title
              shareiPray.prayingCount = ApplicationDelegate.getPrayingCount(data: dataDict)
              shareiPray.isTag = isTag
              shareiPray.isIprayContact = isIprayContact
              if isTag {
                if dataDict.object(forKey: ConstantMessage.kAlreadyTagged) != nil
                  {
                      shareiPray.alreadyShareContactArrayList = (dataDict.object(forKey: ConstantMessage.kAlreadyTagged) as! NSArray).mutableCopy() as! NSMutableArray
                  }
              }else{
                if dataDict.object(forKey: ConstantMessage.kAlreadyShared) != nil
                  {
                      shareiPray.alreadyShareContactArrayList = (dataDict.object(forKey: ConstantMessage.kAlreadyShared) as! NSArray).mutableCopy() as! NSMutableArray
                  }
              }
              shareiPray.modalPresentationStyle = .fullScreen
              self.present(shareiPray, animated: true, completion: nil)
        }
    }
}

extension TagPrayerPopUpViewController : SharePrayerViewControllerProtocol {
    
    func cancelBtnTapped(){
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    
    func shareTagBtnTapped(){
      self.removeFromParent()
      self.view.removeFromSuperview()
    }
    
}
