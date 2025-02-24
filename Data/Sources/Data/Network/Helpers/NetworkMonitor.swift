//
//  NetworkMonitorProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Network

public protocol NetworkMonitorProtocol: Sendable {
    var isConnected: Bool { get }
}

public final class NetworkMonitor: NetworkMonitorProtocol {
    public static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var _isConnected: Bool = true
    
    public var isConnected: Bool {
        _isConnected
    }
    
    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            self._isConnected = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
}

extension NetworkMonitor: @unchecked Sendable {}
