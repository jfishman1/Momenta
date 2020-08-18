//
//  Message.swift
//  humble
//
//  Created by Jonathon Fishman on 9/23/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl: String?
    var videoUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    init(messageDictionary: [String: Any]) {
        self.fromId = messageDictionary["fromId"] as? String
        self.text = messageDictionary["text"] as? String
        self.toId = messageDictionary["toId"] as? String
        self.timestamp = messageDictionary["timestamp"] as? NSNumber
        self.imageUrl = messageDictionary["imageUrl"] as? String
        self.videoUrl = messageDictionary["videoUrl"] as? String
        self.imageWidth = messageDictionary["imageWidth"] as? NSNumber
        self.imageHeight = messageDictionary["imageHeight"] as? NSNumber
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
        // same above and below
        //        if fromId == Auth.auth()?.currentUser?.uid {
        //            return toId
        //        } else {
        //            return fromId
        //        }
    }
    
}
