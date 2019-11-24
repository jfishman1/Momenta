//
//  Post.swift
//  humble
//
//  Created by Jonathon Fishman on 3/20/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import Foundation

class Post: NSObject {
    var postId: String?
    var creatorId: String?
    var creatorName: String?
    var creatorImageUrl: String?
    var timestamp: NSNumber?
    var category: String?
    var postDescription: String?
    var supporterIds: [String: Any]?
    var momentumCount: Int?
    var postText: String?
    var postImageUrl: String?
    var postVideoUrl: String?
    var comments: [Comment]?
    
    init(postDictionary: [String: Any]) {
        self.postId = postDictionary["postId"] as? String
        self.creatorId = postDictionary["creatorId"] as? String
        self.creatorName = postDictionary["creatorName"] as? String
        self.creatorImageUrl = postDictionary["creatorImageUrl"] as? String
        self.timestamp = postDictionary["timestamp"] as? NSNumber
        self.category = postDictionary["category"] as? String
        self.postDescription = postDictionary["postDescription"] as? String
        self.supporterIds = postDictionary["supporterIds"] as? [String: Any]
        self.momentumCount = postDictionary["momentumCount"] as? Int
        self.postText = postDictionary["postText"] as? String
        self.postImageUrl = postDictionary["postImageUrl"] as? String
        self.postVideoUrl = postDictionary["postVideoUrl"] as? String
        self.comments = postDictionary["comments"] as? [Comment]
    }
}
