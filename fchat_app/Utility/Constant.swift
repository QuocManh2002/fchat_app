
import Foundation
struct K {
    
    static let tabbarItems : [(index: Int, image: String, title: String)] = [
        (0, "ellipsis.message.fill", "Tin nhắn"),
        (1, "phone.fill", "Cuộc gọi"),
        (2, "person.fill", "Hồ sơ"),
    ]
    
    struct AppConstant{
        static let appName = "F-Chat"
        
        static let userLogin = "userLogin"
        static let setUpAccount = "setUpAccount"
        static let loggedId = "loggedId"
        static let loggedImageUrl = "loggedImageUrl"
        static let loggedUserName = "loggedUserName"
        static let loggedPhone = "loggedPhone"
        static let loggedEmail = "loggedEmail"
        static let numOfMessagePerPage = 15
        static let loggedStreamToken = "loggedStreamToken"
        
    }
    
    struct ErrorMessages {
        static let fileTooLarge = "Dung lượng file lớn hon 20MB. Vui lòng chọn lại file khác" 
    }
    
    struct ImageUrl {
        static let appLogo = "app_logo"
        static let noImage = "no-image"
    }
    
    struct ColorAssets {
        static let lightGray = "lightGray"
        static let primaryText = "text_color"
        static let lightText = "light_text_color"
        static let systemColor = "system_color"
    }
    
    // Firestore table field
    
    struct AccountTable {
        static let collectionName = "accounts"
        static let idField = "id"
        static let userNameField = "userName"
        static let emailField = "email"
        static let phoneField = "phone"
        static let imageUrlField = "imageUrl"
        static let statusField = "status"
        static let streamTokenField = "streamToken"
    }
    
    struct SearchTable {
        static let collectionName = "searchs"
        static let idField = "id"
        static let userNameField = "userName"
        static let imageUrlField = "imageUrl"
        static let createdAtField = "createdAt"
        static let userIdField = "userId"
        static let searchUserId = "searchUserId"
        static let searchPhone = "phone"
        static let statusField = "status"
    }
    
    struct MessageTable {
        static let collectionName = "messages"
        static let idField = "id"
        static let sendedAtField = "sendedAt"
        static let senderIdField = "senderId"
        static let receiverIdField = "receiverId"
        static let contentField = "content"
        static let contactIdField = "contactId"
        static let typeField = "type"
        static let statusField = "status"
        static let thumbnailUrlField = "thumbnailUrl"
        static let thumbnailSizeField = "thumbnailSize"
        static let audioDurationField = "audioDuration"
        static let senderReactionField = "senderReaction"
        static let receiverReactionField = "receiverReaction"
    }
    
    struct ContactTable {
        static let collectionName = "contacts"
        static let sendedAtField = "sendedAt"
        static let fromIdField = "fromId"
        static let toIdField = "toId"
        static let contentField = "content"
        static let statusField = "status"
        static let imageUrlField = "imageUrl"
        static let userNameField = "userName"
        static let typeField = "type"
        static let messagesField = "messages"
    }
    
    // Hard data
    
    static let imageUrl = "https://th.bing.com/th/id/R.3cdf76996221555ae7dfd24d9ab8cdd3?rik=x6E9RSpA%2bj3UPQ&pid=ImgRaw&r=0"
    static let userName = "Jackson"
    static let userPhone = "0373519580"

    static let myStreamApiKey = ""
    static let allowCallRingingWhileInCall = false
}
