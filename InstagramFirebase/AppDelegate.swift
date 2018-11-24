//
//  AppDelegate.swift
//  InstagramFirebase
//
//  Created by wenlong qiu on 10/7/18.
//  Copyright © 2018 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate{ //UIKit dispatches events to responders like appDelegate, The UIapplication object informs the delegate of significant runtime events, something happened, tells delegate to run its methods.

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        window = UIWindow() // uiwindow to change root view controller //must crete UIWindow if you dont use storyboard
        //set tabbar controller to rootcontroller
        window?.rootViewController = MainTabBarController()
        
        //to enable push notifications, go to xcodeproj, capabilities, enable push
        attemptRegisterForNotifications(application: application)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for notifications:", deviceToken)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    
    //cloud functions can notfiy users when changes in database eg gaining new followers
    //Execute intensive tasks in the cloud instead of in your app
    //read guide online firebase documentation cloud functions, edit json file
    
    
    //send a message to all apps by firebase console cloud messaging send your first message
    //listen for user notifications while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert) //notification center will define the completionhandler all you need is to input the presentation option .alert will pop the alert
    }
    
    //if user response to the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let followerId = userInfo["followerId"] as? String{
            //display userprofilecontroller
            let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.userId = followerId
            //access main ui from appdelegate, use if let if nesting upwrapping depending on previous unwrap
            if let mainTabBarController = window?.rootViewController as? MainTabBarController { //you dont know which controller user is at when notificaiton happen anyway
                
                mainTabBarController.selectedIndex = 0 //setting this var changes the selected view controller, swich to home controller, so if user is at search controller, this changes the ui to the pushed userprofilecontroller down below
                
                mainTabBarController.presentedViewController?.dismiss(animated: true, completion: nil) //dismiss whatever was presented so the follower's profilecontroller is not blocked by it
                
                if let homeNavigationController = mainTabBarController.viewControllers?.first as? UINavigationController {
                    homeNavigationController.pushViewController(userProfileController, animated: true)
                }
            }
        }
    }
    
    
    //lexical scope, the block of which the variable/function is declared
    //private is accessialbe from any extensions in the same source file, even outside of enclosed declaration scope, ie outside of the class, private more restritive than fileprivate
    private func attemptRegisterForNotifications(application: UIApplication) {
        
        //need to configure cloud messageing in firebase console, project overview settings cloud messaging configuration upload file, go to developer account , profile concertificate, key all, + new key , select apn confirm, download auth key file, copy and past key id, find teamid by clicking question mark
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            if let err = err {
                print("failed to request authorizaiton", err)
            }
            
            if granted {
                print("auth granted")
            } else {
                print("auth denied")
            }
        }
        application.registerForRemoteNotifications()
        
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

