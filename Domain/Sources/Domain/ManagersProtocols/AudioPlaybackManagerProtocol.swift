//
//  AudioPlaybackManagerProtocol.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Combine

/// Protocol defining audio playback management functionality
@MainActor public protocol AudioPlaybackManagerProtocol: AnyObject, Sendable {
    /// Whether audio is currently playing
    var isPlaying: Bool { get }
    
    /// Publisher for audio playback state
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Plays audio from the given URL
    func playAudio(from url: String)
    
    /// Stops any currently playing audio
    func stopAudio()
}
