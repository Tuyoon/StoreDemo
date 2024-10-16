//
//  AppDelegate.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if !targetEnvironment(simulator)
        // Load iCloud data.
        SDCloudKitDatabase.shared.load { error in
            if let error {
                if let scene = application.connectedScenes.first as? UIWindowScene {
                    scene.keyWindow?.rootViewController?.showAlert(title: error.localizedDescription)
                }
            }
        }
#endif
        // Start network monitor.
        SDNetworkMonitor.shared.initialize()
        // Initialize store to load products.
        SDStore.shared.initialize()
        // Authorize notifications.
        SDNotifications.authorize {
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
#if !targetEnvironment(simulator)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        if SDCloudKitDatabase.shared.handleNotification(notification) {
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
#endif
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SDNotifications.clearNotifications()
    }
}

