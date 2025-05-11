
import StreamVideo
import Foundation
import StreamVideoSwiftUI
import Combine

class CustomCallViewModel: ObservableObject {
    static var shared = CustomCallViewModel()
    
    @Published var streamVideo: StreamVideo?
    @Injected(\.callKitAdapter) var callKitAdapter
    @Injected(\.callKitPushNotificationAdapter) var callKitPushNotificationAdapter
    @Published var isReady = false
    @Published var callViewModel: CallViewModel?
    
    private var streamVideoUI: StreamVideoUI?
    var lastVoIPToken: String?
    var voIPTokenObservationCancellable: AnyCancellable?
    
    func onAppear(
        apiKey: String,
        userId: String
    ) {
        guard !isReady else { return }
        
        LogConfig.level = .debug
        
        TokenManager.shared.fetchToken(for: userId) { [self] result, message in
            if result {
                streamVideo = .init(
                    apiKey: apiKey,
                    user: .init(id: userId),
                    token: .init(stringLiteral: message!),
                    pushNotificationsConfig: .default
                )
                
                Task{ @MainActor in
                    callViewModel = .init(
                        callSettings: .init(
                            audioOn: true,
                            videoOn: false,
                            speakerOn: false
                        )
                    )
                }
                
                streamVideoUI = .init(streamVideo: streamVideo!)
                
                callKitAdapter.streamVideo = streamVideo
                
                voIPTokenObservationCancellable = callKitPushNotificationAdapter
                    .$deviceToken
                    .sink { [streamVideo = streamVideo] updatedDeviceToken in
                        Task { [weak self] in
                            if let lastVoIPToken = self?.lastVoIPToken {
                                try await streamVideo!.deleteDevice(id: lastVoIPToken)
                            }
                            try await streamVideo!.setVoipDevice(id: updatedDeviceToken)
                            self?.lastVoIPToken = updatedDeviceToken
                        }
                    }
                
                callKitAdapter.registerForIncomingCalls()
                
                Task { @MainActor in
                    do {
                        try await streamVideo!.connect()
                        isReady = true
                    } catch {
                        log.error(error)
                        isReady = false
                    }
                }
            }
        }
    }
}
