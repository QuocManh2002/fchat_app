
import SwiftUI
import AlertKit

struct UpdateProfileView: View {
    @Environment(\.presentationMode) var mode : Binding<PresentationMode>
    @StateObject var mainVM = MainViewModel.shared
    
    var body: some View {
        ZStack {
            Color(K.ColorAssets.lightGray)
                .onTapGesture {
                    dismissKeyboard()
                }.ignoresSafeArea()
            
            VStack{
                HStack(spacing: 25) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(Color(K.ColorAssets.primaryText))
                    }
                    Text("Sửa hồ sơ")
                        .font(.system(size: 27))
                        .fontWeight(.medium)
                        .foregroundColor(Color(K.ColorAssets.primaryText))
                    Spacer()
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                .background(Color(K.ColorAssets.systemColor))
                
                Button {
                    mainVM.isShowPhotoPicker.toggle()
                } label: {
                    if mainVM.mediaAttachments.isEmpty && mainVM.accountObj.imageUrl.isEmpty {
                        Image(K.ImageUrl.noImage)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 150, height: 150)
                            .background(.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            .padding(20)
                    } else {
                        Image(uiImage: mainVM.mediaAttachments.first!.thumbnail)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            .padding(20)
                    }
                }
                
                
                LineTextField(txt: $mainVM.txtUserName, title: "Tên người dùng", placeHolder: "Nguyễn Văn A")
                    .padding(.horizontal, 20)
                
                LineTextField(txt: $mainVM.txtEmail, title: "Email", placeHolder: "abc@gmail.com")
                    .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
                    mainVM.isShowProgressAlert = true
                    Task{
                        try await mainVM.updateProfile()
                    }
                }, label: {
                    Text("Sửa hồ sơ")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame( minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 60 )
                        .background(Color.primaryOrange)
                        .cornerRadius(15)
                        .padding(.bottom, 10)
                })
                .padding(.horizontal, 20)
            }
            
        }
        .photosPicker(
            isPresented: $mainVM.isShowPhotoPicker,
            selection: $mainVM.photoPickerItems,
            maxSelectionCount: 1,
            matching: .not(.videos),
            photoLibrary: .shared())
        .alert(isPresented: $mainVM.showError, content: {
            Alert(title: Text(K.AppConstant.appName), message: Text(mainVM.errorMessage),
                  dismissButton: .default(Text("OK"))
            )
        })
        .alert(isPresent: $mainVM.isShowProgressAlert, view: mainVM.progressAlert)
        .alert(isPresent: $mainVM.isShowSuccessAlert, view: mainVM.successAlert)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
    }
    
    private func showAlert() {
        mainVM.isShowProgressAlert = true
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
        //            mainVM.progressAlert.dismiss()
        //            mainVM.isShowProgressAlert = false
        //        }
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
        //            mainVM.isShowSuccessAlert = true
        //        }
    }
}

#Preview {
    UpdateProfileView()
}
