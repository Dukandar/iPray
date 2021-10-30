//
//  BubbleCollectionViewCell.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 06/02/18.
//  Copyright © 2018 TrivialWorks. All rights reserved.
//

import UIKit
protocol BubblesUIviewDelegate {
    func didSelectBubble(at: NSInteger)
}
class BubbleCollectionViewCell: UICollectionViewCell {
    
    //MARK:- Outlet & Variables
    @IBOutlet var baseView: UIView!
    @IBOutlet var circuleBubble: UIView!
    @IBOutlet var bubbleName: UILabel!
    @IBOutlet var notificationCount: UILabel!
    @IBOutlet var totalCount: UILabel!
    @IBOutlet var totalBubbleCountConstraint: NSLayoutConstraint!
    @IBOutlet var profileImage : UIImageView!
    let motionSpeed : Int = 6
    var delegate : BubblesUIviewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK:- Make Circle
    func makeCircle(bubbleData : UserBubble,tag : Int)
    {
       // self.bubbleName.font = UIFont.boldSystemFont(ofSize: 20.0)
        let cirleSide = self.frame.size.width - 10
        let radiusOfBubble = cirleSide/2
        let notificationSide =  min(cirleSide * 0.22, 30)
        notificationCount.frame = CGRect(x: radiusOfBubble*1.7072 - notificationSide/2, y: radiusOfBubble*0.2927 - notificationSide/2, width: notificationSide, height: notificationSide)
        self.notificationCount.layer.cornerRadius = notificationSide/2
        self.circuleBubble.layer.cornerRadius = radiusOfBubble
        if bubbleData.profileImage.count > 0{
            self.profileImage.isHidden = true
        }else{
             self.profileImage.isHidden = true
        }
        // Set bubble Data
        if bubbleData.bubbleName == UserManager.shareManger.userName!
        {
            bubbleName.text = "\(ConstantMessage.kMyPrayers1)\n\(bubbleData.bubbleName)"
        }else
        {
            bubbleName.text = "\(bubbleData.bubbleName)"
        }
        notificationCount.text = "\(bubbleData.bubbleNotificationCount!)"
        totalCount.text = "\(bubbleData.bubbleCount!)"
        if bubbleData.bubbleNotificationCount! == 0
        {
            notificationCount.isHidden = true
        }else
        {
            notificationCount.isHidden = false
        }
        self.tag = tag + 10
        
        if bubbleData.identificationId == -3 || bubbleData.identificationId == 3
        {
            self.bubbleName.textColor = UIColor.white
            self.circuleBubble.backgroundColor = iPrayColor.groupBgColor
            self.totalBubbleCountConstraint.constant = 0
        }else
        {
            self.totalBubbleCountConstraint.constant =  self.frame.size.width * 0.25
            if bubbleData.bubbleData.object(forKey: ConstantMessage.kInMyContacts) != nil && bubbleData.bubbleData.object(forKey: ConstantMessage.kInMyContacts) as! String == "1"
            {
                self.bubbleName.textColor = iPrayColor.groupBgColor
            }else
            {
                self.bubbleName.textColor = UIColor.white
            }
            if bubbleData.profileImage.count > 0 &&  !self.profileImage.isHidden{
               self.circuleBubble.backgroundColor = UIColor.clear
                self.circuleBubble.layer.borderColor = iPrayColor.normalBgColor.cgColor
               self.circuleBubble.layer.borderWidth = 2.0
            }else{
                self.circuleBubble.backgroundColor = iPrayColor.normalBgColor
            }
        }
    }
    
    //MARK:-Start Animate Bubble
    func startAnimationInBubble()
    {
        // set base view frame
        let cirleSide = self.baseView.frame.size.width + 20
        self.baseView.frame = CGRect(x: 5, y: 5, width: cirleSide, height: cirleSide)
        if self.tag  % 2 == 0
        {
            animateInBubble()
        }else
        {
            animateOutBubble()
        }
    }
    
    func animateInBubble()
    {
        let cirleSide = self.baseView.frame.size.width
        let motionFactorX = self.motionFactorX()
        let motionFactorY = self.motionFactorY()
        UIView.animate(withDuration: getDelay(), delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.baseView.frame = CGRect(x: self.baseView.frame.origin.x + motionFactorX + 1, y: self.baseView.frame.origin.y + motionFactorY  + 1, width: cirleSide, height: cirleSide)
        }) { (compelte) in
            if compelte
            {
                self.animateOutBubble()
            }
        }
    }
    
    func animateOutBubble()
    {
        let cirleSide = self.baseView.frame.size.width
        let motionFactorX = self.motionFactorX()
        let motionFactorY = self.motionFactorY()
        UIView.animate(withDuration: getDelay(), delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.baseView.frame = CGRect(x: self.baseView.frame.origin.x - motionFactorX - 1, y: self.baseView.frame.origin.y - motionFactorY - 1, width: cirleSide, height: cirleSide)
        }) { (compelte) in
            if compelte
            {
                self.animateInBubble()
            }
        }
    }
    
    func motionFactorX() -> CGFloat
    {
        var factore = getDelay() + sin(getDelay())*getDelay() * 3.0
        if tag  % 2 == 0
        {
            factore = getDelay() + cos(getDelay())*getDelay() * 1.0
        }
        return CGFloat(factore)
    }
    
    func motionFactorY() -> CGFloat
    {
        var factore = getDelay() + cos(getDelay())*getDelay() * 1.0
        if tag  % 2 == 0
        {
            factore = getDelay() + sin(getDelay())*getDelay() * 3.0
        }
        return CGFloat(factore)
     }
    
    func getDelay() -> Double
    {
        var delay = Double(self.tag)
        if delay > Double(motionSpeed)
        {
            delay = delay.truncatingRemainder(dividingBy: Double(motionSpeed - 1))
        }
        if delay == 0 || delay == 1
        {
            delay = 2
        }
        return Double(delay)
     }
    
    //MARK:- IBAction
    @IBAction func bubbleButtonPress(_ sender: Any) {
        delegate?.didSelectBubble(at: self.tag)
    }
}

