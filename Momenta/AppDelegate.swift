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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        //START OneSignal initialization code
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]
        
        // Replace 'YOUR_ONESIGNAL_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
          appId: "5e605fcd-de88-4b0a-a5eb-5c18b84d52f3",
          handleNotificationAction: nil,
          settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

        // The promptForPushNotifications function code will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 6)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
        //END OneSignal initializataion code

        // Override point for customization after application launch.
        UINavigationBar.appearance().tintColor = UIColor.white
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        
        /*
        // Facebook init
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        */

        Cloud.sharedInstance.initApp()
        
        Cloud.sharedInstance.getUserIDToken(completion: {auth in
            if auth != nil {
                //Utility.sharedInstance.logoutAndRemoveUserDefaults()
                print("USER ID AUTHENTICATED")
                Cloud.sharedInstance.getCurrentUserId(completion: { userId in
                    OneSignal.setExternalUserId(userId!, withCompletion: { results in
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
                    Cloud.sharedInstance.fetchUserData(userId: userId!, completion: { (user) in
                        Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: {
                            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                            if let osPlayerId = status.subscriptionStatus.userId {
                                let values: [String: AnyObject] = ["osPlayerId": osPlayerId as AnyObject]
                                Cloud.sharedInstance.updateUserInDatabaseWithUID(uid: user.userId!, values: values, completion: {
                                    print("osPlayerId \(osPlayerId) added to Firebase User Id \(user.userId!)")
                                })
                            }
                            OneSignal.setEmail(user.email ?? "no email set")
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

