
import Foundation
import FirebaseFirestore

class Utils {
    class func UDSET(data: Any, key: String) {
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func UDValue( key: String) -> Any {
        return UserDefaults.standard.value(forKey: key) as Any
    }
    
    class func UDValueBool( key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) as? Bool ?? false
    }
    
    class func UDValueTrueBool( key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) as? Bool ?? true
    }
    
    class func UDRemove( key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func UDRemoveAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    class func convertTimestampToDate(input : Timestamp) -> Date? {
        let seconds = input.seconds
        
        let dateFromSeconds = Date(timeIntervalSince1970: TimeInterval(seconds))
        return dateFromSeconds
    }
    
    class func getLoggedAccount() -> AccountModel {
        let dict = [
            K.AccountTable.idField : UDValue(key: K.AppConstant.loggedId),
            K.AccountTable.imageUrlField : UDValue(key: K.AppConstant.loggedImageUrl),
            K.AccountTable.userNameField : UDValue(key: K.AppConstant.loggedUserName),
            K.AccountTable.phoneField : UDValue(key: K.AppConstant.loggedPhone),
            K.AccountTable.emailField : UDValue(key: K.AppConstant.loggedEmail),
            K.AccountTable.streamTokenField : UDValue(key: K.AppConstant.loggedStreamToken)
        ]
        return AccountModel(dict: dict)
    }
    
    class func setLoggedAccount(dict: [String: Any]) {
        Utils.UDSET(data: dict[K.AccountTable.idField] ?? "", key: K.AppConstant.loggedId)
        Utils.UDSET(data: dict[K.AccountTable.userNameField] ?? "", key: K.AppConstant.loggedUserName)
        Utils.UDSET(data: dict[K.AccountTable.imageUrlField] ?? "" , key: K.AppConstant.loggedImageUrl)
        Utils.UDSET(data: dict[K.AccountTable.phoneField] ?? "", key: K.AppConstant.loggedPhone)
        Utils.UDSET(data: dict[K.AccountTable.emailField] ?? "", key: K.AppConstant.loggedEmail)
        Utils.UDSET(data: dict[K.AccountTable.streamTokenField] ?? "", key: K.AppConstant.loggedStreamToken)
    }
}
