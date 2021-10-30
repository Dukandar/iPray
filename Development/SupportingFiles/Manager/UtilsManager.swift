//
//  UtilsManager.swift
//  iPray
//
//  Created by Ishan Sunilkumar on 30/08/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import Foundation

class UtilsManager: NSObject {

    static let shared = UtilsManager()
    
}

//CALayer propoerty in UIView
@IBDesignable extension UIView {
    @IBInspectable var viewBorderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var viewBorderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var viewCornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

//Place holdr textColor
extension UITextField{
    @IBInspectable var placeHolderTextColor : UIColor?{
        set{
            attributedPlaceholder =  NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        }
        get{
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
}
