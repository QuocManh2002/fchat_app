
import Foundation
struct AccountModel : Identifiable, Equatable{
    var id : String = ""
    var userName : String = ""
    var imageUrl : String = ""
    var phone : String = ""
    var email : String = ""
    var streamToken : String = ""
    
    init(dict : [String : Any]) {
        self.id = dict[K.AccountTable.idField] as? String ?? ""
        self.userName = dict[K.AccountTable.userNameField] as? String ?? ""
        self.imageUrl = dict[K.AccountTable.imageUrlField] as? String ?? ""
        self.phone = dict[K.AccountTable.phoneField] as? String ?? ""
        self.email = dict[K.AccountTable.emailField] as? String ?? ""
        self.streamToken = dict[K.AccountTable.streamTokenField] as? String ?? ""
    }
    
    static func == (lhs: AccountModel, rhs: AccountModel) -> Bool {
        return lhs.id == rhs.id
    }
}
