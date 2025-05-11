
import Foundation
struct SearchModel : Identifiable, Equatable{
    var id : String = ""
    var userName : String = ""
    var imageUrl : String = ""
    var createdAt : Date = Date()
    var userId : String = ""
    var searchUserId : String = ""
    var searchPhone : String = ""
    var streamToken : String = ""
    
    init(dict : NSDictionary) {
        self.id = dict.value(forKey: K.SearchTable.idField) as? String ?? ""
        self.userName = dict.value(forKey: K.SearchTable.userNameField) as? String ?? ""
        self.imageUrl = dict.value(forKey: K.SearchTable.imageUrlField) as? String ?? ""
        self.createdAt = (dict.value(forKey: K.SearchTable.createdAtField) as? String ?? "").stringDateToDate() ?? Date()
        self.userId = dict.value(forKey: K.SearchTable.userIdField) as? String ?? ""
        self.searchUserId = dict.value(forKey: K.AccountTable.idField) as? String ?? ""
        self.searchPhone = dict.value(forKey: K.SearchTable.searchPhone) as? String ?? ""
        self.streamToken = dict.value(forKey: K.AccountTable.streamTokenField) as? String ?? ""
    }
    
    static func == (lhs: SearchModel, rhs: SearchModel) -> Bool {
        return lhs.id == rhs.id
    }
}
