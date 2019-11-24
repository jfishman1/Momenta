//
//  User.swift
//  humble
//
//  Created by Jonathon Fishman on 8/20/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit


class User: NSObject, NSCoding {
    
    var userId: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var bigProfileImageUrl: String?
    var smallProfileImageUrl: String?
    var posts: [String: Any]?
    var comments: [String: Any]?
    var groups: [String: Any]?
    var attributes: [String]?
    var supporters: [String: Any]?
    var blockedUsers: [String: Any]?
    
    init(userDictionary: [String: AnyObject]) {
        self.userId = userDictionary["userId"] as? String
        self.firstName = userDictionary["firstName"] as? String
        self.lastName = userDictionary["lastName"] as? String
        self.email = userDictionary["email"] as? String
        self.bigProfileImageUrl = userDictionary["bigProfileImageUrl"] as? String
        self.smallProfileImageUrl = userDictionary["smallProfileImageUrl"] as? String
        self.posts = userDictionary["posts"] as? [String: Any]
        self.comments = userDictionary["comments"] as? [String: Any]
        self.groups = userDictionary["groups"] as? [String: Any]
        self.attributes = userDictionary["attributes"] as? [String]
        self.supporters = userDictionary["supporters"] as? [String: Any]
        self.blockedUsers = userDictionary["blockedUsers"] as? [String: Any]
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let userId = aDecoder.decodeObject(forKey: "userId") as? String else { return nil }
        guard let firstName = aDecoder.decodeObject(forKey: "firstName") as? String else { return nil }
        guard let lastName = aDecoder.decodeObject(forKey: "lastName") as? String else { return nil }
        guard let email = aDecoder.decodeObject(forKey: "email") as? String else { return nil }
        guard let bigProfileImageUrl = aDecoder.decodeObject(forKey: "bigProfileImageUrl") as? String else { return nil }
        guard let smallProfileImageUrl = aDecoder.decodeObject(forKey: "smallProfileImageUrl") as? String else { return nil }
        guard let posts = aDecoder.decodeObject(forKey: "posts") as? [String: Any] else { return nil }
        guard let comments = aDecoder.decodeObject(forKey: "comments") as? [String: Any] else { return nil }
        guard let groups = aDecoder.decodeObject(forKey: "groups") as? [String: Any] else { return nil }
        guard let attributes = aDecoder.decodeObject(forKey: "attributes") as? [String] else { return nil }
        guard let supporters = aDecoder.decodeObject(forKey: "supporters") as? [String: Any] else { return nil }
        guard let blockedUsers = aDecoder.decodeObject(forKey: "blockedUsers") as? [String: Any] else { return nil }
        
        self.init(userDictionary: [
            "userId": userId as AnyObject,
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "email": email as AnyObject,
            "bigProfileImageUrl": bigProfileImageUrl as AnyObject,
            "smallProfileImageUrl": smallProfileImageUrl as AnyObject,
            "posts": posts as AnyObject,
            "comments": comments as AnyObject,
            "groups": groups as AnyObject,
            "attributes": attributes as AnyObject,
            "supporters": supporters as AnyObject,
            "blockedUsers": blockedUsers as AnyObject
        ])
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userId, forKey: "userId")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.bigProfileImageUrl, forKey: "bigProfileImageUrl")
        aCoder.encode(self.smallProfileImageUrl, forKey: "smallProfileImageUrl")
        aCoder.encode(self.posts, forKey: "posts")
        aCoder.encode(self.comments, forKey: "comments")
        aCoder.encode(self.groups, forKey: "groups")
        aCoder.encode(self.attributes, forKey: "attributes")
        aCoder.encode(self.supporters, forKey: "supporters")
        aCoder.encode(self.blockedUsers, forKey: "blockedUsers")
    }
    
}
