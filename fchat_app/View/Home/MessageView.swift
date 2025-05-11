
import SwiftUI
import AVKit
import AVFAudio
import PhotosUI
import StreamVideoSwiftUI
import StreamVideo

struct MessageView: View {

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var messageVM : MessageViewModel = MessageViewModel(contact: ContactModel(dict: [:]))
    @StateObject var audioMessagePlayer = AudioMessagePlayer()
    @StateObject var customCallVM = CustomCallViewModel.shared
    
    @State var callId: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            topAreaView()
            
            MessageListView(messageVM)
            
            Spacer()
            bottomAreaView()
            
        }
        .modifier(
            CallModifier(viewFactory: CustomViewFactory.shared, viewModel: customCallVM.callViewModel!)
        )
        .photosPicker(
            isPresented: $messageVM.isShowPhotoPicker,
            selection: $messageVM.photoPickerItems,
            maxSelectionCount: 6,
            photoLibrary: .shared())
        .alert(isPresented: $messageVM.showError, content: {
            Alert(title: Text(K.AppConstant.appName), message: Text(messageVM.errorMessage),
                  dismissButton: .default(Text("OK"))
            )
        })
        .animation(.easeInOut, value: messageVM.isShowPhotoPicker)
        .fullScreenCover(isPresented: $messageVM.mediaPlayerState.show){
            FullScreenMediaView(
                url: messageVM.mediaPlayerState.url,
                player: messageVM.mediaPlayerState.player,
                attachmentType: messageVM.mediaPlayerState.type
            ) {
                messageVM.dismissMediaPlayer()
            }
        }
        .onReceive(customCallVM.streamVideo!.state.$activeCall, perform: { activeCall in
            customCallVM.callViewModel!.setActiveCall(activeCall)
        })
        .onReceive(customCallVM.callViewModel!.$call) { call in
            if let call {
                Task{
                    for await event in call.subscribe(){
                        switch event{
                        case .typeCallSessionParticipantLeftEvent(_):
                            try await call.end()
                        default:
                            break
                        }
                    }
                }
                
            }
        }
        .environmentObject(audioMessagePlayer)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        
    }
    
    private func contentView() -> some View {
        
        ScrollViewReader{ scrollProxy in
            ScrollView{
                VStack{
                    ForEach(messageVM.messageList , id: \.id){ message in
                        MessageCell(message: message, isShowDateMessage: true){
                            messageVM.handleMessageAction(message)
                        }
                    }
                    HStack{Spacer()}
                        .id("id")
                }
                .onChange(of: messageVM.messageList){
                    withAnimation(.easeOut(duration: 0.5)){
                        scrollProxy.scrollTo("id", anchor: .bottom)
                    }
                }
            }
        }
        
    }
    
    private func topAreaView() -> some View {
        HStack{
            Button(action: {
                mode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.primaryWhite)
            }).padding(.trailing, 5)
            
            MyImage(url: messageVM.contact.imageUrl, height: 40, width: 40, isCircle: true)
                .padding(.trailing, 5)
            
            Text(messageVM.contact.userName)
                .font(.system(size: 25))
                .fontWeight(.bold)
                .foregroundColor(.primaryWhite)
            
            Spacer()
            
            Button(action: {}, label: {
                Image(systemName: "phone.fill")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.primaryWhite)
            }).padding(.trailing, 10)

            Button {
                if customCallVM.isReady {
                    customCallVM.callViewModel!.startCall(
                        callType: .default,
                        callId: generateCallId(),
                        members: [
                            .init(user: User(id: messageVM.contact.toId, name: messageVM.contact.userName)),
                            .init(user: User(id: MainViewModel.shared.accountObj.id, name: MainViewModel.shared.accountObj.userName))
                        ],
                        ring: true
                    )
                }
            } label: {
                Image(systemName: "video.fill")
                    .font(.system(size: 22))
                    .fontWeight(.bold)
                    .foregroundColor(.primaryWhite)
            }
        }
        .padding()
        .background(Color.primaryOrange)
        
    }
    
    private func bottomAreaView() -> some View {
        VStack{
            if messageVM.isShowMediaAttachmentView {
                VStack{
                    Divider()
                    MediaAttachmentView(mediaAttachment: messageVM.mediaAttachments){ action in
                        messageVM.handleMediaAttachmentView(action)
                    }
                    Divider()
                }
            }
            HStack{
                Button(action: {
                    messageVM.isShowPhotoPicker = true
                }, label: {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.primaryOrange)
                        .font(.system(size: 22))
                })
                .padding(.leading, 15)
                .disabled(messageVM.isRecording)
                .grayscale(messageVM.isRecording ? 0.8 : 0)
                
                MessageInputView(
                    txtMessage: $messageVM.txtMessage,
                    isRecording: $messageVM.isRecording,
                    elapsedTime: $messageVM.elapsedTime,
                    showError: $messageVM.showError,
                    errorMessage: $messageVM.errorMessage,
                    isAvailableContent: messageVM.isAvailableContent) { action in
                        Task {
                            try? await messageVM.handleMessageInputView(action)
                        }
                    }
            }
        }
    }
    
    private func generateCallId()-> String {
        return UUID()
            .uuidString
            .replacingOccurrences(of: "-", with: "")
            .prefix(10)
            .map(String.init)
            .joined()
    }
}

