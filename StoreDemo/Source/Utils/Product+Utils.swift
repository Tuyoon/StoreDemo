//
//  Product+Utils.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import StoreKit

extension Product {
    /// Discound % in compare with specified product.
    func discountInCompareWith(_ otherProduct: Product) -> Double {
        guard let subscription = subscription,
              let otherSubscription = otherProduct.subscription else {
            return 0
        }
        
        var otherMultiplier: Decimal = 1
        switch otherSubscription.subscriptionPeriod.unit {
            case .day:
                otherMultiplier = 365
            case .week:
                otherMultiplier = 365 / 7
            case .month:
                otherMultiplier = 12
            case .year:
                otherMultiplier = 1
            @unknown default:
                break
        }
        otherMultiplier /= Decimal(otherSubscription.subscriptionPeriod.value)
        
        var myPrice: Decimal = price
        switch subscription.subscriptionPeriod.unit {
            case .day:
                myPrice = price * 365
            case .week:
                myPrice = price * (365/7)
            case .month:
                myPrice = price * 12
            case .year:
                myPrice = price
            @unknown default:
                break
        }
        myPrice /= Decimal(subscription.subscriptionPeriod.value)
        
        let fullPrice = otherProduct.price * otherMultiplier
        let difference = fullPrice - myPrice
        let percent = difference / fullPrice * 100
        
        let decimalNumber = NSDecimalNumber(decimal:percent)
        return decimalNumber.doubleValue
    }
}

