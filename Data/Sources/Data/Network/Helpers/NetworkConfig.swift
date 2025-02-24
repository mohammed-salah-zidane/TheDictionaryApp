//
//  NetworkConfig.swift
//  Data
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation

public struct NetworkConfig {
    // Example: default 30s timeout
    public static let timeout: TimeInterval = 30
    
    // Default headers if you want them
    public static let defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
}
