
import Foundation
import FirebaseFirestore

class ProfileViewModel : ObservableObject{
    static var shared : ProfileViewModel = ProfileViewModel()
    let db = Firestore.firestore()
    
    @Published var loggedAccount : AccountModel = AccountModel(dict: [:])
    
    @Published var errorMessage : String = ""
    @Published var showError : Bool = false
    
    init(){
//        getCurrentProfile()
    }
    
    private func getCurrentProfile() {
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as? String ?? ""
        db.collection(K.AccountTable.collectionName).document(userId).addSnapshotListener { querySnapshot, error in
            if error != nil {
                self.showError = true
                self.errorMessage = error!.localizedDescription
                return
            }
            if let document = querySnapshot {
                self.loggedAccount = AccountModel(dict: document.data()!)
            }
        }
    }
}
