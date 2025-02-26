import Foundation
import Combine
import Data

@MainActor
public class NetworkStateManager: NetworkStateManagerProtocol {
    @Published private(set) public var isOnline: Bool = true
    @Published private(set) public var networkStatusMessage: String = ""
    @Published private(set) public var showNetworkStatus: Bool = false
    
    private let networkMonitor: NetworkMonitor
    private var networkStatusTask: Task<Void, Never>?
    private var wasOffline: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    public var isOnlinePublisher: AnyPublisher<Bool, Never> {
        $isOnline.eraseToAnyPublisher()
    }
    
    public init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                self.isOnline = isConnected
                self.handleNetworkStatusChange()
            }
            .store(in: &cancellables)
    }
    
    private func handleNetworkStatusChange() {
        networkStatusTask?.cancel()
        
        if isOnline {
            if wasOffline {
                networkStatusMessage = "You're back online"
                showNetworkStatus = true
                scheduleNetworkStatusDismissal()
            }
            wasOffline = false
        } else {
            networkStatusMessage = "You're offline. Showing cached results."
            showNetworkStatus = true
            scheduleNetworkStatusDismissal()
            wasOffline = true
        }
    }
    
    private func scheduleNetworkStatusDismissal() {
        networkStatusTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run { self?.showNetworkStatus = false }
        }
    }
    
    public func dismissNetworkStatus() {
        showNetworkStatus = false
    }
}
