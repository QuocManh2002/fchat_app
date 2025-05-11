
import Foundation
import FirebaseFirestore

struct MessageModel : Identifiable, Equatable{
    var id : String
    var content : String
    var sendedAt : Date
    var senderId : String
    var receiverId : String
    var status : Int
    var type : MessageType
    var thumbnailURL: String?
    var thumbnailSize: CGSize?
    var audioDuration: TimeInterval?
    var isMyMessage: Bool
    var senderReaction: E.Reaction?
    var receiverReaction: E.Reaction?
    
    init(dict : NSDictionary) {
        self.id = dict.value(forKey: K.MessageTable.idField) as? String ?? ""
        self.content = dict.value(forKey: K.MessageTable.contentField) as? String ?? ""
        self.sendedAt = Utils.convertTimestampToDate(input: dict.value(forKey: K.MessageTable.sendedAtField) as? Timestamp ?? Timestamp()) ?? Date()
        self.senderId = dict.value(forKey: K.MessageTable.senderIdField) as? String ?? ""
        self.receiverId = dict.value(forKey: K.MessageTable.receiverIdField) as? String ?? ""
        self.status = dict.value(forKey: K.MessageTable.statusField) as? Int ?? 0
        self.type = (dict.value(forKey: K.MessageTable.typeField) as? Int ?? 0).parseMessageTypeFromInt()
        self.isMyMessage = self.senderId == Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
    }
    
    init(id: String, content: String, sendedAt: Date, senderId: String, receiverId: String, status: Int, type: MessageType, thumbnailURL: String?, thumbnailSize: CGSize?, audioDuration: TimeInterval?, senderReaction: E.Reaction?, receiverReaction: E.Reaction?, isMyMessage: Bool) {
        self.id = id
        self.content = content
        self.sendedAt = sendedAt
        self.senderId = senderId
        self.receiverId = receiverId
        self.status = status
        self.type = type
        self.thumbnailURL = thumbnailURL
        self.thumbnailSize = thumbnailSize
        self.audioDuration = audioDuration
        self.senderReaction = senderReaction
        self.receiverReaction = receiverReaction
        self.isMyMessage = isMyMessage
    }
    
    static func == (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    
}

enum MessageType: Equatable {
    case text
    case photo
    case audio
    case video
    case admin
    
    var title: String {
        switch self {
        case .photo:
            return "Hình ảnh"
        case .audio:
            return "Tin nhắn thoại"
        case .video:
            return "Video"
        default:
            return "Tin nhắn"
        }
    }
    
    static func == (lhs: MessageType, rhs: MessageType) -> Bool {
        switch (lhs, rhs){
        case (.photo, .photo), (.video, .video), (.audio, .audio), (.text, .text):
            return true
        default:
            return false
        }
    }
    
    func toMediaAttachmentType() -> MediaAttachmentType? {
        switch self {
        case .photo:
            return .photo(UIImage())
        case .audio:
            return .audio(.stubURL, .stubTimeInterval)
        case .video:
            return .video(UIImage(), .stubURL)
        default:
            return nil
        }
    }
}

extension MessageModel {
    static var stubSendMessage: MessageModel {
        return MessageModel(id: "", content: "Hello", sendedAt: Date.now, senderId: "", receiverId: "", status: 0, type: .text, thumbnailURL: nil, thumbnailSize: nil, audioDuration: nil, senderReaction: .heart, receiverReaction: .like, isMyMessage: true)
    }
    
    static var stubReceiveMessage: MessageModel {
        return MessageModel(id: "", content: "Good bye", sendedAt: Date.now, senderId: "", receiverId: "", status: 0, type: .text, thumbnailURL: nil, thumbnailSize: nil, audioDuration: nil, senderReaction: .heart, receiverReaction: .heart, isMyMessage: false)
    }
}
