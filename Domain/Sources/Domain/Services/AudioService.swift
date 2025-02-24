import Foundation
import AVFoundation

@MainActor
public protocol AudioService {
    func play(from url: String)
    func stop()
}

@MainActor
public final class AudioServiceImpl: AudioService {
    private var player: AVPlayer?
    
    public init() {}
    
    public func play(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Ensure we're on the main thread
        if #available(iOS 13.0, *) {
            Task { @MainActor in
                player?.play()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func stop() {
        // Ensure we're on the main thread
        Task { @MainActor in
            player?.pause()
            player = nil
        }
    }
}
