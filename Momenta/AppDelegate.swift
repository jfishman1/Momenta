//
//  AppDelegate.swift
//  humble
//
//  Created by Jonathon Fishman on 7/29/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
//import GoogleSignIn
import Firebase
//import FBSDKCoreKit
import OneSignal
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       // NotificatonManager.sharedInstance.setup(launchOptions: launchOptions)
        //Mixpanel Setup
        Mixpanel.initialize(token: "d810d40cdbc7dead2ff901838c696ccb")

//        //Firebase Messagaing
//        if #available(iOS 10.0, *) {
//          // For iOS 10 display notification (sent via APNS)
//          UNUserNotificationCenter.current().delegate = self
//
//          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//          UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: {_, _ in })
//        } else {
//          let settings: UIUserNotificationSettings =
//          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//          application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
//        //Firebase Messagaing */
        
        //Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
////        //START OneSignal initialization code
////        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]

        
        let notifWillShowInForegroundHandler: OSNotificationWillShowInForegroundBlock = { notification, completion in
            print("Received Notification: ", notification.notificationId ?? "no id")
            print("launchURL: ", notification.launchURL ?? "no launch url")
            print("content_available = \(notification.contentAvailable)")
            if notification.notificationId == "example_silent_notif" {
                completion(nil)
            } else {
                completion(notification)
            }
        }
        OneSignal.setNotificationWillShowInForegroundHandler(notifWillShowInForegroundHandler)

        let osNotificationOpenedBlock: OSNotificationOpenedBlock = { result in
            
            // This block gets called when the user reacts to a notification received
            let timeInterval = Int(NSDate().timeIntervalSince1970)
            OneSignal.sendTags(["last_push_clicked": timeInterval])
            
            let notification: OSNotification = result.notification
            print("Message: ", notification.body ?? "empty body")
            print("badge number: ", notification.badge)
            print("notification sound: ", notification.sound ?? "No sound")
                    
            if let additionalData = notification.additionalData {
                print("additionalData: ", additionalData)
                if let postId = additionalData["postId"] as? String {
                    print(additionalData["postId"] as! String)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if  let postDetailVC = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController,
                        let tabBarController = self.window?.rootViewController as? UITabBarController,
                        let navController = tabBarController.selectedViewController as? UINavigationController {
                            let dataModel = PostDataModel()
                            dataModel.postId = postId
                            postDetailVC.dataModel = dataModel
                            navController.popViewController(animated: false)
                            navController.pushViewController(postDetailVC, animated: true)
                    }
                }
                if let actionSelected = notification.actionButtons {
                    print("actionSelected: ", actionSelected)
                }
                if let actionID = result.action.actionId {
                    //handle the action
                    print(actionID.description)
                }
            }
        }
        
        // Replace 'YOUR_ONESIGNAL_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("5e605fcd-de88-4b0a-a5eb-5c18b84d52f3")
        OneSignal.setLaunchURLsInApp(true)

        OneSignal.setNotificationOpenedHandler(osNotificationOpenedBlock)

        // The promptForPushNotifications function code will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 6)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
//        //END OneSignal initializataion code
//        
//        let OneSignalInAppMessageClickHandler: OSInAppMessageClickBlock = { action in
//            if let clickName = action.clickName {
//                print("clickName string: ", clickName)
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if clickName == "getStarted" {
//                    if  let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController,
//                        let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as? FirstViewController{
//                        self.window?.rootViewController = firstVC
//                        firstVC.present(loginVC, animated: true, completion: nil)
//                    }
//                }
//                if clickName == "updateInterests" {
//                    if  let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController,
//                        let tabBarController = self.window?.rootViewController as? UITabBarController,
//                        let navController = tabBarController.selectedViewController as? UINavigationController,
//                        let profileVC = navController.visibleViewController as? ProfileViewController {
//                        print(tabBarController.selectedViewController.debugDescription)
//                        print(navController.viewControllers.description)
//                        print(navController.presentedViewController.debugDescription)
//                        print(navController.visibleViewController.debugDescription)
//                        profileVC.present(editProfileVC, animated: true, completion: nil)
//                        
//                    }
//                }
//            }
//            if let clickUrl = action.clickUrl {
//                print ("clickUrl string: ", clickUrl)
//            }
//            let firstClick = action.firstClick
//            print("firstClick bool: ", firstClick)
//            let closesMessage = action.closesMessage
//            print("closesMessage bool: ", closesMessage)
//        }
//
//       OneSignal.setInAppMessageClickHandler(OneSignalInAppMessageClickHandler)

        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = UIColor.white
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        
        /*
        // Facebook init
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        */
        
        //Firebase init code set in Cloud Singleton Class
        Cloud.sharedInstance.initApp()
        //Check if user has a Firebase record
        Cloud.sharedInstance.getUserIDToken(completion: {auth in
            if auth != nil {
                //Utility.sharedInstance.logoutAndRemoveUserDefaults()
                print("USER ID AUTHENTICATED")
                
                //osDemo1 get the Firebase User ID and set to OS External User ID
                Cloud.sharedInstance.getCurrentUserId(completion: { userId in
                    Mixpanel.mainInstance().identify(distinctId: userId!)
                    OneSignal.setExternalUserId(userId!, withSuccess: { results in
                      // The results will contain push and email success statuses
                      print("External user id update complete with results: ", results!.description)
                      // Push can be expected in almost every situation with a success status, but
                      // as a pre-caution its good to verify it exists
                      if let pushResults = results!["push"] {
                        print("Set external user id push status: ", pushResults)
                      }
                      if let emailResults = results!["email"] {
                          print("Set external user id email status: ", emailResults)
                      }
                    })
                    
                    
                    if let deviceState = OneSignal.getDeviceState() {
                       let subscribed = deviceState.isSubscribed
                        print("subscribed = ", subscribed)
                        if subscribed == false {
                            OneSignal.addTrigger("unsubscribed", withValue: "true")
                        } else {
                            OneSignal.removeTrigger(forKey: "unsubscribed")
                        }
                        if let osPlayerId = deviceState.userId {
                            Mixpanel.mainInstance().people.set(properties: ["$onesignal_user_id":osPlayerId])
                        }
                    }
                    
                    
                    
                    
                    
                    // Use Firebase User ID to get User data
                    Cloud.sharedInstance.fetchUserData(userId: userId!, completion: { (user) in
                        Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                            //osDemo2 example of creating OneSignal email record for user upon fetching user email from Firebase
                            if let email = user.email {
                                OneSignal.setEmail(email, withEmailAuthHashToken: nil, withSuccess: {
                                    //The email has successfully been set.
                                    print("OneSignal email set: " + email)
//                                    OneSignal.setExternalUserId("test", withSuccess: {result in
//                                        print("successful set external user id: ", result?.debugDescription ?? "no result")
//                                    }, withFailure: {error in
//                                        print("failed set external user id: ", error.debugDescription)
//                                    })
                                }) { (error) in
                                    //Encountered an error while setting the email.
                                    print("OneSignal email error: " + error.debugDescription)
                                }
                            }
                            //osDemo3 get the OneSignal player id and set as attribute to user record in Firebase
                            let deviceState = OneSignal.getDeviceState()
                            if let userId = deviceState?.userId {
                                Mixpanel.mainInstance().people.set(properties: [ "$onesignal_user_id": userId ])
                                let values: [String: AnyObject] = ["osPlayerId": userId as AnyObject]
                                Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: user.userId!, values: values, completion: {
                                    print("osPlayerId \(String(describing: userId)) added to Firebase User Id \(user.userId!)")
                                })
                            }
                                                        
                            if let deviceState = OneSignal.getDeviceState() {
                                let userId = deviceState.userId
                                let values: [String: AnyObject] = ["osPlayerId": userId as AnyObject]
                                Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: user.userId!, values: values, completion: {
                                        print("osPlayerId added to Firebase User Id \(user.userId!)")
                                })
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "masterTabBar")
                        })
                    }, err: {
                        return
                    })
                })
            }
        })
        return true
    }
    
    /*
    // For Google, Facebook Sign In
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            
            let facebookDidHandle = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
            
            let googleDidhandle = GIDSignIn.sharedInstance().handle(url)
            //let googleDidhandle = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
                        
            return googleDidhandle || facebookDidHandle
    }*/
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is CreatePostViewController {
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "CreatePostViewController") {
                tabBarController.present(newVC, animated: true)
                return false
            }
        }
        
        return true
    }
    
    
private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    
    print("Continue User Activity called: ")
    
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
        let url = userActivity.webpageURL!
        print(url.absoluteString)
        //handle url and open whatever page you want to open.
    }
    
    guard let url = userActivity.webpageURL else {
        print("url not a url")
        return false
    }
    guard let viewController = getDestination(for: url) else {
        
        application.open(url)
        
        return false
    }
    
    window?.rootViewController = viewController
    
    window?.makeKeyAndVisible()
    
    return true
    
}

func getDestination(for url: URL) -> UIViewController? {
    print("2-----------------------------------------------------------------------------------")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
    tabBarController?.selectedIndex = 1
    
    let destination = Destination(for: url)
    switch destination {
    case .posts: return tabBarController
    case .postDetails(let postId):
        let navController = tabBarController?.viewControllers?[1] as? UINavigationController
        
        guard let postDetailVC = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else { return nil }
        let dataModel = PostDataModel()
        dataModel.postId = String(postId)
        postDetailVC.dataModel = dataModel
        navController?.pushViewController(postDetailVC, animated: false)
        
        return tabBarController
    case .safari: return nil
    }
}
    
    

enum Destination {
    case posts
    case postDetails(Int)
    case safari
    init(for url: URL) {
        print("3-----------------------------------------------------------------------------------")
        print(url.lastPathComponent)
        if url.lastPathComponent == "posts" {
            self = .posts
        } else if let postId = Int(url.lastPathComponent) {
            self = .postDetails(postId)
        } else {
            self = .safari
        }
    }
}

}
//func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//    print("iOS Native didReceiveRemoteNotification: ", userInfo.debugDescription)
//    // This block gets called when the user reacts to a notification received
//    let timeInterval = Int(NSDate().timeIntervalSince1970)
//    OneSignal.sendTags(["last_push_received": timeInterval])
//    if #available(iOS 10.0, *) {
////        os_log("%{public}@", log: OSLog(subsystem: "com.onesignal.jonexample", category: "OneSignalNotificationServiceExtension"), type: OSLogType.debug, userInfo.debugDescription)
//    } else {
//        // Fallback on earlier versions
//    }
//}
