
import Foundation
import FirebaseFirestore
import Combine
import PhotosUI
import SwiftUI
import StreamVideo
import StreamVideoSwiftUI


class MessageViewModel : ObservableObject{
    
    let db = Firestore.firestore()
    let mainVM = MainViewModel.shared
    let contactVM = ContactViewModel.shared
    
    @Published var contact : ContactModel
    @Published var txtMessage : String = ""
    @Published var messageList : [MessageModel] = []
    
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    @Published var isShowPhotoPicker: Bool = false
    @Published var mediaPlayerState: (show: Bool, player: AVPlayer?, url: URL?, type: MediaAttachmentType) = (false, nil, nil, .photo(UIImage()))
    @Published var isRecording: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var scrollToBottom: (scroll: Bool, isAnimated: Bool) = (false, false)
    @Published var isPaginatable: Bool = true
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var firstMessage: MessageModel?
    private var currentCursor: DocumentSnapshot?
    private var paginationListener: ListenerRegistration?
    private var scrollToLastListener: ListenerRegistration?
    private var callId: String?
    
    private let audioRecorderService = AudioRecorderService()
    private var subscriptions = Set<AnyCancellable>()
    
    var isShowMediaAttachmentView: Bool {
        return !photoPickerItems.isEmpty || !mediaAttachments.isEmpty
    }
    
    var isAvailableContent: Bool {
        return !txtMessage.trimmingCharacters(in: .whitespaces).isEmpty || !photoPickerItems.isEmpty || !mediaAttachments.isEmpty
    }
    
    private var isInPreviewMode: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    init(contact: ContactModel){
        self.contact = contact
        if isInPreviewMode {
            messageList = [.stubSendMessage, .stubReceiveMessage, .stubSendMessage]
        } else {
            onPhotoPickerSeletion()
            setUpVoiceRecorderListener()
            getMessages()
            print(contact.fromId)
            print(contact.toId)
        }
    }
    
    deinit{
        subscriptions.forEach{$0.cancel()}
        subscriptions.removeAll()
        audioRecorderService.tearDown()
    }
    
    func getMessages() {
        if isPaginatable {
            getPagination() {
                self.paginationListener?.remove()
                self.paginationListener = nil
                
                let userId = Utils.UDValue(key: K.AppConstant.loggedId) as! String
                self.scrollToLastListener = self.db.collection(K.MessageTable.collectionName)
                    .document(userId)
                    .collection(self.contact.toId)
                    .order(by: K.MessageTable.sendedAtField)
                    .addSnapshotListener { querySnapshot, error in
                        if error != nil {
                            self.errorMessage = error!.localizedDescription
                            self.showError = true
                            print("Error when get message data: \(error!.localizedDescription)")
                            return
                        }
                        
                        querySnapshot?.documentChanges.forEach({ change in
                            let data = change.document.data()
                            let message = self.parseFromFirebase(dict: data as NSDictionary)
                            let lastMessage = self.messageList.last
                            
                            if change.type == .added && (self.messageList.isEmpty || message.sendedAt > lastMessage!.sendedAt)  {
                                self.messageList.append(message)
                                self.scrollToBottom(false)
                            }
                            
                            if change.type == .modified {
                                self.addReactionToMessageList(data as NSDictionary)
                            }
                        })
                    }
            }
        }
    }
    
    func getPagination( completion: @escaping () -> Void){
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as! String
        
        scrollToLastListener?.remove()
        scrollToLastListener = nil
        
        if currentCursor == nil {
            getFirstMessage { message in
                self.firstMessage = message
            }
        }
        
        let query =
        currentCursor == nil ?
        db.collection(K.MessageTable.collectionName)
            .document(userId)
            .collection(contact.toId)
            .order(by: K.MessageTable.sendedAtField, descending: true)
            .limit(to: Int(K.AppConstant.numOfMessagePerPage)) :
        db.collection(K.MessageTable.collectionName)
            .document(userId)
            .collection(contact.toId)
            .order(by: K.MessageTable.sendedAtField, descending: true)
            .limit(to: Int(K.AppConstant.numOfMessagePerPage))
            .start(afterDocument: currentCursor!)
        
        paginationListener = query.addSnapshotListener { [self] querySnapshot, error in
            if error != nil {
                self.errorMessage = error!.localizedDescription
                self.showError = true
                print("Error when get message data: \(error!.localizedDescription)")
                return
            }
            
            
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    self.messageList.insert(self.parseFromFirebase(dict: data as NSDictionary), at: 0)
                }
            })
            
            if self.currentCursor == nil {
                self.scrollToBottom(false)
            }
            
            self.currentCursor = querySnapshot?.documents.last
            
            if let currentCursor = querySnapshot?.documents.last {
                self.currentCursor = currentCursor
                let currentCursorData = currentCursor.data() as NSDictionary
                let currentCursorId = currentCursorData[K.MessageTable.idField] as? String ?? ""
                self.isPaginatable = self.firstMessage != nil && currentCursorId != self.firstMessage!.id
            } else {
                self.isPaginatable = false
            }
            completion()
        }
    }
    
    func getFirstMessage(completion: @escaping(MessageModel?) -> Void) {
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as! String
        db.collection(K.MessageTable.collectionName)
            .document(userId)
            .collection(contact.toId)
            .order(by: K.MessageTable.sendedAtField)
            .limit(to: 1)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    self.errorMessage = error!.localizedDescription
                    self.showError = true
                    print("Error when get message data: \(error!.localizedDescription)")
                    return
                }
                
                if let messageData = querySnapshot?.documents.first?.data()
                {
                    let message = self.parseFromFirebase(dict: messageData as NSDictionary)
                    print("firstMessage: \(message.id)")
                    completion(message)
                }
                else {completion(nil)}
            }
    }
    
    func sendMessage() async throws {
        for attachment in mediaAttachments {
            try? await handleSendMessage(attachment)
        }
        
        if !txtMessage.trimmingCharacters(in: .whitespaces).isEmpty {
            try? await handleSendMessage(nil)
        }
        
        self.mediaAttachments.removeAll()
        self.photoPickerItems.removeAll()
        txtMessage = ""
        await UIApplication.dismissKeyboard()
        scrollToBottom(true)
    }
    
    func handleSendMessage(_ attachment: MediaAttachment?) async throws {
        let messageId = UUID().uuidString
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
        
        var messageData = [
            K.MessageTable.idField : messageId,
            K.MessageTable.contentField : txtMessage,
            K.MessageTable.sendedAtField : Date(),
            K.MessageTable.senderIdField : userId,
            K.MessageTable.receiverIdField : contact.toId,
            K.MessageTable.statusField : 0,
            K.MessageTable.typeField : 0
        ] as [String : Any]
        
        if attachment != nil {
            if attachment!.type == .video(UIImage(), .stubURL){
                guard let videoURL = attachment?.fileURL, let thumbnail = try? await videoURL.generateVideoThumbnail() else {return}
                try await MediaHelper().upLoadMediaToFirebase(MediaAttachment(id: UUID().uuidString, type: .photo(thumbnail))) { result in
                    switch result {
                    case .success(let downloadURL):
                        messageData[K.MessageTable.thumbnailUrlField] = downloadURL
                        messageData[K.MessageTable.thumbnailSizeField] = [thumbnail.size.width, thumbnail.size.height]
                        break
                    case .failure(let error):
                        self.showError = true
                        self.errorMessage = error.localizedDescription
                        return
                    }
                }
            }
            try await MediaHelper().upLoadMediaToFirebase(attachment!) { result in
                switch result {
                case .success(let downloadUrl):
                    if attachment!.type == .photo(UIImage()) {
                        messageData[K.MessageTable.thumbnailSizeField] = [attachment!.thumbnail.size.width, attachment!.thumbnail.size.height]
                    }
                    if attachment!.type == .audio(.stubURL, .stubTimeInterval) {
                        messageData[K.MessageTable.audioDurationField] = attachment!.audioDuration
                    }
                    messageData[K.MessageTable.contentField] = downloadUrl
                    messageData[K.MessageTable.typeField] = self.getMessageType(attachment!)
                    self.serviceCallSendMessage(messageData: messageData)
                    break
                case .failure(let error):
                    self.showError = true
                    self.errorMessage = error.localizedDescription
                    return
                }
            }
            
        } else {
            serviceCallSendMessage(messageData: messageData)
        }
        
    }
    
    private func serviceCallSendMessage(messageData : [String : Any]){
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
        
        let fromDocument = db.collection(K.MessageTable.collectionName).document(userId).collection(contact.toId).document(messageData[K.MessageTable.idField] as! String)
        
        fromDocument.setData(messageData){ error in
            if error != nil {
                self.errorMessage = error!.localizedDescription
                self.showError = true
                print("Error when send message: \(error!.localizedDescription)")
                return
            }
        }
        
        let toDocument = db.collection(K.MessageTable.collectionName).document(contact.toId).collection(userId).document(messageData[K.MessageTable.idField] as! String)
        
        toDocument.setData(messageData){ error in
            if error != nil {
                self.errorMessage = error!.localizedDescription
                self.showError = true
                print("Error when send message: \(error!.localizedDescription)")
                return
            }
        }
        addRecentMessage(messageData: messageData)
        txtMessage = ""
    }
    
    private func addRecentMessage(messageData : [String : Any]){
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as! String
        
        
        let fromDocument = db.collection(K.ContactTable.collectionName)
            .document(userId)
            .collection(K.ContactTable.messagesField)
            .document(contact.toId)
        
        let fromContactData = generateContactData(messageData: messageData, isFromContact: true)
        
        fromDocument.setData(fromContactData){ error in
            if error != nil {
                self.showError = true
                self.errorMessage = error!.localizedDescription
                print("Error when add contact data: \(error!.localizedDescription)")
                return
            }
        }
        
        let toDocument = db.collection(K.ContactTable.collectionName)
            .document(contact.toId)
            .collection(K.ContactTable.messagesField)
            .document(userId)
        
        let toContactData = generateContactData(messageData: messageData, isFromContact: false)
        
        toDocument.setData(toContactData){ error in
            if error != nil {
                self.showError = true
                self.errorMessage = error!.localizedDescription
                print("Error when add contact data: \(error!.localizedDescription)")
                return
            }
        }
    }
    
    private func setUpVoiceRecorderListener(){
        audioRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecording = isRecording
            }.store(in: &subscriptions)
        
        audioRecorderService.$elaspedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elapsedTime in
                self?.elapsedTime = elapsedTime
            }.store(in: &subscriptions)
    }
    
    private func toggleAudioRecorder(){
        if audioRecorderService.isRecording {
            audioRecorderService.stopRecording {[weak self] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            audioRecorderService.startRecording()
        }
    }
    
    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval){
        guard let audioURL = audioURL else {return}
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        self.mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    private func onPhotoPickerSeletion() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self = self else {return}
            let audioRecordings = mediaAttachments.filter({ $0.type == .audio(.stubURL, .stubTimeInterval) })
            self.mediaAttachments = audioRecordings
            Task{
                await self.parsePhotoPickerItems(photoItems)
            }
        }.store(in: &subscriptions)
    }
    
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for item in photoPickerItems {
            if item.isVideo {
                if let movie = try? await item.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnail = try? await movie.url.generateVideoThumbnail(),
                   let itemIdentifier = item.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnail, movie.url))
                    mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try? await item.loadTransferable(type: Data.self),
                    let thumbnail = UIImage(data: data),
                    let itemIdentifier = item.itemIdentifier
                else {return}
                
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }
    
    func dismissMediaPlayer(){
        mediaPlayerState.player?.replaceCurrentItem(with: nil)
        mediaPlayerState.player = nil
        mediaPlayerState.url = nil
        mediaPlayerState.show = false
    }
    
    func showMediaPlayer(_ url: URL, _ attachmentType: MediaAttachmentType){
        print(url.absoluteString)
        mediaPlayerState.player = AVPlayer(url: url)
        mediaPlayerState.url = url
        mediaPlayerState.type = attachmentType
        mediaPlayerState.show = true
    }
    
    func handleMediaAttachmentView(_ action: MediaAttachmentView.UserAction){
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else {return}
            showMediaPlayer(fileURL, attachment.type)
        case .remove(let attachment):
            removeAttachment(attachment)
            guard let fileURL = attachment.fileURL else {return}
            if attachment.type == .audio(.stubURL, .stubTimeInterval){
                audioRecorderService.deleteRecording(at: fileURL)
            }
        }
    }
    
    private func removeAttachment(_ attachment: MediaAttachment){
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == attachment.id }) else {return}
        mediaAttachments.remove(at: attachmentIndex)
        
        guard let photoIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == attachment.id }) else {return}
        photoPickerItems.remove(at: photoIndex)
    }
    
    func handleMessageInputView(_ action: MessageInputView.UserAction) async throws {
        switch action {
        case .sendMessage:
            try await sendMessage()
        case .mediaPicker:
            isShowPhotoPicker = true
        case .recordAudio:
            toggleAudioRecorder()
        }
    }
    
    private func getMessageType(_ attachment: MediaAttachment) -> Int{
        switch attachment.type {
        case .photo( _):
            return 1
        case .audio( _, _):
            return 2
        case .video( _, _):
            return 3
        }
    }
    
    func handleMessageAction(_ message: MessageModel){
        showMediaPlayer(URL(string: message.content) ?? .stubURL, message.type.toMediaAttachmentType()!)
    }
    
    private func scrollToBottom(_ animated: Bool){
        scrollToBottom.isAnimated = animated
        scrollToBottom.scroll = true
    }
    
    private func parseFromFirebase(dict : NSDictionary) ->  MessageModel{
        let id = dict.value(forKey: K.MessageTable.idField) as? String ?? ""
        let content = dict.value(forKey: K.MessageTable.contentField) as? String ?? ""
        let sendedAt = Utils.convertTimestampToDate(input: dict.value(forKey: K.MessageTable.sendedAtField) as? Timestamp ?? Timestamp()) ?? Date()
        let senderId = dict.value(forKey: K.MessageTable.senderIdField) as? String ?? ""
        let receiverId = dict.value(forKey: K.MessageTable.receiverIdField) as? String ?? ""
        let status = dict.value(forKey: K.MessageTable.statusField) as? Int ?? 0
        let type = (dict.value(forKey: K.MessageTable.typeField) as? Int ?? 0).parseMessageTypeFromInt()
        let isMyMessage = senderId == Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
        
        var thumbnailURL: String?
        var thumbnailSize: CGSize?
        var audioDuration: TimeInterval?
        var senderReaction: E.Reaction?
        var receiverReaction: E.Reaction?
        
        if let senderReactionInt = dict.value(forKey: K.MessageTable.senderReactionField) {
            senderReaction = (senderReactionInt as? Int ?? 0).parseReactionFromInt()
        }
        
        if let receiverReactionInt = dict.value(forKey: K.MessageTable.receiverReactionField) {
            receiverReaction = (receiverReactionInt as? Int ?? 0).parseReactionFromInt()
        }
        
        if type == .photo || type == .video {
            thumbnailURL = dict.value(forKey: K.MessageTable.thumbnailUrlField) as! String?
            let width = (dict.value(forKey: K.MessageTable.thumbnailSizeField) as! [CGFloat]).first
            let height = (dict.value(forKey: K.MessageTable.thumbnailSizeField) as! [CGFloat]).last
            let thumbnailWidth = UIWindowScene.current!.maxImageWidth
            let thumbnailHeight = CGFloat(height! * thumbnailWidth ) / width!
            thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
        } else if type == .audio {
            audioDuration = dict.value(forKey: K.MessageTable.audioDurationField) as? Double ?? 0
        }
        return MessageModel(id: id, content: content, sendedAt: sendedAt, senderId: senderId, receiverId: receiverId, status: status, type: type, thumbnailURL: thumbnailURL, thumbnailSize: thumbnailSize, audioDuration: audioDuration, senderReaction: senderReaction, receiverReaction: receiverReaction, isMyMessage: isMyMessage)
    }
    
    func isShowDateMessage(for message: MessageModel, at index: Int) -> Bool {
        let previousIndex = max(0, index - 1)
        let previousMessage = messageList[previousIndex]
        return !message.sendedAt.isSameDate(with: previousMessage.sendedAt) || index == 0
    }
    
    func reactMessage(message: MessageModel, reaction: E.Reaction){
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
        
        let fromDocument = db.collection(K.MessageTable.collectionName).document(userId).collection(contact.toId).document(message.id)
        let toDocument =
        db.collection(K.MessageTable.collectionName).document(contact.toId).collection(userId).document(message.id)
        
        if message.isMyMessage {
            fromDocument.updateData([K.MessageTable.senderReactionField : reaction.id])
            toDocument.updateData([K.MessageTable.senderReactionField : reaction.id])
        } else {
            fromDocument.updateData([K.MessageTable.receiverReactionField : reaction.id])
            toDocument.updateData([K.MessageTable.receiverReactionField : reaction.id])
        }
    }
    
    private func addReactionToMessageList(_ data: NSDictionary) -> Void {
        let index = messageList.firstIndex { message in
            message.id == data.value(forKey: K.MessageTable.idField) as? String ?? ""
        }
        
        if let reactionId = data.value(forKey: K.MessageTable.senderReactionField) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                self.messageList[index ?? 0].senderReaction = (reactionId as! Int).parseReactionFromInt()
            }
        }
        
        if let reactionId = data.value(forKey: K.MessageTable.receiverReactionField) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                self.messageList[index ?? 0].receiverReaction = (reactionId as! Int).parseReactionFromInt()
            }
        }
    }
    
    private func generateContactData(messageData: [String: Any], isFromContact: Bool) -> [String: Any] {
        var result: [String: Any] = [:]
        if isFromContact {
            result[K.ContactTable.fromIdField] = contact.fromId
            result[K.ContactTable.toIdField] = contact.toId
            result[K.ContactTable.imageUrlField] = contact.imageUrl
            result[K.ContactTable.userNameField] = contact.userName
        } else {
            result[K.ContactTable.fromIdField] = contact.toId
            result[K.ContactTable.toIdField] = contact.fromId
            result[K.ContactTable.imageUrlField] = mainVM.accountObj.imageUrl
            result[K.ContactTable.userNameField] = mainVM.accountObj.userName
        }
        result[K.ContactTable.contentField] = messageData[K.MessageTable.contentField]
        result[K.ContactTable.sendedAtField] = messageData[K.MessageTable.sendedAtField]
        result[K.ContactTable.typeField] = messageData[K.MessageTable.typeField]
        result[K.ContactTable.statusField] = messageData[K.MessageTable.statusField]
        return result
    }
}
