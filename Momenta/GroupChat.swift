//
//  GroupChat.swift
//  humble
//
//  Created by Jonathon Fishman on 10/20/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit

class GroupChat: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var imageUrl: String?
    var videoUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    var profileImageUrl: String?
    
    init(groupChatDictionary: [String: Any]) {
        self.fromId = groupChatDictionary["fromId"] as? String
        self.text = groupChatDictionary["text"] as? String
        self.timestamp = groupChatDictionary["timestamp"] as? NSNumber
        self.imageUrl = groupChatDictionary["imageUrl"] as? String
        self.videoUrl = groupChatDictionary["videoUrl"] as? String
        self.imageWidth = groupChatDictionary["imageWidth"] as? NSNumber
        self.imageHeight = groupChatDictionary["imageHeight"] as? NSNumber
        
        self.profileImageUrl = groupChatDictionary["profileImageUrl"] as? String
    }
}
