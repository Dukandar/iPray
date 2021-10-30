//
//  bubbleAnimations.swift
//  iPray
//
//  Created by TrivialWorks on 24/02/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import UIKit

class BubbleAnimationView: UIView {
    enum PathType {
        case one
        case two
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        _ = customPath(type: .one)
        _ = customPath(type: .two)
    }
    
    func animate(icon: UIImage) {
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        let dimention = 40 + drand48() * 20
        imageView.frame = CGRect(x: 0, y: 0, width: dimention, height: dimention)
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            imageView.isHidden = true
            imageView.removeFromSuperview()
        })
        let randomPath = drand48() > 0.5 ? customPath(type: .one) : customPath(type: .two)
        let randomDuration: TimeInterval = drand48() > 0.5 ? 3 : 6
        let duration = 2 + drand48() * 4
        let positionAnim = positionAnimation(duration - 1, path: randomPath)
        let scaleAnim = scaleAnimation(randomDuration)
        let opacityAnim = opacityAnimation(randomDuration)
        let groupAnim = groupAnimation(randomDuration, animations: [positionAnim, scaleAnim, opacityAnim])
        imageView.layer.add(groupAnim, forKey: nil)
        CATransaction.commit()
        self.addSubview(imageView)
    }
    
    func positionAnimation(_ duration: TimeInterval, path: UIBezierPath) -> CAKeyframeAnimation {
        let positionAnimation = CAKeyframeAnimation(keyPath: ConstantMessage.kPosition)
        positionAnimation.duration = duration
        positionAnimation.path = path.cgPath
        positionAnimation.fillMode = CAMediaTimingFillMode.forwards
        positionAnimation.isRemovedOnCompletion = true
        positionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        return positionAnimation
    }
    
    func scaleAnimation(_ duration: TimeInterval) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: ConstantMessage.kTransformScale)
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 0
        scaleAnimation.isRemovedOnCompletion = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        return scaleAnimation
    }
    
    func opacityAnimation(_ duration: TimeInterval) -> CAKeyframeAnimation {
        let opacity = CAKeyframeAnimation(keyPath: ConstantMessage.kOpacity)
        opacity.duration = duration
        opacity.keyTimes = [0.4, 0.8, 5]
        opacity.values = [1, 0.7, 0]
        opacity.isRemovedOnCompletion = false
        return opacity
    }
    
    func groupAnimation(_ duration: TimeInterval, animations: [CAAnimation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.duration = duration
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        group.isRemovedOnCompletion = true
        group.animations = animations
        return group
    }
    
    func customPath(type: PathType) -> UIBezierPath {
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 100, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x:100,y:50))
        return path
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}



