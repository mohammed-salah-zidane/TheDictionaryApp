import Foundation
import Combine

@MainActor public protocol NetworkStateManagerProtocol: AnyObject, Sendable {
    var isOnline: Bool { get }
    var isOnlinePublisher: AnyPublisher<Bool, Never> { get }
    var networkStatusMessage: String { get }
    var showNetworkStatus: Bool { get }
    
    func dismissNetworkStatus()
}
