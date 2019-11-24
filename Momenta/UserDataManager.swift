//
//  UserDataManager.swift
//  humble
//
//  Created by Jonathon Fishman on 2/18/18.
//  Copyright © 2018 GoYoJo. All rights reserved.
//

import Foundation

let userDataManagerDidUpdateCurrentUserNotification = "userDataManagerDidUpdateCurrentUserNotification"


class UserDataManager {
    static var sharedInstance = UserDataManager()
    private init() {}
    
    private (set) var currentUserData: User? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: userDataManagerDidUpdateCurrentUserNotification), object: nil)
        }
    }
    
    func requestCurrentUserData() {
        if let userData = Utility.sharedInstance.loadUserDataFromArchiver() {
            self.currentUserData = userData
        } else {
            Cloud.sharedInstance.getCurrentUserId(completion: { (userId) in
                Cloud.sharedInstance.fetchUserData(userId: userId!, completion: { (user) in
                    Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                        self.currentUserData = user
                    })
                }, err: {
                    return
                })
            })
        }
    }
}
