
import Foundation
import FirebaseFirestore

struct ContactModel: Identifiable {
    
    var id: String
    var content : String
    var sendedAt : Date
    var fromId : String
    var toId : String
    var status : Int
    var imageUrl : String
    var userName : String
    var type: MessageType
    
    init(dict : NSDictionary) {
        self.id = UUID().uuidString
        self.content = dict.value(forKey: K.ContactTable.contentField) as? String ?? ""
        self.sendedAt = Utils.convertTimestampToDate(input: dict.value(forKey: K.ContactTable.sendedAtField) as? Timestamp ?? Timestamp()) ?? Date()
        self.fromId = dict.value(forKey: K.ContactTable.fromIdField) as? String ?? ""
        self.toId = dict.value(forKey: K.ContactTable.toIdField) as? String ?? ""
        self.status = dict.value(forKey: K.ContactTable.statusField) as? Int ?? 0
        self.imageUrl = dict.value(forKey: K.ContactTable.imageUrlField) as? String ?? ""
        self.userName = dict.value(forKey: K.ContactTable.userNameField) as? String ?? ""
        self.type = (dict.value(forKey: K.MessageTable.typeField) as? Int ?? 0).parseMessageTypeFromInt()
    }
}

extension ContactModel {
    init (from search : SearchModel){
        self.imageUrl = search.imageUrl
        self.userName = search.userName
        self.toId = search.searchUserId
        self.content = ""
        self.sendedAt = Date()
        self.status = 0
        self.fromId = Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
        self.type = .text
        self.id = UUID().uuidString
    }
}
