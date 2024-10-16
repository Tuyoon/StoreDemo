//
//  App.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit
import StoreKit

private enum SDAppConstants {
#if DEBUG
    static var rateInterval: TimeInterval = 60 * 60
#else
    static var rateInterval: TimeInterval = 60 * 60 * 24
#endif
}

class SDApp {
    
    /// Last rate app request display date.
    @SDUserDefaulltsStoredValue(defaultValue: nil, key: "app-rateDate")
    private static var rateDate: Date?
    
    /// Display rate app request.
    static func rate() {
        if let rateDate {
            if Date().timeIntervalSince(rateDate) <= SDAppConstants.rateInterval {
                return
            }
        } else {
            rateDate = Date()
            return
        }
        
        if let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            rateDate = Date()
        }
    }
}
