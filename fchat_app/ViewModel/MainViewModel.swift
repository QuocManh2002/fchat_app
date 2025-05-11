
import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import StreamVideo
import PhotosUI
import SwiftUI
import Combine
import AlertKit

class MainViewModel : ObservableObject{
    
    static var shared = MainViewModel()
    
    @Published var txtUserName : String = ""
    @Published var txtEmail : String = ""
    @Published var txtPhone : String = ""
    @Published var imageUrl : String = ""
    
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    @Published var isShowPhotoPicker: Bool = false
    
    @Published var showOTP : Bool = false
    @Published var vID : String = ""
    @Published var txtCode : [String] = Array(repeating: "", count: 6)
    
    @Published var isUserLogin : Bool = false
    @Published var isSetUpAccount : Bool = false
    @Published var accountObj : AccountModel = AccountModel(dict: [:])
    
    @Published var isShowLogoutAlert: Bool = false
    @Published var isShowChangeAccountAlert: Bool = false
    
    @Published var isShowProgressAlert: Bool = false
    @Published var isShowSuccessAlert: Bool = false
    
    private(set) var progressAlert = AlertAppleMusic17View(title: "Đang xử lý", subtitle: nil, icon: .spinnerSmall)
    private(set) var successAlert = AlertAppleMusic17View(title: "Sửa hồ sơ thành công", subtitle: nil, icon: .done)
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var customCallVM = CustomCallViewModel.shared
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    init() {
        if( Utils.UDValueBool(key: K.AppConstant.userLogin) ) {
            if( Utils.UDValueBool(key: K.AppConstant.setUpAccount)){
                self.accountObj = Utils.getLoggedAccount()
                    self.isSetUpAccount = true
                if !customCallVM.isReady{
                    customCallVM.onAppear(apiKey: K.myStreamApiKey, userId: self.accountObj.id)
                }
                setTextFieldContent()
            }
            self.isUserLogin = true
        }
        onPhotoPickerSeletion()
    }
    
    deinit {
        subscriptions.forEach{$0.cancel()}
        subscriptions.removeAll()
    }
    
    func logOut(){
        revokeStreamToken { result, message in
            if !result {
                print("Fail to revoke stream token with error: \(message ?? "")")
                self.errorMessage = message ?? ""
                self.showError = true
                return
            }
            Utils.UDRemoveAll()
            self.isUserLogin = false
            self.isSetUpAccount = false
        }
    }
    
    func signUpAccount() async throws {
        if(txtUserName.isEmpty){
            await progressAlert.dismiss()
            self.errorMessage = "Tên người dùng không được để trống"
            self.showError = true
            return
        }
        
        if(!txtEmail.isValidEmail) {
            await progressAlert.dismiss()
            self.errorMessage = "Email không hợp lệ"
            self.showError = true
            return
        }
        
        let userId = UUID().uuidString
        
        // save avatar to firestore
        if !mediaAttachments.isEmpty {
            try await MediaHelper().upLoadMediaToFirebase( mediaAttachments.first!) { result in
                switch result {
                case .success(let downloadUrl):
                    self.imageUrl = downloadUrl
                    self.serviceCallSignUp(userId)
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }
            }
        } else {
            serviceCallSignUp(userId)
        }
    }
    
    func serviceCallSignUp(_ userId : String){
        // firebase sign up logic
        let userData = [
            K.AccountTable.idField : userId,
            K.AccountTable.userNameField : self.txtUserName,
            K.AccountTable.emailField : self.txtEmail,
            K.AccountTable.phoneField : self.txtPhone,
            K.AccountTable.imageUrlField : self.imageUrl,
            K.AccountTable.streamTokenField : self.accountObj.streamToken
        ]
        Firestore.firestore().collection(K.AccountTable.collectionName).document(userId).setData(userData as [String : Any]){ error in
            if error != nil{
                self.progressAlert.dismiss()
                self.errorMessage = error!.localizedDescription
                self.showError = true
                return
            } else {
                self.setUserData(uDict: userData as [String : Any]){
                    self.progressAlert.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1 ){
                        self.isShowProgressAlert = false
                        self.isShowSuccessAlert = true
                    }
                    self.isSetUpAccount = true
                }
            }
        }
    }
    
    func getAccountByPhone() -> [AccountModel] {
        let db = Firestore.firestore()
        var rs : [AccountModel] = []
        db.collection(K.AccountTable.collectionName).whereField(K.AccountTable.phoneField, isEqualTo: self.txtPhone).limit(to: 1).addSnapshotListener { querySnapshot, error in
            if error != nil {
                self.errorMessage = error!.localizedDescription
                self.showError = true
                return
            } else {
                if let document = querySnapshot?.documents{
                    if !document.isEmpty {
                        print(document.first!.data())
                        rs.append(AccountModel(dict: document.first!.data()))
                    }
                }
            }
        }
        return rs
    }
    
    func setUserData(uDict: [String : Any], completion: @escaping () -> Void) {
        Utils.UDSET(data: true, key: K.AppConstant.userLogin)
        Utils.setLoggedAccount(dict: uDict)
        self.accountObj = AccountModel(dict: uDict)
        self.isUserLogin = true
        
        setTextFieldContent()
        if !customCallVM.isReady{
            customCallVM.onAppear(apiKey: K.myStreamApiKey, userId: self.accountObj.id)
        }
        Utils.UDSET(data: true, key: K.AppConstant.setUpAccount)
        completion()
    }
    
    func submitPhoneNumber(){
        if txtPhone.count < 10 {
            errorMessage = "Hãy điền đầy đủ số điện thoại"
            showError = true
            return
        } else if !txtPhone.isPhoneNumber(){
            errorMessage = "Số điện thoại chứa kí tự không hợp lệ"
            showError = true
            return
        } else {
            showOTP = true
            sendSMS()
        }
    }
    
    func sendSMS(){
        PhoneAuthProvider.provider().verifyPhoneNumber("+84\(txtPhone)", uiDelegate: nil){
            verificationId, error in
            if error != nil {
                self.errorMessage = error!.localizedDescription
                self.showError = true
                return
            } else {
                self.vID = verificationId ?? ""
            }
        }
    }
    
    func verifyCode(){
        if txtCode.contains("") {
            self.errorMessage = "Hãy điền đầy đủ mã OTP"
            self.showError = true
            return
        }
        
        let code = String().convertArrayToString(txtCode)
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: vID, verificationCode: code)
        
        Auth.auth().signIn(with: credential){
            authResult, error in
            
            if error != nil{
                self.errorMessage = error!.localizedDescription
                self.showError = true
                return
            } else {
                let db = Firestore.firestore()
                db.collection(K.AccountTable.collectionName).whereField(K.AccountTable.phoneField, isEqualTo: self.txtPhone).limit(to: 1).addSnapshotListener { querySnapshot, error in
                    if error != nil {
                        self.errorMessage = error!.localizedDescription
                        self.showError = true
                        return
                    } else {
                        if let document = querySnapshot?.documents{
                            if document.isEmpty {
                                self.isSetUpAccount = false
                                self.isUserLogin = true
                                Utils.UDSET(data: true, key: K.AppConstant.userLogin)
                            } else {
                                self.isSetUpAccount = true
                                Utils.UDSET(data: true, key: K.AppConstant.setUpAccount)
                                Utils.UDSET(data: document.first!.data()[K.AccountTable.idField] ?? "", key: K.AppConstant.loggedId)
                                self.setUserData(uDict: document.first!.data()){
                                    self.isSetUpAccount = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func generateStreamToken(completion: @escaping (Bool, String?) -> Void) {
        let payload: [String: Any] = [
            "id": accountObj.id
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(false, "Failed to encode JSON")
            return
        }
        
        guard let url = URL(string: "https://asia-southeast2-fchat-app-6dd34.cloudfunctions.net/generateToken") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fail to generate token with error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion(false, "No data received")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let responseString = String(data: data, encoding: .utf8) {
                    completion(true, responseString)
                    return
                } else {
                    completion(false, "Fail to parse response")
                    return
                }
            } else {
                completion(false, "Fail to generate token")
                return
            }
        }
        task.resume()
    }
    
    func setStreamTokenForAccount(_ token: String) {
        let db = Firestore.firestore()
        let accountRef = db.collection(K.AccountTable.collectionName).document(accountObj.id)
        accountRef.updateData([K.AccountTable.streamTokenField: token]){ error in
            if let error = error {
                print("Fail to update stream token with error: \(error)")
                self.errorMessage = error.localizedDescription
                self.showError = true
                return
            }
            Utils.UDSET(data: token, key: K.AppConstant.loggedStreamToken)
        }
    }
    
    private func revokeStreamToken(completion: @escaping (Bool, String?) -> Void) {
        let payload: [String: Any] = [
            "id": accountObj.id
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(false, "Failed to encode JSON")
            return
        }
        
        guard let url = URL(string: "https://asia-southeast2-fchat-app-6dd34.cloudfunctions.net/revokeToken") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fail to generate token with error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            guard data != nil else {
                completion(false, "No data received")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true, nil)
                return
            } else {
                completion(false, "Fail to generate token")
                return
            }
        }
        task.resume()
    }
    
    func updateProfile() async throws {
        if(txtUserName.isEmpty){
            await progressAlert.dismiss()
            self.errorMessage = "Tên người dùng không được để trống"
            self.showError = true
            return
        }
        
        if(!txtEmail.isValidEmail) {
            await progressAlert.dismiss()
            self.errorMessage = "Email không hợp lệ"
            self.showError = true
            return
        }
        
        // save avatar to firestore
        
        if !mediaAttachments.isEmpty {
            try await MediaHelper().upLoadMediaToFirebase( mediaAttachments.first!) { result in
                switch result {
                case .success(let downloadUrl):
                    self.imageUrl = downloadUrl
                    self.serviceCallSignUp(self.accountObj.id)
                    break
                case .failure(let error):
                    Task {
                        await self.progressAlert.dismiss()
                    }
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }
            }
        } else {
            serviceCallSignUp(accountObj.id)
        }
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
            guard
                let data = try? await item.loadTransferable(type: Data.self),
                let thumbnail = UIImage(data: data),
                let itemIdentifier = item.itemIdentifier
            else {return}
            
            let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
            mediaAttachments.insert(photoAttachment, at: 0)
        }
    }
    
    
    private func setTextFieldContent() {
        txtUserName = accountObj.userName
        txtEmail = accountObj.email
        txtPhone = accountObj.phone
    }
}
