
import Foundation
import FirebaseFirestore

class ContactViewModel : ObservableObject{
    let db = Firestore.firestore()
    static var shared : ContactViewModel = ContactViewModel()
    
    @Published var senderId : String = ""
    @Published var receiverId : String = ""
    @Published var contactList : [ContactModel] = []
    
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    init(){
        getContactByUserId()
    }
    
    func getContactByUserId() {
        let userId = Utils.UDValue(key: K.AppConstant.loggedId) as! String
        db.collection(K.ContactTable.collectionName)
            .document(userId)
            .collection(K.ContactTable.messagesField)
            .addSnapshotListener { querySnapshot, error in
                if error != nil {
                    self.errorMessage = error!.localizedDescription
                    self.showError = true
                    print("Error when get message data: \(error!.localizedDescription)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    if change.type == .added {
                        self.contactList.insert(ContactModel(dict: data as NSDictionary), at: 0)
                    } else if change.type == .modified {
                        self.updateContactList(data as NSDictionary)
                    }
                })
            }
    }
    
    private func updateContactList(_ data: NSDictionary) {
        let index = contactList.firstIndex { contact in
            contact.toId == data.value(forKey: K.ContactTable.toIdField) as? String ?? ""
        }
        
        let newContact = ContactModel(dict: data)
        if let index = index {
            contactList.remove(at: index)
        }
        contactList.insert(newContact, at: 0)
    }
}
