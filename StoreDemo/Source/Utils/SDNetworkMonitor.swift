//
//  NetworkMonitor.swift
//  StoreDemo
//
//  Created by Admin on 15.10.2024.
//

import Foundation
import Network

extension Notification.Name {
    static let SDNetworkMonitorStatusChanged = Notification.Name("SDNetworkMonitorStatusChanged")
}

enum SDNetworkMonitorError: LocalizedError {
    case noInternet
    
    var errorDescription: String? {
        switch self {
            case .noInternet:
                return .ErrorNoInternet
        }
    }
}

class SDNetworkMonitor {

    static let shared = SDNetworkMonitor()
    
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private(set) var isConnected: Bool = false
    private let monitor: NWPathMonitor
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    /// Initialize network monitor.
    func initialize() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.notifyAboutStatusChange()
        }
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
    
    private func notifyAboutStatusChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .SDNetworkMonitorStatusChanged, object: nil)
        }
    }
}
