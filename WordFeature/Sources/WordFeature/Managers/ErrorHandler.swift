//
//  ErrorHandler.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Combine
import Domain
import Data

@MainActor
public class ErrorHandler: ErrorHandlerProtocol {
    // MARK: - Private Published Properties
    @Published private var _errorMessage: String?
    @Published private var _showErrorAlert: Bool = false
    
    // MARK: - Public Properties
    public var errorMessage: String? { _errorMessage }
    public var showErrorAlert: Bool { _showErrorAlert }
    
    public var errorMessagePublisher: AnyPublisher<String?, Never> {
        $_errorMessage.eraseToAnyPublisher()
    }
    
    public var showErrorAlertPublisher: AnyPublisher<Bool, Never> {
        $_showErrorAlert.eraseToAnyPublisher()
    }
    
    public init() {}
    
    // MARK: - Public Methods
    public func showError(_ message: String) {
        _errorMessage = message
        _showErrorAlert = true
    }
    
    public func handleRepositoryError(_ error: Error, for word: String) {
        if let repositoryError = error as? RepositoryError {
            switch repositoryError {
            case .noDataFound:
                showError("No definition found for '\(word)'")
            case .networkError(let networkError):
                if let networkError = networkError as? NetworkError,
                   case .noInternetConnection = networkError {
                    showError("No internet connection. Showing cached results.")
                } else {
                    showError(repositoryError.localizedDescription)
                }
            default:
                showError(repositoryError.localizedDescription)
            }
        } else {
            showError(error.localizedDescription)
        }
    }
    
    public func resetError() {
        _errorMessage = nil
        _showErrorAlert = false
    }
}
