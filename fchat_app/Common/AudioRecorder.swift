
import SwiftUI
import AVFAudio
import AVKit

struct AudioRecorder: View {
    
    @Binding var showError : Bool
    @Binding var errorMessage : String
    @Binding var isRecording : Bool
    @Binding var elapsedTime: TimeInterval
    
    let actionHandler: (_ action: MessageInputView.UserAction) -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                actionHandler(.recordAudio)
            }, label: {
                if isRecording {
                    Image(systemName: "pause.fill")
                        .padding(.all, 5)
                        .foregroundColor(.white)
                        .background(.red)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.primaryOrange)
                        .font(.system(size: 22))
                }
            })
            if isRecording {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.red)
                    Text("Đang ghi")
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                    Spacer()
                    Text(elapsedTime.formatElapsedTime)
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                }
                .padding(.all, 8)
                .clipShape(Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.5), lineWidth: 1)
                        .fill(.orange.opacity(0.1))
                )
            }
        }
    }
}
