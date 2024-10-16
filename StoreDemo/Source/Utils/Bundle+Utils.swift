//
//  Bundle+Utils.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation

extension Bundle {
    var versionString: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var shortVersionString: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
