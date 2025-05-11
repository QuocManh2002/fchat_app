
import Foundation
import SwiftUI
import AVKit
import Kingfisher

struct MessageContentView : View {
    
    @EnvironmentObject private var audioMessagePlayer: AudioMessagePlayer
    @State private var playbackState: AudioMessagePlayer.PlaybackState = .stopped
    
    var content : String
    var type : MessageType
    var isMyMessage : Bool
    var imageHeight: CGFloat = 0
    var thumbnailURL: String?
    var audioDuration: TimeInterval?
    let actionHandler: () -> Void
    @State var isPlayingMedia : Bool = false
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    @State private var playbackTime = "00:00"
    @State private var isDraggingSlider = false
    
    init(content: String, type: MessageType, isMyMessage: Bool, imageHeight: CGFloat, thumbnailURL: String? = nil, audioDuration: TimeInterval? = nil, actionHandler: @escaping () -> Void) {
        self.content = content
        self.type = type
        self.isMyMessage = isMyMessage
        self.imageHeight = imageHeight
        self.thumbnailURL = thumbnailURL
        self.audioDuration = audioDuration
        self.actionHandler = actionHandler
        
        let audioDuration = audioDuration ?? 20
        self._sliderRange = State(wrappedValue: 0...audioDuration)
    }
    
    private var isCorrectAudioMessage: Bool {
        return audioMessagePlayer.currentURL?.absoluteString == content
    }
    
    
    var body: some View {
        switch type {
        case .text:
            textMessageView()
            
        case .photo:
            photoMessageView()
            
        case .video:
            videoMessageView()
            
        case .audio:
            audioMessageView()
        case .admin:
            Text("")
        }
    }
    
    private func textMessageView() -> some View {
        return Text(content)
            .font(.system(size: 18))
            .fontWeight(.semibold)
            .foregroundColor(isMyMessage ? .white : .black.opacity(0.8))
            .padding(10)
            .background(isMyMessage ? Color.primaryOrange : Color.primaryWhite)
            .cornerRadius(10)
    }
    
    private func photoMessageView() -> some View {
        return Button {
            actionHandler()
        } label: {
            KFImage(URL(string: content))
                .resizable()
                .placeholder{
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: UIWindowScene.current?.maxImageWidth, height: imageHeight)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)
        }
    }
    
    func videoMessageView() -> some View {
        return KFImage(URL(string: thumbnailURL ?? ""))
            .resizable()
            .placeholder{
                ProgressView()
            }
            .scaledToFill()
            .frame(width: UIWindowScene.current?.maxImageWidth, height: imageHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            .overlay {
                playButton()
            }
    }
    
    private func playButton() -> some View {
        return Button {
            actionHandler()
        } label: {
            Image(systemName: "play.fill")
                .scaledToFit()
                .imageScale(.small)
                .padding(20)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(.circle)
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func audioMessageView() -> some View {
        return HStack{
            Button(action: {
                handlePlayAudioMessage()
            }, label: {
                Image(systemName: playbackState == .playing ? "pause.fill" : "play.fill")
                    .foregroundColor(isMyMessage ? .white : .black.opacity(0.8))
            })
            
            Slider(value: $sliderValue, in: sliderRange){ editing in
                isDraggingSlider = editing
                if !editing && isCorrectAudioMessage {
                    audioMessagePlayer.seek(to: sliderValue)
                }
            }
            .tint(isMyMessage ? .white : .gray)
            
            
            Text(playbackState == .stopped ? audioDuration!.formatElapsedTime : playbackTime)
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .foregroundColor(isMyMessage ? .white : .black.opacity(0.8))
                .padding(.leading, 5)
        }
        .frame(maxWidth: UIWindowScene.current?.maxImageWidth)
        .padding(10)
        .background(isMyMessage ? Color.primaryOrange : Color.primaryWhite)
        .cornerRadius(10)
        .onReceive(audioMessagePlayer.$playbackState) { state in
            observePlaybackState(state)
        }
        .onReceive(audioMessagePlayer.$currentTime) { currentTime in
            guard audioMessagePlayer.currentURL?.absoluteString == content else {return}
            observeCurrentTime(currentTime)
        }
    }
}

extension MessageContentView {
    private func handlePlayAudioMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard let url = URL(string: content) else {return}
            audioMessagePlayer.playAudio(from: url)
        } else {
            audioMessagePlayer.pauseAudio()
        }
    }
    
    private func observePlaybackState(_ state: AudioMessagePlayer.PlaybackState) {
        if state == .stopped {
            playbackState = .stopped
            sliderValue = 0
        } else {
            if isCorrectAudioMessage {
                playbackState = state
            }
        }
    }
    
    private func observeCurrentTime(_ currentTime: CMTime) {
        guard !isDraggingSlider else {return}
        playbackTime = currentTime.seconds.formatElapsedTime
        sliderValue = currentTime.seconds
    }
}
