//
//  GroupPrayerTableViewCell.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 03/10/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit

protocol GroupPrayerTableViewCellProtocol {
    func PrayerActionButtonCliked(index : Int,action : Int)
    /*
     1 : See More
     2 : open pop up
     3 : Adoption btn
     4 : Copy prayer
     5 : remove publishing
     6 : Publish
     7 : share
     POP Action
     -11 : Update
     -12 : Ans
     -13 : Remove self prayer
     */
}

class GroupPrayerTableViewCell: UITableViewCell {
    
    var delegate : GroupPrayerTableViewCellProtocol!
    /// See More View
    @IBOutlet weak var seeMoreView: UIView!
    @IBOutlet weak var seeLessLabel: UILabel!
    @IBOutlet weak var seeLessOrMoreBtn: UIButton!
    @IBOutlet var discriptionTextView: UITextView!
    /// Constraint Outlets
    @IBOutlet weak var descriptionConstraint: NSLayoutConstraint!
    @IBOutlet weak var seeMoreHeight: NSLayoutConstraint!
    @IBOutlet weak var spaceConctraint: NSLayoutConstraint!
    @IBOutlet var answerLable: UILabel!
    /// 1 view
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    /// 2 View
    @IBOutlet weak var prayerTitleLabel: UILabel!
    @IBOutlet weak var prayerDescriptionLabel: UILabel!
    /// My prayer view
    @IBOutlet var selfBgView: UIView!
    @IBOutlet weak var popUpBgView: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var prayedCountLabel: UILabel!
    @IBOutlet weak var praisedCountLabel: UILabel!
    @IBOutlet weak var prayingCountLabel: UILabel!
    @IBOutlet var threePoPupView: UIButton!
    @IBOutlet var threeDotPopUp: NSLayoutConstraint!
    /// Adopted view
    @IBOutlet var adoptedBgView: UIView!
    @IBOutlet weak var adoptLabel: UILabel!
    @IBOutlet weak var adoptionImage: UIImageView!
    @IBOutlet var adoptedBtnView: UIView!
    @IBOutlet var removeAdoptBtn: UIButton!
    @IBOutlet var adoptionCount: UILabel!
    @IBOutlet var sharableBeyondGroup: UIView!
    /// ask for publish view
    @IBOutlet var publishBgView: UIView!
    /// member book prayer
    @IBOutlet var copyBgView: UIView!
    @IBOutlet var copyView: UIView!
    @IBOutlet var copyCount: UILabel!
    @IBOutlet var copyLable: UILabel!
    @IBOutlet var copyImageConstraint: NSLayoutConstraint!
    /// Group Prayer
    @IBOutlet weak var prayBgView: UIView!
    @IBOutlet weak var tagBgView: UIView!
    @IBOutlet weak var shareBgView: UIView!
    @IBOutlet weak var copyImgView: UIImageView!
    @IBOutlet weak var adoptPrayerView: UIView!
    @IBOutlet weak var adoptLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var prayCountLbl: UILabel!
    @IBOutlet weak var tagCountLbl: UILabel!
    @IBOutlet weak var shareCountLbl: UILabel!
    @IBOutlet weak var prayLbl: UILabel!
    @IBOutlet weak var prayImgView: UIImageView!
    @IBOutlet weak var adoptPrayImgView: UIImageView!
    @IBOutlet weak var adoptPrayCountLbl: UILabel!
    @IBOutlet weak var adoptPrayLbl: UILabel!
    @IBOutlet weak var answerdLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //overlayView.isHidden = true
        prayBgView.layer.cornerRadius = prayBgView.frame.height / 2
        tagBgView.layer.cornerRadius = tagBgView.frame.height / 2
        shareBgView.layer.cornerRadius = shareBgView.frame.height / 2
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadData(data : NSDictionary, indexPath : Int, selectedPopUpIndex : Int,isPrayerWall : Bool,isGroupAdmin : Bool){
        // comman view in all cell
        nameLabel?.text = (data[ConstantMessage.kCreatorName] as! String)
        dateLabel?.text = (data[ConstantMessage.kCreatedOn] as! String)
        prayerTitleLabel?.text = (data[ConstantMessage.kGroupPrayerTitle] as! String)
        prayerDescriptionLabel?.text = (data[ConstantMessage.kGroupPrayerDescription] as! String)
        discriptionTextView.text = (data[ConstantMessage.kGroupPrayerDescription] as! String)
        if data[ConstantMessage.kCreatorImage] != nil  &&
            data[ConstantMessage.kCreatorImage] is String &&
            data[ConstantMessage.kCreatorImage] as! String != ""
        {
            profileImage.setImageWith(NSURL(string:  data[ConstantMessage.kCreatorImage] as! String)! as URL, placeholderImage: UIImage(named: ConstantMessage.kPlaceholderProfileImage))
        }else
        {
            profileImage.image = UIImage(named: ConstantMessage.kPlaceholderProfileImage)
        }
         var celltype : Int!
        /*
         celltype
         1 :admin book prayer // self view now copy view with 3 dot
         2 :ask for publish view // publish view
         3 :member book prayer // copy view
         4 :Adopt view without remove // adoptview
         */
            if isPrayerWall
            {
                if isGroupAdmin && data[ConstantMessage.kIsPublished] as! String == "0"
                {
                     //  2 :ask for publish view
                     celltype = 2
                }else
                {
                    //  4 :Adopt view
                    celltype = 4
                }
            }else
            {
                if isGroupAdmin
                {
                    //   1 :admin book prayer
                      celltype = 1
                }else
                {
                    // 3 :member book prayer
                      celltype = 3
                }
            }
        profileImage.layoutIfNeeded()
        /// Cell wise conditions
        switch celltype {
        case 1:
            // My admin book prayer
            /*
            // this is used in self view to display the data but now only copy feature is thre so self view is not used I used copied view here in case 1
             // eariler copied view is only used in case 3 only
             
            praisedCountLabel?.text = data["praisedCount"] as! String! + " praised"
            prayedCountLabel.text = data[ConstantMessage.kDelay] as! String! + " prayed"
            prayingCountLabel?.text =  data["prayingCount"] as! String!  + " praying"
            */
            if data[ConstantMessage.kIsAnswered] as! String == "0"
            {
                answerLable.text = ConstantMessage.kAnsweredPrayer
            }else
            {
                answerLable.text = ConstantMessage.kNeedPrayerAgain
            }
            
            if indexPath == selectedPopUpIndex
            {
                popUpView.isHidden = false
            }else
            {
                popUpView.isHidden = true
            }
            
            if selectedPopUpIndex != -1
            {
                popUpBgView.isHidden = false
            }else
            {
                popUpBgView.isHidden = true
            }
            
            if  data[ConstantMessage.kIsCopied] as! String == "0"
            {
                copyLable.text = ConstantMessage.kMyPrayers
                copyImgView.image = UIImage(named: ConstantMessage.kGroupCopy)
                copyView.backgroundColor = UIColor(red: 160.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
                copyImageConstraint.constant = 22
                copyLable.textAlignment = .left
            }else
            {
                copyImgView.image = UIImage(named: ConstantMessage.kGroupCopied)
                copyLable.textAlignment = .center
                copyLable.text = ConstantMessage.kCCopiedPrayer
                copyView.backgroundColor = UIColor(red: 160.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 0.5)
                copyImageConstraint.constant = 0
            }
            
            if data[ConstantMessage.kIsShareble] != nil && data[ConstantMessage.kIsShareble] as! String == "1"
            {
                sharableBeyondGroup.isHidden = false
            }else
            {
                sharableBeyondGroup.isHidden = true
            }
            copyCount.text = data[ConstantMessage.kCopiedCount] as? String
            threeDotPopUp.constant = 46
            threePoPupView.isHidden = false
            selfBgView.isHidden = true
            adoptedBgView.isHidden = true
            publishBgView.isHidden = true
            copyBgView.isHidden = false
            break
        case 2:
            /// ask for publish view
            popUpBgView.isHidden = true
            selfBgView.isHidden = true
            adoptedBgView.isHidden = true
            publishBgView.isHidden = false
            copyBgView.isHidden = true
            break
        case 3:
            /// member book prayer
            if  data[ConstantMessage.kIsCopied] as! String == "0"
            {
                copyLable.text = ConstantMessage.kMyPrayers
                copyImgView.image = UIImage(named: ConstantMessage.kGroupCopy)
                copyView.backgroundColor = UIColor(red: 160.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
                copyImageConstraint.constant = 22
                copyLable.textAlignment = .left
            }else
            {
                copyLable.textAlignment = .center
                copyLable.text = ConstantMessage.kCCopiedPrayer
                copyImgView.image = UIImage(named: ConstantMessage.kGroupCopied)
                copyView.backgroundColor = UIColor(red: 160.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 0.5)
                copyImageConstraint.constant = 0
            }
            if data[ConstantMessage.kIsShareble] != nil && data[ConstantMessage.kIsShareble] as! String == "1"
            {
                 sharableBeyondGroup.isHidden = false
            }else
            {
               sharableBeyondGroup.isHidden = true
            }
            copyCount.text = (data[ConstantMessage.kCopiedCount] as! String)
            threeDotPopUp.constant = 0
            popUpBgView.isHidden = true
            selfBgView.isHidden = true
            adoptedBgView.isHidden = true
            publishBgView.isHidden = true
            copyBgView.isHidden = false
            break
        default: /// Adoption view
            adoptedBgView.isHidden = false
            selfBgView.isHidden = true
            publishBgView.isHidden = true
            copyBgView.isHidden = true
            popUpBgView.isHidden = true
            
            if data[ConstantMessage.kIsAdopted] as! String == "0"
            {
                adoptLabel.text = ConstantMessage.kAdopt
                adoptedBtnView.backgroundColor = UIColor(red: 234.0/255.0, green: 79.0/255.0, blue: 104.0/255.0, alpha: 1)
                adoptedBtnView.isUserInteractionEnabled = true
            }else
            {
                adoptLabel.text = ConstantMessage.kAdopted
                adoptedBtnView.backgroundColor =  UIColor(red: 234.0/255.0, green: 79.0/255.0, blue: 104.0/255.0, alpha: 0.5)
                adoptedBtnView.isUserInteractionEnabled = false
            }
            
            if isGroupAdmin
            {
                removeAdoptBtn.isHidden = false
            }else
            {
                removeAdoptBtn.isHidden = true
            }
            
            /// Show adoption counts
            if data[ConstantMessage.kAdoptedCount] as! String == "0"
            {
                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption3")
//                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption0")
                adoptionCount.text = "3 \(ConstantMessage.kAdoptions) to go"
            }else if data[ConstantMessage.kAdoptedCount] as! String == "1"
            {
                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption2")
//                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption1")
                adoptionCount.text = "2 \(ConstantMessage.kAdoptions) to go"
            }else if data[ConstantMessage.kAdoptedCount] as! String == "2"
            {
                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption1")
//                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption2")
                adoptionCount.text = "1 \(ConstantMessage.kAdoptions) to go"
            }else
            {
                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption0")
//                adoptionImage.image = #imageLiteral(resourceName: "prayerAdoption3")
                adoptionCount.text = ConstantMessage.kFullyAdopted
                adoptedBtnView.backgroundColor = UIColor(red: 234.0/255.0, green: 79.0/255.0, blue: 104.0/255.0, alpha: 0.5)
                adoptedBtnView.isUserInteractionEnabled = false
            }
            break
        }
        /// manage height
        let  heightofdis = data[ConstantMessage.kHeight] as! CGFloat
        //let  heightofdis =  CGFloat(20.0) //data["height"] as! CGFloat
        if heightofdis > 80
        {
            seeMoreHeight.constant = 20
            seeMoreView.isHidden = false
            spaceConctraint.constant  = 22
            if data[ConstantMessage.kShowfull] as! Bool
            {
                seeLessLabel.text = ConstantMessage.kSeeLess
                descriptionConstraint.constant  = heightofdis - 16
            }else
            {
                seeLessLabel.text = ConstantMessage.kSeeMore
                descriptionConstraint.constant  = 80.0 - 16
            }
        }else
        {
            spaceConctraint.constant  = 10
            seeMoreView.isHidden = true
            seeLessLabel.text = ""
            seeMoreHeight.constant = 0
            descriptionConstraint.constant  = heightofdis
        }
        
        // sharing count
        if data.object(forKey: ConstantMessage.kAlreadyShared) != nil  &&
            (data.object(forKey: ConstantMessage.kAlreadyShared) is NSArray) &&
            (data.object(forKey: ConstantMessage.kAlreadyShared) as! NSArray).count != 0
        {
            shareCountLbl?.text = "\((data.object(forKey: ConstantMessage.kAlreadyShared) as! NSArray).count)"
        }else
        {
            shareCountLbl?.text = "0"
        }
        
        // tag count
        if data.object(forKey: ConstantMessage.kAlreadyTagged) != nil  &&
            (data.object(forKey: ConstantMessage.kAlreadyTagged) is NSArray) &&
            (data.object(forKey: ConstantMessage.kAlreadyTagged) as! NSArray).count != 0
        {
            tagCountLbl?.text = "\((data.object(forKey: ConstantMessage.kAlreadyTagged) as! NSArray).count)"
        }else
        {
            tagCountLbl?.text = "0"
        }
        
        prayCountLbl.text = (data[ConstantMessage.kPrayedCount] as! String)
        adoptPrayCountLbl.text = (data[ConstantMessage.kPrayedCount] as! String)
        let status = (data[ConstantMessage.kStatus] as! String)
        
        if data[ConstantMessage.kIsAnswered] as! String == "0"
        {
            self.answerdLabel.text = ""
            switch status {
            case "0":
                
                prayLbl.text = ConstantMessage.kPrayed
                prayImgView.image = UIImage(named: ConstantMessage.kPrayedButtonImage)
                adoptPrayLbl.text = ConstantMessage.kPrayed
                adoptPrayImgView.image = UIImage(named: ConstantMessage.kPrayedButtonImage)
                break
            case "1":
                prayLbl.text = ConstantMessage.kPray
                prayImgView.image = UIImage(named: ConstantMessage.kPrayerButtonImage)
                adoptPrayLbl.text = ConstantMessage.kPray
                adoptPrayImgView.image = UIImage(named: ConstantMessage.kPrayerButtonImage)
                break
            default:
                prayImgView.image = UIImage(named: ConstantMessage.kPrayerButtonImage)
                prayLbl.text = ConstantMessage.kPray
                adoptPrayLbl.text = ConstantMessage.kPray
                adoptPrayImgView.image = UIImage(named: ConstantMessage.kPrayerButtonImage)
                break
            }
        }else if data[ConstantMessage.kIsAnswered] as! String == "1"{
            if (data[ConstantMessage.kStatus] as! String) == "4" {
                  prayImgView.image = UIImage(named: ConstantMessage.kPraisedButtonImage)
                  prayLbl.text = ConstantMessage.kPPraised
                  adoptPrayLbl.text = ConstantMessage.kPPraised
                  adoptPrayImgView.image = UIImage(named: ConstantMessage.kPraisedButtonImage)
               }else{
                  prayImgView.image = UIImage(named: ConstantMessage.kPraiseButtonImage)
                  prayLbl.text = ConstantMessage.kPPraise
                  adoptPrayLbl.text = ConstantMessage.kPPraise
                  adoptPrayImgView.image = UIImage(named: ConstantMessage.kPraiseButtonImage)
               }
             let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = ConstantMessage.kDateForamte
               if let dateTime = data[ConstantMessage.kAnsweredTime] as? String,dateTime.count > 0 {
                if let date  = dateFormatter.date(from: data[ConstantMessage.kAnsweredTime] as! String) as NSDate?{
                    let tempTimeDate = dateFormatter.date(from: data[ConstantMessage.kAnsweredTime] as! String)! as NSDate
                     let localtime = supportingfuction.ChangeGmtTimeIntoLocal(date: tempTimeDate)
                    dateFormatter.dateFormat = ConstantMessage.kDateFormate2
                    self.answerdLabel.text = "\(ConstantMessage.kPrayerAnsweredOn) \(dateFormatter.string(from: localtime as Date))"
                }
               }else{
                 self.answerdLabel.text = ""
            }
        }
    }
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func openpopUpMenuBtnCliked(_ sender: UIButton) {
        delegate.PrayerActionButtonCliked(index: self.tag, action: 2)
    }
    
    /// Open My Prayer PopUp
    ///
    /// - Parameter sender: UIButton
    @IBAction func myPrayerPopUpActionBtnClicked(_ sender: UIButton) {
        delegate.PrayerActionButtonCliked(index: self.tag, action:sender.tag)
    }
    
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func adoptBtnCliked(_ sender: UIButton) {
        delegate.PrayerActionButtonCliked(index: self.tag, action: 3)
    }
    
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func seeMoreBtncliked(_ sender: UIButton) {
        delegate.PrayerActionButtonCliked(index: self.tag, action: 1)
    }
    
    @IBAction func copyBtncliked(sender: AnyObject) {
         delegate.PrayerActionButtonCliked(index: self.tag, action: 4)
    }
    
    @IBAction func removeRequestPrayer(sender: AnyObject) {
         delegate.PrayerActionButtonCliked(index: self.tag, action: 5)
    }
    
    @IBAction func publishRequestPrayer(sender: AnyObject) {
      delegate.PrayerActionButtonCliked(index: self.tag, action: 6)
    }
    
    @IBAction func sharePrayer(_ sender: UIButton) {
        if sender.tag == 1 {
        }else if sender.tag == 2 {
             self.delegate.PrayerActionButtonCliked(index: self.tag, action: 7)
        }else if sender.tag == 3 {
             self.delegate.PrayerActionButtonCliked(index: self.tag, action: 8)
        }else{
             self.delegate.PrayerActionButtonCliked(index: self.tag, action: 8)
        }
    }
    
    @IBAction func prayBtnClicked(_ sender: UIButton) {
        delegate.PrayerActionButtonCliked(index: self.tag, action: 9)
    }
}

