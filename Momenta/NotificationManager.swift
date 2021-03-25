//
//  NotificationManager.swift
//  ScoreLynxPro
//
//  Created by Neil Schreiber on 5/28/20.
//  Copyright © 2020 Neil Schreiber. All rights reserved.
//
import UIKit
import OneSignal

enum NotificationActions: String {
    case scoreUpdate = "REFRESH_SCORES"
    case message = "MESSAGE"
    case gameUpdate = "REFRESH_GAME"
    
    var notificationName: Notification.Name {
        switch self {
        case .scoreUpdate:
            return Notification.Name("ScoreUpdateNotification")
        case .message:
            return Notification.Name("MessageNotification")
        case .gameUpdate:
            return Notification.Name("GameUpdateNotification")
        }
    }
}

class NotificatonManager {
    static let sharedInstance = NotificatonManager()
    
    func setup(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        //Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        //START OneSignal initialization code
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("5e605fcd-de88-4b0a-a5eb-5c18b84d52f3")

        OneSignal.setNotificationOpenedHandler { result in
            // This block gets called when the user reacts to a notification received
            let notification = result.notification
            guard let notificationID = notification.notificationId else { return }
            
            print("Opened Notification: \(notificationID)")
        }
        let notifWillShowInForegroundHandler: OSNotificationWillShowInForegroundBlock = { notification, completion in
            print("Received Notification: ", notification.notificationId!)
            print("launchURL: ", notification.launchURL ?? "no launch url")
            print("content_available = \(notification.contentAvailable)")
            if notification.notificationId == "example_silent_notif" {
                completion(nil)
            } else {
            completion(notification)
           }}

        OneSignal.setNotificationWillShowInForegroundHandler(notifWillShowInForegroundHandler)
//        OneSignal.setNotificationWillShowInForegroundHandler { (notification, completion) in
//            print("Received Notification")
//
//            guard let notificationID = notification.notificationId,
//                let additionalData = notification.additionalData,
//                let action = additionalData["ACTION_NAME"] as? String,
//                let notificationAction = NotificationActions(rawValue: action) else { return }
//
//            print("Received NotificationID: \(notificationID)")
//
//            switch notificationAction {
//            case .scoreUpdate:
//                print("Refresh Scores Action received")
//            case .message:
//                print("Message Action received")
//                if let message = notification.body {
//                    print("Message: " + message)
//                }
//            case .gameUpdate:
//                print("Game Updated Action received")
//                NotificationCenter.default.post(name: notificationAction.notificationName, object: nil)
//            }
//            completion(nil)
//        }

        
        // The promptForPushNotifications function code will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 6)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        //END OneSignal initializataion code
    }
    
    // Register this game id with OS so that SGScoreServer will send this game id's notifications to this device
//    func registerForGameNotification(game: Game) {
//        OneSignal.sendTag("GAME_ID", value: game.gameID!)
//    }
}
