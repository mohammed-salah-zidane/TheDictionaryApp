//
//  AudioService.swift
//  Domain
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import AVFoundation

/// Protocol defining audio playback operations.
/// This abstracts platform-specific audio handling from the domain logic.
@MainActor
public protocol AudioService {
    /// Prepares a player for the specified URL
    /// - Parameter urlString: String representation of the audio URL
    /// - Returns: An initialized AVPlayer
    /// - Throws: Error if URL is invalid or player creation fails
    func preparePlayer(from urlString: String) async throws -> AVPlayer
    
    /// Stops any currently playing audio
    func stop()
}

/// Implementation of the AudioService protocol using AVFoundation.
/// Note: This implementation is tied to a specific framework (AVFoundation)
/// and might be better placed in an Infrastructure or Feature layer.
@MainActor
public final class AudioServiceImpl: AudioService {
    /// The audio player instance
    private var player: AVPlayer?
    
    public init() {}
    
    public func preparePlayer(from urlString: String) async throws -> AVPlayer {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "AudioService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        // Configure audio session
        try await configureAudioSession()
        
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        self.player = player
        return player
    }
    
    public func stop() {
        player?.pause()
        player = nil
    }
    
    private func configureAudioSession() async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }
}
