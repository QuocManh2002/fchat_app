
import Foundation
import AVFoundation

final class AudioMessagePlayer: ObservableObject {
    private var player: AVPlayer?
    private(set) var currentURL: URL?
    
    private var playerItem: AVPlayerItem?
    @Published private(set) var playbackState = PlaybackState.stopped
    @Published private(set) var currentTime = CMTime.zero
    private var currentTimeObserver: Any?
    
    deinit {
        tearDown()
    }
    
    func playAudio(from url: URL){
        if let currentURL = currentURL, currentURL == url {
            resumePlaying()
        } else {
            currentURL = url
            playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player!.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayback()
        }
    }
    
    private func resumePlaying(){
        if playbackState == .paused || playbackState == .stopped {
            player?.play()
            playbackState = .playing
        }
    }
    
    func pauseAudio(){
        player?.pause()
        playbackState = .paused
    }
    
    func seek(to timeInterval: TimeInterval){
        guard let player = player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    private func observeCurrentPlayerTime(){
        currentTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) {[weak self] time in
            self?.currentTime = time
        }
    }
    
    private func observeEndOfPlayback(){
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.stopAudioPlayer()
        }
    }
    
    private func stopAudioPlayer(){
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentTime = .zero
    }
    
    private func removeObserver(){
        guard let currentTimeObserver else {return}
        player?.removeTimeObserver(currentTimeObserver)
        self.currentTimeObserver = nil
    }
    
    private func tearDown(){
        removeObserver()
        player = nil
        playerItem = nil
        currentURL = nil
        
    }
}

extension AudioMessagePlayer {
    enum PlaybackState {
        case stopped, playing, paused
    }
}
