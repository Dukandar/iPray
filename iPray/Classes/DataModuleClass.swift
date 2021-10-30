//
//  DataModuleClass.swift
//  iPray
//
//  Created by Saurabh Mishra on 22/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

import Foundation

class UserBubble
{
    // MARK: - Variables
    var bubbleID : String!
    var bubbleCount : Int!
    var bubbleNotificationCount : Int!
    var bubbleName : String = ""
    var identificationId : Int! // -1 : request, -2 : adopt, -3 : group ,0: reques all ,  1 : self , 2 : copy
    var bubbleData : NSDictionary!
    var profileImage :String!
    
    func setDataInBubbles(id : String, totalCount : Int,notificationCount : Int , name : String , identificationId : Int , bubbleDiscription : NSDictionary,profileImg : String) {
        self.bubbleID = id
        self.bubbleCount = totalCount
        self.bubbleNotificationCount = notificationCount
        self.bubbleName  = name
        self.identificationId = identificationId
        self.bubbleData = bubbleDiscription
        self.profileImage = profileImg
    }

    func getDataFromBubbles() -> NSDictionary {
        let temp = NSMutableDictionary()
        temp.setValue(self.bubbleID, forKey: ConstantMessage.kBubbleId)
        temp.setValue(self.bubbleCount, forKey: ConstantMessage.kBubbleCount)
        temp.setValue(self.bubbleNotificationCount, forKey: ConstantMessage.kBubbleNc)
        return temp
    }
}

