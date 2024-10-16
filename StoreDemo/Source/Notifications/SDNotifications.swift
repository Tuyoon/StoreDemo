//
//  Notifications.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UserNotifications
import UIKit

enum SDNotificationSoundType {
    case `default`
    case coins
}

private extension SDNotificationSoundType {
    var sound: UNNotificationSound {
        switch self {
            case .default:
                return .default
            case .coins:
                return UNNotificationSound(named: UNNotificationSoundName("coins.wav"))
        }
    }
}

class SDNotifications {
    
    static func authorize(completion: @escaping () -> Void) {
        Task {
            let center = UNUserNotificationCenter.current()
            do {
                try await center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings])
            } catch {
                
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
        
    static func scheduleNotification(id: String, timeInterval: TimeInterval, title: String, body: String, soundType: SDNotificationSoundType, badge: NSNumber?) {
        Task {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [id])
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = soundType.sound
            content.badge = badge
                        
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            try await center.add(request)
        }
    }
    
    static func clearNotifications() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
