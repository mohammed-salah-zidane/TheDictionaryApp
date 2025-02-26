//
//  ErrorHandlerProtocol.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Combine

/// Protocol defining error handling functionality
@MainActor public protocol ErrorHandlerProtocol: AnyObject, Sendable {
    /// Current error message
    var errorMessage: String? { get }
    
    /// Whether to show the error alert
    var showErrorAlert: Bool { get }
    
    /// Publisher for error messages
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }
    
    /// Publisher for showing error alerts
    var showErrorAlertPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Shows an error message
    func showError(_ message: String)
    
    /// Shows an appropriate error message based on a repository error
    func handleRepositoryError(_ error: Error, for word: String)
    
    /// Reset error
    func resetError()
}
