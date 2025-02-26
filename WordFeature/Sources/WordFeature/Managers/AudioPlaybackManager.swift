//
//  AudioPlaybackManager.swift
//  WordFeature
//
//  Created by Mohamed Salah on 24/02/2025.
//

import Foundation
import Combine
import Domain
import AVFoundation

/// Manages audio playback functionality
@MainActor
public class AudioPlaybackManager: AudioPlaybackManagerProtocol {
    // MARK: - Published Properties
    @Published private(set) public var isPlaying: Bool = false
    
    // MARK: - Public Properties
    public var isPlayingPublisher: AnyPublisher<Bool, Never> {
        $isPlaying.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private let audioService: AudioService
    private var currentAudioURL: String?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(audioService: AudioService) {
        self.audioService = audioService
        setupNotifications()
    }
    
    deinit {
        MainActor.assumeIsolated {
            cleanupResources()
        }
    }
    
    // MARK: - Public Methods
    public func playAudio(from url: String) {
        if isPlaying && currentAudioURL == url {
            stopAudio()
        } else {
            Task { [weak self] in
                await self?.startPlayback(url)
            }
        }
    }
    
    public func stopAudio() {
        player?.pause()
        removeTimeObserver()
        player = nil
        isPlaying = false
        currentAudioURL = nil
    }
    
    // MARK: - Private Methods
    private func cleanupResources() {
        stopAudio()
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startPlayback(_ url: String) async {
        currentAudioURL = url
        isPlaying = true
        
        do {
            let player = try await audioService.preparePlayer(from: url)
            
            // Check if we're still supposed to play this URL
            guard currentAudioURL == url else {
                return
            }
            
            self.player = player
            setupTimeObserver()
            
            // Add completion observer
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
            
            player.play()
        } catch {
            isPlaying = false
            currentAudioURL = nil
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                // Explicitly run on MainActor
                Task { @MainActor [weak self] in
                    self?.handleAudioInterruption(notification)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTimeObserver() {
        removeTimeObserver()
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            // Explicitly run on MainActor to handle Sendable closure requirements
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                guard let player = self.player,
                      let duration = player.currentItem?.duration,
                      !duration.isIndefinite else { return }
                
                if time >= duration {
                    self.stopAudio()
                }
            }
        }
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        // Since this is called on main thread by AVPlayer
        Task { @MainActor [weak self] in
            self?.stopAudio()
        }
    }
    
    private func handleAudioInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            stopAudio()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                if let url = currentAudioURL {
                    Task { [weak self] in
                        await self?.startPlayback(url)
                    }
                }
            }
        @unknown default:
            break
        }
    }
}
