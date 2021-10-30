//
//  PrayerTableViewCell.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 03/10/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import UIKit
import FaveButton

protocol PrayerTableViewCellProtocol {
    func PrayerActionButtonCliked(index : Int,action : Int)
}

class PrayerTableViewCell: UITableViewCell,FaveButtonDelegate { //FaveButtonDelegate
    var degligatePrayerTableViewCell : PrayerTableViewCellProtocol!
    /// See More View
    @IBOutlet var discriptionTextView: UITextView!
    @IBOutlet weak var seeMoreView: UIView!
    @IBOutlet weak var seeLessLabel: UILabel!
    @IBOutlet weak var seeLessOrMoreBtn: UIButton!
    /// 1 view
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    /// 2 View
    @IBOutlet weak var prayerTitleLabel: UILabel!
    @IBOutlet weak var prayerDescriptionLabel: UILabel!
    /// 3 View
    @IBOutlet weak var prayedCountLabel: UILabel!
    @IBOutlet weak var praisedCountLabel: UILabel!
    @IBOutlet weak var prayingCountLabel: UILabel!
    /// Praying View
    @IBOutlet weak var prayerStatusBtnImg: UIImageView!
    @IBOutlet weak var prayerStatusBtnLabel: UILabel!
    @IBOutlet weak var prayingBtn: FaveButton!
    /// Answer Prayer View
    @IBOutlet weak var answerPrayerImg: UIImageView!
    @IBOutlet weak var answerPrayerLabel: UILabel!
    @IBOutlet weak var answerPrayerBtn: UIButton!
    @IBOutlet weak var sharePrayerImg: UIImageView!
    @IBOutlet weak var sharePrayerBtn: UIButton!
    @IBOutlet weak var shareCountLabel: UILabel!
    @IBOutlet weak var openPopUpBtn: UIButton!
    @IBOutlet weak var tabCountLbl: UILabel!
    @IBOutlet weak var hideShareView: UIView!
    @IBOutlet weak var hideAnswerView: UIView!
    @IBOutlet weak var hideTagView: UIView!
    /// Constraint Outlets
    @IBOutlet weak var descriptionConstraint: NSLayoutConstraint!
    @IBOutlet weak var seeMoreHeight: NSLayoutConstraint!
    @IBOutlet weak var spaceConctraint: NSLayoutConstraint!
    // My Prayer PopUp
    @IBOutlet weak var myeditViewbg: UIView!
    @IBOutlet weak var myeditView: UIView!
    @IBOutlet weak var myeditViewcorner: UIView!
    // My Request PopUp
    @IBOutlet weak var requesteditViewbg: UIView!
    @IBOutlet weak var requesteditView: UIView!
    @IBOutlet weak var requesteditViewcorner: UIView!
    @IBOutlet weak var prayingView: UIView!
    @IBOutlet weak var tagCountLbl: UILabel!
    @IBOutlet weak var answerdLabel : UILabel!
    
    var isSelfPrayer : Bool!
    var cellIndex = -1
    
    let imagesArray = [#imageLiteral(resourceName: "addPrayer_select_radio_button_Image"),#imageLiteral(resourceName: "yelloCircle")]
    var bubbleAnimationView: BubbleAnimationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prayingBtn.delegate = self
        setLayout()
        setupBubbleAnimationView()
        //overlayView.isHidden = true
        self.selectionStyle = .none
        self.prayingBtn?.setSelected(selected: false, animated: false)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setLayout() {
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
    }
    
    func loadData(data : NSDictionary, indexPath : Int, selectedPopUpIndex : Int, tableView : UITableView){
        var iseditselfprayer : Bool = true
        if let answered = data[ConstantMessage.kSetAnswered] as? String,answered == "1"{
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = ConstantMessage.kDateForamte
            if let dateTime = data[ConstantMessage.kAnsweredTime] as? String,dateTime.count > 0 {
                if (dateFormatter.date(from: data[ConstantMessage.kAnsweredTime] as! String) as NSDate?) != nil{
                    let tempTimeDate = dateFormatter.date(from: data[ConstantMessage.kAnsweredTime] as! String)! as NSDate
                               let localtime = supportingfuction.ChangeGmtTimeIntoLocal(date: tempTimeDate)
                    dateFormatter.dateFormat = ConstantMessage.kDateFormate2
                    self.answerdLabel.text = "\(ConstantMessage.kPrayerAnsweredOn) \(dateFormatter.string(from: localtime as Date))"
                }
            }
           
        }else{
             self.answerdLabel.text = ""
        }
        prayedCountLabel.text = data[ConstantMessage.kPrayedCount] as! String + " \(ConstantMessage.kPrayed.lowercased())"
        praisedCountLabel?.text = data[ConstantMessage.kPraisedCount] as! String + " \(ConstantMessage.kPraised)"
        prayingCountLabel?.text = "\(ApplicationDelegate.getPrayingCountinPrayerRequest(data: data))" + " \(ConstantMessage.kPraying)"
        nameLabel?.text = data[ConstantMessage.kSenderName] as? String
        dateLabel?.text = data[ConstantMessage.kCreatedOn] as? String
        prayerTitleLabel?.text = data[ConstantMessage.kTitle] as? String
        prayerDescriptionLabel?.text = data[ConstantMessage.kDescription] as? String
        discriptionTextView.text = data[ConstantMessage.kDescription] as? String
        if (((data.object(forKey: ConstantMessage.kUserID) != nil) && (data.object(forKey: ConstantMessage.kUserID) as! String == UserManager.shareManger.userID!)) && ( (data.object(forKey: ConstantMessage.kCopiedPrayer) != nil) && data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "0")) || (((data.object(forKey: ConstantMessage.kSenderUserID) != nil) && (data.object(forKey: ConstantMessage.kSenderUserID) as! String == UserManager.shareManger.userID!)) && ( (data.object(forKey: ConstantMessage.kCopiedPrayer) != nil) && data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "0"))
        {
            isSelfPrayer = true
            hideAnswerView.isHidden = true
            iseditselfprayer = true
        }else
        {
            isSelfPrayer = false
            hideAnswerView.isHidden = false
            iseditselfprayer = false
        }
        if ((data.object(forKey: ConstantMessage.kUserID) != nil) && (data.object(forKey: ConstantMessage.kUserID) as! String == UserManager.shareManger.userID!)) && ( (data.object(forKey: ConstantMessage.kCopiedPrayer) != nil) && data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "0")
        {
            hideShareView.isHidden = true
            hideTagView.isHidden = true
        }else if  (data.object(forKey: ConstantMessage.kUserID) != nil) && ((data.object(forKey: ConstantMessage.kCopiedPrayer) != nil) && data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1"){
            hideShareView.isHidden = true
            hideTagView.isHidden = true
        }else{
            hideShareView.isHidden = false
            hideTagView.isHidden = false
        }
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        
        var defaultImage : UIImage!
        if (data.object(forKey: ConstantMessage.kCopiedPrayer) != nil &&  data.object(forKey: ConstantMessage.kCopiedPrayer) as! String == "1")
        {
            defaultImage = #imageLiteral(resourceName: "groupDefault")
        }else
        {
            defaultImage = #imageLiteral(resourceName: "placeholder_profileImage")
        }

        if data[ConstantMessage.kSenderImage] != nil  &&
            data[ConstantMessage.kSenderImage] is String &&
            data[ConstantMessage.kSenderImage] as! String != ""
        {
            profileImage.setImageWith(NSURL(string:  data[ConstantMessage.kSenderImage] as! String)! as URL, placeholderImage: defaultImage)
        }else
        {
            profileImage.image = defaultImage
        }
        profileImage.layoutIfNeeded()
        let status = ApplicationDelegate.checkPrayerStatus(prayerData: data)
        if status == 1 || status == 3{
            self.beginAnimation(index : indexPath)
        }
        
        switch status {
        case 1:
            answerPrayerLabel.text = ConstantMessage.kAnsweredPrayer
            prayerStatusBtnImg.image = UIImage(named: ConstantMessage.kPrayerButtonImage)
            prayerStatusBtnLabel.text = ConstantMessage.kPray.lowercased()
            let visibleCell = tableView.visibleCells
            self.beginAnimation(index : indexPath)
            break
        case 2:
            answerPrayerLabel.text = ConstantMessage.kAnsweredPrayer
            prayerStatusBtnImg.image = UIImage(named: ConstantMessage.kPrayedButtonImage)
            prayerStatusBtnLabel.text = ConstantMessage.kPrayed.lowercased()
            
            break
        case 3:
            answerPrayerLabel.text = ConstantMessage.kNeedPrayerAgain
            prayerStatusBtnImg.image = UIImage(named: ConstantMessage.kPraiseButtonImage)
            prayerStatusBtnLabel.text = ConstantMessage.kPPraise
            self.beginAnimation(index : indexPath)
            break
        case 4:
            answerPrayerLabel.text = ConstantMessage.kNeedPrayerAgain
            prayerStatusBtnImg.image = UIImage(named: ConstantMessage.kPraisedButtonImage)
            prayerStatusBtnLabel.text = ConstantMessage.kPPraised
            break
        default:
            answerPrayerLabel.text = ConstantMessage.kAnsweredPrayer
            prayerStatusBtnImg.image = UIImage(named: ConstantMessage.kPrayerButtonImage)
            prayerStatusBtnLabel.text = ConstantMessage.kPray.lowercased()
            var focusedCell : PrayerTableViewCell
            let visibleCell = tableView.visibleCells
            self.beginAnimation(index : indexPath)
            for cell in visibleCell {
                focusedCell = cell as! PrayerTableViewCell
                if focusedCell.cellIndex == indexPath {}
            }
            break
        }
        
        myeditViewcorner?.layer.cornerRadius = 10.0
        myeditViewbg?.layer.cornerRadius = 10
        
        requesteditViewcorner?.layer.cornerRadius = 5.0
        requesteditViewbg?.layer.cornerRadius = 5
        
     
        
        if indexPath == selectedPopUpIndex
        {
            if iseditselfprayer
            {
                myeditView?.isHidden = false
            }else
            {
                requesteditView?.isHidden = false
            }
            
        }else
        {
            myeditView?.isHidden = true
            requesteditView?.isHidden = true
        }
        
        if selectedPopUpIndex != -1
        {
            if iseditselfprayer
            {
                myeditViewbg?.isHidden = false
                requesteditViewbg?.isHidden = true
            }else
            {
                requesteditViewbg?.isHidden = false
                myeditViewbg?.isHidden = true
            }
        }else
        {
            requesteditViewbg?.isHidden = true
            myeditViewbg?.isHidden = true
        }
        
        // manage height
        let  heightofdis = data[ConstantMessage.kHeight] as! CGFloat
        if heightofdis > 80
        {
            seeMoreHeight.constant = 20
            seeMoreView.isHidden = false
            spaceConctraint.constant  = 8
            if data[ConstantMessage.kShowfull] as! Bool
            {
                seeLessLabel.text = ConstantMessage.kSeeLess
                descriptionConstraint.constant  = heightofdis - 8
            }else
            {
                seeLessLabel.text = ConstantMessage.kSeeMore
                descriptionConstraint.constant  = 80.0 - 8
            }
        }else
        {
            spaceConctraint.constant  = -3
            seeMoreView.isHidden = true
            seeLessLabel.text = ""
            seeMoreHeight.constant = 0
            descriptionConstraint.constant  = heightofdis
        }
        
        // sharing count
        //Share count
        if let array = data.object(forKey: ConstantMessage.kAlreadyTagged) as? NSArray,array.count > 0{
            let invitationAccepted = (array[0] as? NSDictionary)?.value(forKey: ConstantMessage.kInvitationAccepted)
               shareCountLabel?.text = invitationAccepted as? String ?? "0"
         }else
         {
               shareCountLabel?.text = "0"
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
    }
    
    //MARK:- FaveButton Delegate
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]? {
        if faveButton == faveButton{
        }
        //return UIColor.purple.cgColor as? [DotColors]
        var color = [DotColors(first: UIColor(red: 253.0/255.0, green: 187.0/255.0, blue: 64.0/255.0, alpha: 1), second: UIColor(red: 253.0/255.0, green: 187.0/255.0, blue: 64.0/255.0, alpha: 1))]
        if prayerStatusBtnLabel.text == ConstantMessage.kPPraise || prayerStatusBtnLabel.text == ConstantMessage.kPPraised{
            color = [DotColors(first: UIColor(red: 253.0/255.0, green: 187.0/255.0, blue: 64.0/255.0, alpha: 1), second: UIColor(red: 253.0/255.0, green: 187.0/255.0, blue: 64.0/255.0, alpha: 1))]
        }else{
            color = [DotColors(first: UIColor(red: 160.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1), second: UIColor(red: 160.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1))]
        }
        return color
    }
    
    /// Description
    /// - Parameter sender: sender description
    @IBAction func prayerStart(_ sender: UIButton) {
        self.prayingBtn?.setSelected(selected: false, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: 1)
        }
    }
    
    func setupBubbleAnimationView() {
        bubbleAnimationView = BubbleAnimationView()
        bubbleAnimationView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(bubbleAnimationView)
        [bubbleAnimationView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: -50),
        bubbleAnimationView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
        bubbleAnimationView.bottomAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        bubbleAnimationView.heightAnchor.constraint(equalToConstant: 200)].forEach { ($0.isActive = true)
        }
        self.contentView.sendSubviewToBack(bubbleAnimationView)
    }
    
    func showBubbleAnimationBottonToTop() {
        let randomIndex1 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage1 = imagesArray[randomIndex1]
        let randomIndex2 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage2 = imagesArray[randomIndex2]
        let randomIndex3 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage3 = imagesArray[randomIndex3]
        let randomIndex4 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage4 = imagesArray[randomIndex4]
        let randomIndex5 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage5 = imagesArray[randomIndex5]
        let randomIndex6 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage6 = imagesArray[randomIndex6]
        let randomIndex7 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage7 = imagesArray[randomIndex7]
        let randomIndex8 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage8 = imagesArray[randomIndex8]
        let randomIndex9 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage9 = imagesArray[randomIndex9]
        let randomIndex10 = Int(arc4random_uniform(UInt32(imagesArray.count)))
        let randomImage10 = imagesArray[randomIndex10]

        bubbleAnimationView.animate(icon: randomImage1)
        bubbleAnimationView.animate(icon: randomImage2)
        bubbleAnimationView.animate(icon: randomImage3)
        bubbleAnimationView.animate(icon: randomImage4)
        bubbleAnimationView.animate(icon: randomImage5)
        bubbleAnimationView.animate(icon: randomImage6)
        bubbleAnimationView.animate(icon: randomImage7)
        bubbleAnimationView.animate(icon: randomImage8)
        bubbleAnimationView.animate(icon: randomImage9)
        bubbleAnimationView.animate(icon: randomImage10)
    }
    
    
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func shareBtnCliked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: 2)
    }
    
    @IBAction func tagBtnClicked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: 6)
    }
    
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func editPrayerPopUpMenuBtnCliked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: 3)
    }
    
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func seeMoreBtncliked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: 4)
    }
    
    /// Description
    ///
    /// - Parameter sender: sender description
    @IBAction func prayerAnswerBtnCliked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: 5)
    }
    
    /// Open My Prayer PopUp
    ///
    /// - Parameter sender: UIButton
    @IBAction func myPrayerPopUpBtnClicked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action:sender.tag)
    }
    
    /// Open My Prayer Request PopUp
    ///
    /// - Parameter sender: UIButton
    @IBAction func requestPrayerPopUpBtnClicked(_ sender: UIButton) {
        degligatePrayerTableViewCell.PrayerActionButtonCliked(index: self.tag, action: sender.tag)
    }
    
    func beginAnimation (index : Int) {
        UIView.animate(withDuration: 0.8, delay: 0, options:  [.repeat, .autoreverse], animations: {
           // UIView.setAnimationRepeatCount(3)
            self.prayingView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: {completion in
            self.prayingView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
}

