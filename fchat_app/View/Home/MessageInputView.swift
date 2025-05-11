
import SwiftUI

struct MessageInputView: View {
    @Binding var txtMessage: String
    @Binding var isRecording : Bool
    @Binding var elapsedTime: TimeInterval
    @Binding var showError: Bool
    @Binding var errorMessage: String
    var isAvailableContent: Bool
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        HStack{
            AudioRecorder(
                showError: $showError,
                errorMessage: $errorMessage,
                isRecording: $isRecording,
                elapsedTime: $elapsedTime){ action in
                    actionHandler(action)
                }
            .padding(.horizontal, 5)
            
            if !isRecording {
                TextField("Aa", text: $txtMessage)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
            }
            Button(action: {
                actionHandler(.sendMessage)
            }, label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(isAvailableContent ? .primaryOrange : .gray)
                    .font(.system(size: 22))
            })
            .disabled(!isAvailableContent)
            .padding(.trailing, 15)
            .padding(.leading, 5)
        }
        .onChange(of: isRecording) { oldValue, newValue in
            if newValue{
                
            }
        }
    }
}

extension MessageInputView {
    enum UserAction {
        case sendMessage
        case mediaPicker
        case recordAudio
    }
}
