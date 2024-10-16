//
//  DateFormatters.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import UIKit

class SDDateFormatters {
    private static let standardDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss"
        return dateFormatter
    }()
    
    static func standardString(from date: Date) -> String {
        return standardDateFormatter.string(from: date)
    }
    
    private static let elapsedTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    private static let elapsedShortTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    static func elapsedTimeString(_ time: TimeInterval) -> String {
        if time < 3600 {
            return elapsedShortTimeFormatter.string(from: time)!
        }
        return elapsedTimeFormatter.string(from: time)!
    }
}
