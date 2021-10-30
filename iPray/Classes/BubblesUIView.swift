//
//  BubblesUIView.swift
//  iPray
//
//  Created by Manvendra Pratap Singh on 29/11/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

//import UIKit
//protocol BubblesUIviewDelegate {
//    func didSelectBubble(at: NSInteger)
//}
//class BubblesUIView: UIView {
//    var delegate : BubblesUIviewDelegate!
//    
//    @IBOutlet var baseView: UIView!
//    @IBOutlet var circuleBubble: UIView!
//    @IBOutlet var bubbleName: UILabel!
//    @IBOutlet var notificationCOunt: UILabel!
//    @IBOutlet var totalCount: UILabel!
//    
//    @IBOutlet var totalBubbleCountConstraint: NSLayoutConstraint!
//    let motionSpeed : Int = 6
// 
//     var groupBgColor = UIColor(red: 120.0/255.0, green: 45.0/255.0, blue: 112.0/255.0, alpha: 1)
//      var normalBgColor = UIColor(red: 234.0/255.0, green: 181.0/255.0, blue: 72.0/255.0, alpha: 1)
//    func makeCircle(bubbleData : bubblesData,tag : Int)
//    {
//        self.backgroundColor = UIColor.red
//        let cirleSide = self.frame.size.width - 10
//        let radiusOfBubble = cirleSide/2
//        let notificationSide =  min(cirleSide * 0.22, 30)
//  
//        notificationCOunt.frame = CGRect(x: radiusOfBubble*1.7072 - notificationSide/2, y: radiusOfBubble*0.2927 - notificationSide/2, width: notificationSide, height: notificationSide)
//        
//         self.notificationCOunt.layer.cornerRadius = notificationSide/2
//         self.circuleBubble.layer.cornerRadius = radiusOfBubble
//        
//        // Set bubble Data
//        bubbleName.text = "\(bubbleData.bubbleName)"
//        notificationCOunt.text = "\(bubbleData.bubbleNotificationCount!)"
//        totalCount.text = "\(bubbleData.bubbleCount!)"
//        if bubbleData.bubbleNotificationCount! == 0
//        {
//          notificationCOunt.isHidden = true
//            
//            
//        }else
//        {
//            notificationCOunt.isHidden = false
//            
//        }
//        self.tag = tag + 10
//        
//        // set color According to group and adoption
//        
//     //    var identificationId : Int! // -1 : request, -2 : adopt, -3 : group ,0: reques all ,  1 : self , 2 : copy
//        
//        if bubbleData.identificationId == -3
//        {
//            self.bubbleName.textColor = UIColor.white
//            self.circuleBubble.backgroundColor = groupBgColor
//            self.totalBubbleCountConstraint.constant = 0
//        }else
//        {
//            self.totalBubbleCountConstraint.constant =  self.frame.size.width * 0.3
//            if bubbleData.identificationId == -2
//            {
//                self.bubbleName.textColor = groupBgColor
//                
//            }else
//            {   self.bubbleName.textColor = UIColor.white
//                
//            }
//            self.circuleBubble.backgroundColor = normalBgColor
//        }
//
//        // Start animation in Bubble
//      //  startAnimationInBubble()
//        
//    }
//    
//    func startAnimationInBubble()
//    {
//        // set base view frame
//        let cirleSide = self.baseView.frame.size.width
//        self.baseView.frame = CGRect(x: 5, y: 5, width: cirleSide, height: cirleSide)
//        
//        if self.tag  % 2 == 0
//        {
//            animateInBubble()
//        }else
//        {
//            animateOutBubble()
//            
//        }
//        
//    }
//    
//    func animateInBubble()
//    {
//        
//        let cirleSide = self.baseView.frame.size.width
//         let motionFactorX = self.motionFactorX()
//         let motionFactorY = self.motionFactorY()
//        
//        UIView.animate(withDuration: getDelay(), delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
//            self.baseView.frame = CGRect(x: self.baseView.frame.origin.x + motionFactorX, y: self.baseView.frame.origin.y + motionFactorY , width: cirleSide, height: cirleSide)
//          
//        }) { (compelte) in
//            if compelte
//            {
//            self.animateOutBubble()
//            }
//            
//        }
//        
//    }
//    func animateOutBubble()
//    {
//        
//        let cirleSide = self.baseView.frame.size.width
//        let motionFactorX = self.motionFactorX()
//        let motionFactorY = self.motionFactorY()
//        
//        UIView.animate(withDuration: getDelay(), delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
//            self.baseView.frame = CGRect(x: self.baseView.frame.origin.x - motionFactorX , y: self.baseView.frame.origin.y - motionFactorY, width: cirleSide, height: cirleSide)
//            
//        }) { (compelte) in
//            if compelte
//            {
//            self.animateInBubble()
//            }
//        }
//        
//    }
//    
//    func motionFactorX() -> CGFloat
//    {
//        var factore = getDelay() + sin(getDelay())*getDelay() * 8.0
//        if tag  % 2 == 0
//        {
//            factore = getDelay() + cos(getDelay())*getDelay() * 6.0
//        }
//        
//        return CGFloat(factore)
//        
//    }
//    func motionFactorY() -> CGFloat
//    {
//        
//        var factore = getDelay() + cos(getDelay())*getDelay() * 6.0
//        if tag  % 2 == 0
//        {
//            factore = getDelay() + sin(getDelay())*getDelay() * 8.0
//        }
//        
//        return CGFloat(factore)
//        
//    }
//    
//    func getDelay() -> Double
//    {
//        
//        var delay = Double(self.tag)
//        if delay > Double(motionSpeed)
//        {
//            
//            delay = delay.truncatingRemainder(dividingBy: Double(motionSpeed - 1))
//        }
//        
//        if delay == 0 || delay == 1
//        {
//            delay = 2
//        }
//        return Double(delay)
//    }
//    
//    @IBAction func bubbleButtonPress(_ sender: Any) {
//        
//        delegate?.didSelectBubble(at: self.tag)
//    }
//
//}

