//
//  HelpViewController.swift
//  iPray
//
//  Created by zeba on 29/03/19.
//  Copyright © 2019 TrivialWorks. All rights reserved.
//

import UIKit
import WebKit

protocol HelpViewDelegate {
    func isHelpButtonShow()
}
class HelpViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var chechUncheckBtn: UIButton!
    @IBOutlet weak var lablHeaer: UILabel!
    let URL = iPrayConsant.kPrayerRequestrules
    var isUpdate = false
    // MARK: - Variables
    var delegate : HelpViewDelegate!
    //Add Prayer
    var titleArray = [ConstantMessage.kSSave,ConstantMessage.kTAG,ConstantMessage.kSHARE,"UPDATE"]
    var descriptionArray = ["Saves this prayer in your “My Prayers” bubble.","Tag a prayer when you want to pray for someone else.","Share your prayer when you want people to pray for you.","Adjusts the prayer reminder setting someone set for you when they asked you to pray for them."]
    var detaildDecscriptionArray = ["Saves this prayer in your “My Prayers” bubble.\n\nIf you have not shared or tagged the prayer, this prayer is completely private to just you.","Tag a prayer when you want to pray for someone else.\n\nWhen you tag someone, if they accept your prayer you wrote for them, iPray creates a prayer in their “My Prayers” bubble.  You then get a yellow bubble with their name on it, with their prayers, as if they had written and shared this prayer request with you.\nEven if they don’t accept the prayer you wrote for them, a copy of your prayer for them will be in your “My Prayers” bubble.","Share your prayer when you want people to pray for you.\n\nIf those people accept your prayer request, they get a yellow bubble on their iPray with your name on it where your prayer requests are stored and they can pray for you."]
    // TagRequest
    var tagTitleArray = ["Accept","Decline"]
    var tagDescriptionArray = ["Someone has created a prayer for you!  Click “Accept” to load this prayer to your My Prayers as if you had written it. This also auto-shares your prayer with the person who created it for you so that they can faithfully pray for you.","Select decline if you do not want to accept this prayer created for you."]
    var tagDetaildDecscriptionArray = ["Someone has created a prayer for you!  Click “Accept” to load this prayer to your My Prayers as if you had written it. This also auto-shares your prayer with the person who created it for you so that they can faithfully pray for you.\n\nFYI - you can edit this prayer created on your behalf in your “My Prayers” bubble in your iPray. If you would like to pray for someone else the same way, you too can select the “Tag” option to “Tag” someone you want to pray for. If you would like more people than just your friend to pray for you, select the “Share” button on your prayer.",""]
    //Group Prayer
    var groupTitleArray = [ConstantMessage.kPray]
    var groupDescriptionArray = ["Clicking on the pray button will not only increase the count of the prayer but will simultaneously copy the prayer into your “My Prayers”. You can always remove the prayer later."]
    var isExpand = false
    var selectedIndex = -1
    //Add Prayer = 1
    // TagRequest = 2
    //Group Prayer = 3
    var pageType = 1
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableView.automaticDimension
        showCheckBtn()
        self.setTextView()
        self.lablHeaer.text = (self.pageType == 1000) ? ConstantMessage.kPrayerRequests  : (self.pageType == 2000) ? ConstantMessage.kGroupPrayers : ConstantMessage.kiPrayButtonExplanations
    }
    
    // MARK: - Button Action
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.delegate.isHelpButtonShow()
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func gotItBtnClicked(_ sender: UIButton) {
        if pageType == 1 {
            if let isAddPrayrCheck =  DefaultsManager.share.isShowHelp,isAddPrayrCheck {
                DefaultsManager.share.isShowHelp = false
            }else{
                DefaultsManager.share.isShowHelp = true
            }
        }else if pageType == 2 {
            if let isTaggPrayrCheck = DefaultsManager.share.isShowTagHelp,isTaggPrayrCheck {
                DefaultsManager.share.isShowTagHelp = false
            }else{
                DefaultsManager.share.isShowTagHelp = true
            }
        }else if pageType == 1000{
        }else{
            if let isGroupPrayrCheck = DefaultsManager.share.isShowGroupHelp ,isGroupPrayrCheck {
                DefaultsManager.share.isShowGroupHelp = false
            }else{
                DefaultsManager.share.isShowGroupHelp = true
            }
        }
        UserDefaults.standard.synchronize()
        showCheckBtn()
    }
    
    @IBAction func seeMoreOrLessBtnClicked(_ sender: UIButton) {
        let pointInTable: CGPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        let cellIndexPath = self.tableView.indexPathForRow(at: pointInTable)
        selectedIndex = cellIndexPath!.row
        if isExpand {
            isExpand = false
        }else{
            isExpand = true
        }
        self.tableView.reloadData()
    }
}

extension HelpViewController {
    func showCheckBtn(){
       if pageType == 1 {
           if let isAddPrayrCheck = DefaultsManager.share.isShowHelp ,isAddPrayrCheck {
            chechUncheckBtn.setImage(UIImage(named: ConstantMessage.kHelpCheck), for: .normal)
           }else{
            chechUncheckBtn.setImage(UIImage(named: ConstantMessage.kHelpUnCheck), for: .normal)
           }
       }else if pageType == 2 {
           if let isTaggPrayrCheck = DefaultsManager.share.isShowTagHelp ,isTaggPrayrCheck {
               chechUncheckBtn.setImage(UIImage(named: ConstantMessage.kHelpCheck), for: .normal)
           }else{
               chechUncheckBtn.setImage(UIImage(named: ConstantMessage.kHelpUnCheck), for: .normal)
           }
       }else if pageType == 1000{
           chechUncheckBtn.isHidden = true
       }else{
           if let isGroupPrayrCheck = DefaultsManager.share.isShowGroupHelp ,isGroupPrayrCheck {
               chechUncheckBtn.setImage(UIImage(named: ConstantMessage.kHelpCheck), for: .normal)
           }else{
               chechUncheckBtn.setImage(UIImage(named: ConstantMessage.kHelpUnCheck), for: .normal)
           }
       }
    }
    func setTextView() {
        if self.pageType == 1000 || self.pageType == 2000{
            let textView = self.view.viewWithTag(1000) as! UITextView
            textView.isHidden = false
            textView.isEditable = false
            textView.isSelectable = true
            textView.delegate = self
           let string = ( self.pageType == 1000) ? self.returnPrayerRequesHelp() : self.returnGroupPrayerHelp()
           let paragraph = NSMutableParagraphStyle()
           paragraph.alignment = .left
           let attributeString = NSMutableAttributedString(string: string, attributes: [.paragraphStyle: paragraph])
           let textRange = attributeString.mutableString.range(of: "here.")
           attributeString.addAttribute(NSAttributedString.Key.link, value: self.URL, range: textRange)
           attributeString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Arial", size:15.0) as Any , range: attributeString.mutableString.range(of:string))
           attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: attributeString.mutableString.range(of:string))
           textView.attributedText = attributeString
        }
    }
    func returnPrayerRequesHelp()->String{
           return "Group members share their individual prayer requests or praises to their iPray group.\n\nGroup owners or Admins get to approve all individual prayer requests for appropriateness.\n\n“+” Request prayerClick this button, to request prayer or share a praise to members of this group. Your Group Admin will approve or decline your individual prayer request. Read Prayer Request rules here.\n\n“Pray” Click the Pray button when you want to indicate you have prayed for the individual who has made the request.\n\n“Adopt” Click the Adopt button to commit to pray for the individual who requested prayer. According to the prayer reminder set (you can modify it) you will be reminded to pray for this person. You will find their prayer(s) in the Yellow “Friend” Bubble with their name on it on your iPray Homescreen\n\n.Up to three group members can adopt a prayer request. Why did we create the limit? We designed this functionality to maximize prayer coverage for all members of a group. Especially larger groups. Too many organizations too many prayer requests and too few people helping faithfully pray!\n\nClick the Group Avatar at the top of the Group Page to invite additional members to your group. Admins can invite other members to become Admins the same way."
       }
       
       func returnGroupPrayerHelp()->String{
           return "Group leaders or “Admins” can share group prayers or praises to their group.\n\n“+” Add Group Prayer\nOnly group Admins have this button. They click this button to create and add a group prayer for the group.\n\nThis is a popular way that group leaders share corporate prayers or praise for group activity.\n\n “Pray” Click the Pray button when you have joined your Group Admin in praying for the group prayer.\n\n“Tag” Click the Tag button when you feel this prayer would be appreciated by and seems written for someone you know.\n\n“Share” Click the Share button when you feel this prayer applies to you and you would like people to pray this prayer for you.\n\n“Copy” (the two ovals icon) Click the Copy button when you want to save this prayer in your My Prayers as a prayer you don’t want to forget and want to faithfully pray over.\n\nClick the Group Avatar at the top of the Group Page to invite additional members to your group. Admins can invite other members to become Admins the same way."
       }
}

// MARK: - TableView Delegate
extension HelpViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch pageType {
        case 1:return (self.isUpdate) ? 4 : 3
        case 2:return 2
        case 3:return 1
        case 1000:return 1
        default:return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell!
        switch pageType {
        case 1:
            cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kSaveCell)
            let titleLbl = cell.viewWithTag(11) as! UILabel
            let textLbl = cell.viewWithTag(12) as! UILabel
            let seeMoreLessLbl = cell.viewWithTag(13) as! UILabel
            
            titleLbl.text = titleArray[indexPath.row]
            if indexPath.row == selectedIndex && isExpand {
                textLbl.text = detaildDecscriptionArray[indexPath.row]
                seeMoreLessLbl.text = ConstantMessage.kSeeLess
            }else{
                textLbl.text = descriptionArray[indexPath.row]
                if indexPath.row == 3 {
                    seeMoreLessLbl.text = ""
                }
            }
            if indexPath.row == 0 {
                titleLbl.textColor = UIColor(red: 240.0/255.0, green: 193.0/255.0, blue: 93.0/255.0, alpha: 1.0)
            }else if indexPath.row == 1 {
                titleLbl.textColor = UIColor(red: 106.0/255.0, green: 70.0/255.0, blue: 123.0/255.0, alpha: 1.0)
            }else{
                titleLbl.textColor = UIColor(red: 234.0/255.0, green: 79.0/255.0, blue: 104.0/255.0, alpha: 1.0)
            }
        case 2:
            cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kSaveCell)
             let titleLbl = cell.viewWithTag(11) as! UILabel
             let textLbl = cell.viewWithTag(12) as! UILabel
             let seeMoreLessLbl = cell.viewWithTag(13) as! UILabel
             let seeMoreView = cell.viewWithTag(14)
             
             titleLbl.text = tagTitleArray[indexPath.row]
            
             if indexPath.row == 0 {
                 seeMoreView?.isHidden = false
                 titleLbl.textColor = UIColor(red: 26.0/255.0, green: 177.0/255.0, blue: 94.0/255.0, alpha: 1)
                 if indexPath.row == selectedIndex && isExpand {
                     textLbl.text = tagDetaildDecscriptionArray[indexPath.row]
                     seeMoreLessLbl.text = ConstantMessage.kSeeLess
                 }else{
                     textLbl.text = tagDescriptionArray[indexPath.row]
                    seeMoreLessLbl.text = ConstantMessage.kSeeMore
                 }
             }else{
                 seeMoreView?.isHidden = true
                 textLbl.text = tagDescriptionArray[indexPath.row]
                 titleLbl.textColor = UIColor.red
             }
        case 1000:
            cell = self.tableView.dequeueReusableCell(withIdentifier: ConstantMessage.kSaveCell)
            cell.textLabel?.text = ""
        default:
            cell = self.tableView.dequeueReusableCell(withIdentifier:ConstantMessage.kSaveCell)
            let titleLbl = cell.viewWithTag(11) as! UILabel
            let textLbl = cell.viewWithTag(12) as! UILabel
            let seeMoreView = cell.viewWithTag(14)
            //let seeMoreLessLbl = cell.viewWithTag(13) as! UILabel
            
            seeMoreView?.isHidden = true
            titleLbl.text = groupTitleArray[indexPath.row]
            textLbl.text = groupDescriptionArray[indexPath.row]
            titleLbl.textColor = UIColor(red: 159.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1.0)
        }
        return cell
    }
}

//NEW CR AP20 2020
extension HelpViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if (URL.absoluteString ==  self.URL) {
            let storyboard = UIStoryboard(name: ConstantMessage.kMain, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: iPrayIdentifier.kUKWebViewViewControllerI) as! UKWebViewViewControllerI
            vc.URL = self.URL
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return false
    }
       
   func textViewDidChangeSelection(_ textView: UITextView) {
       if(!NSEqualRanges(textView.selectedRange, NSMakeRange(0, 0))) {
            textView.selectedRange = NSMakeRange(0, 0);
        }
    }
}



