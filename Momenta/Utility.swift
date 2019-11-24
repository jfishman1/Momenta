//
//  Utility.swift
//  humble
//
//  Created by Jonathon Fishman on 10/1/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    static let sharedInstance = Utility()
    fileprivate init() {
        imageCache.countLimit = 100
    }
    
    let mainGreen = UIColor(r: 80, g: 227, b: 194)//(r: 91, g: 230, b: 205)
    
    // MARK: Image Cache
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    func loadImageFromUrl(photoUrl: String, completion: @escaping (Data) -> (), loadError: @escaping () -> ()) {
        
        let url = URL(string: photoUrl)!
        
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if error == nil {
                do {
                    let data = try Data(contentsOf: url, options: [])
                    DispatchQueue.main.async {
                        completion(data)
                    }
                } catch {
                    print("NSData Error: \(error)")
                    DispatchQueue.main.async {
                        loadError()
                    }
                }
            } else {
                print("NSURLSession Error: \(error!)")
                DispatchQueue.main.async {
                    loadError()
                }
            }
        })
        task.resume()
    }
    
    // MARK: Navigation
    //let tabbarController = UITabBarController()
    func useAppDelegateToMoveTabBar(selectedIndex: Int) {
        //works... better way then referencing AppDelegate????
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
        tabBarController.selectedIndex = selectedIndex
    }
    
    // MARK: NSCoding
    func writeUserLogginStatus(isLoggedIn: Bool) {
        let defaults = Foundation.UserDefaults.standard
        let isLoggedInArchive = isLoggedIn
        let data = NSKeyedArchiver.archivedData(withRootObject: isLoggedInArchive)
        defaults.set(data, forKey: "LOGINSTATUS")
        defaults.synchronize()
    }
    func loadUserLogginStatusFromArchiver() -> (Bool?) {
        let defaults = Foundation.UserDefaults.standard
        if let data = defaults.object(forKey: "LOGINSTATUS") as? Data {
            let isLoggedIn = NSKeyedUnarchiver.unarchiveObject(with: data) as? Bool
            print("isLoggedIn",isLoggedIn as Any)
            return isLoggedIn
        }
        return nil
    }
    
    func writeUserDataToArchiver(user: User, completion: @escaping ()->()) {
        let defaults = Foundation.UserDefaults.standard
        let userId = user.userId ?? ""
        let firstName = user.firstName ?? ""
        let lastName = user.lastName ?? ""
        let email = user.email ?? ""
        let bigProfileImageUrl = user.bigProfileImageUrl ?? "BigProfileDefault"
        let smallProfileImageUrl = user.smallProfileImageUrl ?? "SmallProfileDefault"
        //let groups = user.groups ?? [:]
        let posts = user.posts ?? [:]
        let attributes = user.attributes ?? []
        //let actionsMade = user.actionsMade ?? 0
        let supporters = user.supporters ?? [:]
        let userDataToArchive = User(userDictionary: [
            "userId": userId as AnyObject,
            "firstName": firstName as AnyObject,
            "lastName": lastName as AnyObject,
            "email": email as AnyObject,
            "bigProfileImageUrl": bigProfileImageUrl as AnyObject,
            "smallProfileImageUrl": smallProfileImageUrl as AnyObject,
            //"groups": groups as AnyObject,
            "posts": posts as AnyObject,
            "attributes": attributes as AnyObject,
            //"actionsMade": actionsMade as AnyObject,
            "supporters": supporters as AnyObject
        ])
        let data = NSKeyedArchiver.archivedData(withRootObject: userDataToArchive)
        defaults.set(data, forKey: "USERDATA")
        defaults.synchronize()
        completion()
    }
    
//    func writeUpdatedUserGroupDataToArchiver(user: User, group: [String: Any], completion: @escaping ()->()) {
//        let defaults = Foundation.UserDefaults.standard
//        //var userGroups: [String: Any] = user.groups!
//        group.forEach({userGroups[$0] = $1})
//        let userDataToArchive = User(userDictionary: [
//            "userId": user.userId as AnyObject,
//            "firstName": user.firstName as AnyObject,
//            "lastName": user.lastName as AnyObject,
//            "email": user.email as AnyObject,
//            "bigProfileImageUrl": user.bigProfileImageUrl as AnyObject,
//            "smallProfileImageUrl": user.smallProfileImageUrl as AnyObject,
//            //"groups": userGroups as AnyObject,
//            "attributes": user.attributes as AnyObject,
//            //"actionsMade": user.actionsMade as AnyObject,
//            "supporters": user.supporters as AnyObject
//            ])
//        let data = NSKeyedArchiver.archivedData(withRootObject: userDataToArchive)
//        defaults.set(data, forKey: "USERDATA")
//        defaults.synchronize()
//        completion()
//    }
    func writeUpdatedUserPostDataToArchiver(user: User, post: [String: Any], completion: @escaping ()->()) {
        let defaults = Foundation.UserDefaults.standard
        var userPosts: [String: Any] = user.posts ?? [:]
        post.forEach({userPosts[$0] = $1})
        let userDataToArchive = User(userDictionary: [
            "userId": user.userId as AnyObject,
            "firstName": user.firstName as AnyObject,
            "lastName": user.lastName as AnyObject,
            "email": user.email as AnyObject,
            "bigProfileImageUrl": user.bigProfileImageUrl as AnyObject,
            "smallProfileImageUrl": user.smallProfileImageUrl as AnyObject,
            "posts": userPosts as AnyObject,
            "attributes": user.attributes as AnyObject,
            //"actionsMade": user.actionsMade as AnyObject,
            "supporters": user.supporters as AnyObject
            ])
        let data = NSKeyedArchiver.archivedData(withRootObject: userDataToArchive)
        defaults.set(data, forKey: "USERDATA")
        defaults.synchronize()
        completion()
    }
    
    func loadUserDataFromArchiver() -> (User?) {
        let defaults = Foundation.UserDefaults.standard
        if let data = defaults.object(forKey: "USERDATA") as? Data {
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            return userData
        }
        return nil
    }
    
    func logoutAndRemoveUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "LOGINSTATUS")
        userDefaults.removeObject(forKey: "USERDATA")
        Cloud.sharedInstance.logout()
    }
    
    // Mark: Custom Activity Spinner
    
    private var containerView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    
    public func showActivityIndicator(view: UIView) {
        
        let activityViewBackground = UIView()
        
        containerView.frame = view.frame
        containerView.center = view.center
        
        activityViewBackground.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityViewBackground.center = view.center
        activityViewBackground.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        activityViewBackground.clipsToBounds = true
        activityViewBackground.layer.cornerRadius = 5.0
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.center = CGPoint(x: activityViewBackground.frame.size.width / 2, y: activityViewBackground.frame.size.width / 2)
        
        activityViewBackground.addSubview(activityIndicator)
        containerView.addSubview(activityViewBackground)
        view.addSubview(containerView)
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicator(view: UIView) {
        
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
    
    // check if entered email is in the right format
    static func isValidEmail(emailAddress: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: emailAddress)
    }
    
    // Basic alert view
    
    static func showAlert(viewController: UIViewController, title: String, message: String, completion: @escaping ()->()) {
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            completion()
        })
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func reportPostAlert(viewController: UIViewController, postId: String, postCreatorName: String, reporterId: String) {
        let alertController = UIAlertController(title: "Report this post", message: "Are you sure you want to report this post?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.showActivityIndicator(view: viewController.view)
            // TODO: send me a notification
            Cloud.sharedInstance.reportPost(postId: postId, postCreatorName: postCreatorName, reporterId: reporterId, completion: {
                self.hideActivityIndicator(view: viewController.view)
                Utility.showAlert(viewController: viewController, title: "Post Reported", message: "We have received your report and will investigate over the next 24 hours. Thank you", completion: {})
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func reportCommentAlert(viewController: UIViewController, postId: String, commentId: String, commentCreatorName: String, reporterId: String) {
        let alertController = UIAlertController(title: "Report this comment", message: "Are you sure you want to report this comment?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.showActivityIndicator(view: viewController.view)
            // TODO: send me a notification
            Cloud.sharedInstance.reportComment(postId: postId, commentId: commentId, commentCreatorName: commentCreatorName, reporterId: reporterId, completion: {
                self.hideActivityIndicator(view: viewController.view)
                Utility.showAlert(viewController: viewController, title: "Comment Reported", message: "We have received your report and will investigate over the next 24 hours. Thank you", completion: {
                    viewController.navigationController?.popViewController(animated: true)
                })
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func blockUserAlert(viewController: UIViewController, currentUserId: String, blockedUserId: String) {
        let alertController = UIAlertController(title: "Block User", message: "Are you sure you want to block this person?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.showActivityIndicator(view: viewController.view)
            Cloud.sharedInstance.blockUser(currentUserId: currentUserId, blockedUserId: blockedUserId, completion: {
                self.hideActivityIndicator(view: viewController.view)
                Utility.showAlert(viewController: viewController, title: "User Blocked", message: "You will not see any more messages from this user.", completion: {
                    // viewController is chatlogcontroller
                    viewController.navigationController?.popViewController(animated: true)
                })
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}

