//
//  SDDIContainer.swift
//  StoreDemo
//
//  Created by Admin on 21.10.2024.
//

import Foundation

protocol SDDIContainerProtocol {
    func register<Service>(_ type: Service.Type, builder: @escaping () -> Service)
    func resolve<Service>(_ type: Service.Type) -> Service
}

class SDDIContainer: SDDIContainerProtocol {
    static let shared: SDDIContainer = SDDIContainer()
    private var builders: [String: Any] = [:]
    private var services: [String: Any] = [:]
    
    private init() {}
    
    func register<Service>(_ type: Service.Type, builder: @escaping () -> Service) {
        let key = String(describing: Service.self)
        builders[key] = builder
    }
    
    func resolve<Service>(_ type: Service.Type) -> Service {
        let key = String(describing: Service.self)
        if let service = services[key] as? Service {
            return service
        }
        guard let builder = builders[key] as? () -> Service else {
            fatalError("Service not registered \(key)")
        }
        
        let service = builder()
        services[key] = service
        builders.removeValue(forKey: key)
        
        return service
    }
}
