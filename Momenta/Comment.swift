//
//  Comment.swift
//  humble
//
//  Created by Jonathon Fishman on 4/8/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import Foundation

struct Comment {
    var commentId: String?
    var postId: String?
    var commentCreatorId: String?
    var commentorName: String?
    var commentorImageUrl: String?
    var comment: String?
    var commentImageUrl: String?
    var timestamp: Int?
    
    init(commentDictionary: [String: Any]) {
        self.commentId = commentDictionary["commentId"] as? String
        self.postId = commentDictionary["postId"] as? String
        self.commentCreatorId = commentDictionary["commentCreatorId"] as? String
        self.commentorName = commentDictionary["commentorName"] as? String
        self.commentorImageUrl = commentDictionary["commentorImageUrl"] as? String
        self.comment = commentDictionary["comment"] as? String
        self.commentImageUrl = commentDictionary["commentImageUrl"] as? String
        self.timestamp = commentDictionary["timestamp"] as? Int
    }
}

extension Comment: CustomStringConvertible {
    var description: String {
        return "commentId, postId, creatorId, commentorName, commentorImageUrl, comment, commentImageUrl, timestamp"
    }
}
