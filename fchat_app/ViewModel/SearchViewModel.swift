
import Foundation
import FirebaseFirestore

class SearchViewModel : ObservableObject{
    static var shared : SearchViewModel = SearchViewModel()
    let db = Firestore.firestore()
    
    @Published var txtSearch : String = ""
    @Published var recentSearchList : [SearchModel] = []
    @Published var searchResult : [SearchModel]?
    @Published var contact : ContactModel?
    
    @Published var isSearching = true
    @Published var showError = false
    @Published var errorMessage = ""
    
    init() {
        getRecentSearchList()
    }
    
    func searchAccount(){
        searchResult = nil
        self.db.collection(K.AccountTable.collectionName).whereField(K.AccountTable.phoneField, isEqualTo: self.txtSearch).limit(to: 1)
            .addSnapshotListener { querySnapshot, error in
                if error != nil{
                    self.showError = true
                    self.errorMessage = error!.localizedDescription
                    return
                }else{
                    if let snapshotDocument = querySnapshot?.documents{
                        if !snapshotDocument.isEmpty {
                            let data = snapshotDocument[0].data()
                            self.searchResult = [SearchModel(dict: data as NSDictionary)]
                        } else {
                            self.searchResult = []
                        }
                        self.isSearching = false
                        return
                    }
                }
            }
    }
    
    func getRecentSearchList(){
        let userId = Utils.UDValue(key: K.AppConstant.loggedId)
        
        self.db.collection(K.SearchTable.collectionName).whereField(K.SearchTable.userIdField , isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                if error != nil{
                    self.errorMessage = error!.localizedDescription
                    self.showError = true
                    return
                }else{
                    if let snapshotDocument = querySnapshot?.documents{
                        self.recentSearchList = []
                        for doc in snapshotDocument{
                            let data = doc.data()
                            self.recentSearchList.append(SearchModel(dict: data as NSDictionary))
                        }
                    }
                }
            }
    }
    
    func addSearchRecent(recent: SearchModel) -> Void{
        self.db.collection(K.SearchTable.collectionName).whereField(K.SearchTable.userIdField, isEqualTo: Utils.UDValue(key: K.AppConstant.loggedId)).whereField(K.SearchTable.searchUserId, isEqualTo: recent.searchUserId).limit(to: 1).addSnapshotListener{querySnapshot,error in
            if error != nil {
                self.errorMessage = error!.localizedDescription
                self.showError = true
                return
            }else{
                if let snapshotDocument = querySnapshot?.documents{
                    
                    var resultData = [
                        K.SearchTable.userNameField : recent.userName,
                        K.SearchTable.imageUrlField : recent.imageUrl,
                        K.SearchTable.createdAtField : Date().description,
                        K.SearchTable.userIdField : Utils.UDValue(key: K.AppConstant.loggedId),
                        K.SearchTable.searchUserId : recent.searchUserId,
                        K.SearchTable.searchPhone : recent.searchPhone
                    ]
                    
                    if !snapshotDocument.isEmpty{
                        // if exist recent, update date
                        let data = snapshotDocument[0].data()
                        resultData[K.SearchTable.idField] = data[K.SearchTable.idField]
                        self.db.collection(K.SearchTable.collectionName).document(data[K.SearchTable.idField] as! String).setData(resultData){ error in
                            if error != nil{
                                self.errorMessage = error!.localizedDescription
                                self.showError = true
                                return
                            }else{
                                self.searchResult = nil
                                return
                            }
                        }
                    }else{
                        // if not, add search recent
                        let id = UUID()
                        resultData[K.SearchTable.idField] = id.uuidString
                        self.db.collection(K.SearchTable.collectionName).document(id.uuidString).setData(resultData){ error in
                            if error != nil{
                                self.errorMessage = error!.localizedDescription
                                self.showError = true
                                return
                            }else{
                                self.searchResult = nil
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteRecent(){
        db.collection(K.SearchTable.collectionName).whereField(K.SearchTable.userIdField, isEqualTo: Utils.UDValue(key: K.AppConstant.loggedId)).addSnapshotListener { querySnapshot, error in
            if error != nil{
                self.errorMessage = error!.localizedDescription
                self.showError = true
                return
            }else{
                for document in querySnapshot?.documents ?? [] {
                    document.reference.delete()
                }
                self.recentSearchList = []
                print("delete all record")
            }
        }
    }
}
