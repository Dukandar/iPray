//
//  iPray+UIColor.swift
//  iPray
//
//  Created by Ishan Sunilkumar on 25/08/20.
//  Copyright © 2020 TrivialWorks. All rights reserved.
//

import Foundation

extension UIColor{
    
    func hexColor(_ hexcode : String) -> UIColor{
       var cString:String = hexcode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
               
       if (cString.hasPrefix("#")) {
           cString.remove(at: cString.startIndex)
       }
       
       if ((cString.count) != 6) {
           return UIColor.gray
       }
       
       var rgbValue:UInt32 = 0
       Scanner(string: cString).scanHexInt32(&rgbValue)
       
       return UIColor(
           red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
           green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
           blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
           alpha: CGFloat(1.0)
       )
    }
    
}

class iPrayColor : UIColor{
    class var groupBgColor : UIColor{
        return UIColor(red: 120.0/255.0, green: 45.0/255.0, blue: 112.0/255.0, alpha: 1)
    }
    class var normalBgColor : UIColor{
        return UIColor(red: 234.0/255.0, green: 181.0/255.0, blue: 72.0/255.0, alpha: 1)
    }
}


