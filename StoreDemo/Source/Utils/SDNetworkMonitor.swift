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

protocol SDNetworkMonitorProtocol {
    var isConnected: Bool { get }
}

class SDNetworkMonitor: SDNetworkMonitorProtocol {

//    static let shared = SDNetworkMonitor()
    
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private(set) var isConnected: Bool = false
    private let monitor: NWPathMonitor
    
    init() {
        monitor = NWPathMonitor()
        start()
    }
    
    deinit {
        stop()
    }
    
    /// Initialize network monitor.
    private func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.notifyAboutStatusChange()
        }
        monitor.start(queue: queue)
    }
    
    private func stop() {
        monitor.cancel()
    }
    
    private func notifyAboutStatusChange() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .SDNetworkMonitorStatusChanged, object: nil)
        }
    }
}
