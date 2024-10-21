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
        
        let diContainer = SDDIContainer.shared
        
        diContainer.register(SDNetworkMonitor.self) {
            return SDNetworkMonitor()
        }
        
        diContainer.register(SDCloudKitDatabase.self) {
            let networkMonitor = SDDIContainer.shared.resolve(SDNetworkMonitor.self)
            return SDCloudKitDatabase(networkMonitor: networkMonitor)
        }
        
        diContainer.register(SDGameCenter.self) {
            return SDGameCenter()
        }
        
        diContainer.register(SDUserState.self) {
            let gameCenter = SDDIContainer.shared.resolve(SDGameCenter.self)
            let database = SDDIContainer.shared.resolve(SDCloudKitDatabase.self)
            return SDUserState(gameCenter: gameCenter, database: database)
        }
        
        
        diContainer.register(SDStore.self) {
            let userState = SDDIContainer.shared.resolve(SDUserState.self)
            let database = SDDIContainer.shared.resolve(SDCloudKitDatabase.self)
            let networkMonitor = SDDIContainer.shared.resolve(SDNetworkMonitor.self)
            return SDStore(userState: userState,
                           database: database,
                           networkMonitor: networkMonitor)
        }
        
        diContainer.register(SDNotificationCenter.self) {
            return SDNotificationCenter(completion: {
                application.registerForRemoteNotifications()
            })
        }
        
        diContainer.register(SDRewardsManager.self) {
            let userState = SDDIContainer.shared.resolve(SDUserState.self)
            let database = SDDIContainer.shared.resolve(SDCloudKitDatabase.self)
            let notificationCenter = SDDIContainer.shared.resolve(SDNotificationCenter.self)
            return SDRewardsManager(userState: userState,
                                    database: database,
                                    notificationCenter: notificationCenter)
        }
        
        return true
    }
    
#if !targetEnvironment(simulator)
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        let cloudKitDatabase = SDDIContainer.shared.resolve(SDCloudKitDatabase.self)
        if cloudKitDatabase.handleNotification(notification) {
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
        let notificationCenter = SDDIContainer.shared.resolve(SDNotificationCenter.self)
        notificationCenter.clearNotifications()
    }
}

