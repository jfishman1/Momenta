//
//  AppDelegate.swift
//  humble
//
//  Created by Jonathon Fishman on 7/29/17.
//  Copyright © 2017 GoYoJo. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FBSDKCoreKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().tintColor = UIColor.white
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGray]
        
        // Facebook init
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        // Twitter init
        TWTRTwitter.sharedInstance().start(withConsumerKey:"33JVom0gWa1M67rpacHoygwIy", consumerSecret:"3BVjEkgI6JJY63dkj9R8zOTLVuoNTxJ1Z4wnBLRVlMFHrUs5kZ")


        Cloud.sharedInstance.initApp()
        
        Cloud.sharedInstance.getUserIDToken(completion: {auth in
            if auth != nil {
                //Utility.sharedInstance.logoutAndRemoveUserDefaults()
                Cloud.sharedInstance.getCurrentUserId(completion: { userId in
                    Cloud.sharedInstance.fetchUserData(userId: userId!, completion: { (user) in
                        Utility.sharedInstance.writeUserDataToArchiver(user: user, completion: { 
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
    
    // For Google, Facebook, Twitter Sign In
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            
            let facebookDidHandle = ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
            let googleDidhandle = GIDSignIn.sharedInstance().handle(url)
            //let googleDidhandle = GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
            
            let twitterDidHandle = TWTRTwitter.sharedInstance().application(application, open: url, options: options)
            
            return googleDidhandle || facebookDidHandle || twitterDidHandle
    }
    
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

