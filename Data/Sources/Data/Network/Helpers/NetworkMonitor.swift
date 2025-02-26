//
//  NetworkMonitorProtocol.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Network
import Combine

@MainActor
public final class NetworkMonitor: ObservableObject, Sendable {
    public static let shared = NetworkMonitor()
    
    // Marking as private(set) ensures external code only subscribes to changes.
    @Published public private(set) var isConnected: Bool = true
    
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    
    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            // Use a Task to ensure that updates occur on the main actor.
            Task { @MainActor in
                let newStatus = (path.status == .satisfied)
                // Only update if the value has changed.
                if self?.isConnected != newStatus {
                    self?.isConnected = newStatus
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    deinit {
        monitor.cancel()
    }
}
