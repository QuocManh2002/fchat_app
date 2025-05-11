
import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var mode : Binding<PresentationMode>
    @StateObject var mainVM = MainViewModel.shared
    
    var body: some View {
        ZStack{
            Color(K.ColorAssets.lightGray)
                .onTapGesture {
                    dismissKeyboard()
                }
                .ignoresSafeArea()
            
            VStack{
                Image(K.ImageUrl.appLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 30)
                
                Text("Đăng ký")
                    .font(.system(size: 28))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 5)
                
                Text("Hãy nhập đầy đủ các thông tin sau")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
               
                Button {
                    mainVM.isShowPhotoPicker.toggle()
                } label: {
                    if !mainVM.mediaAttachments.isEmpty{
                        Image(uiImage: mainVM.mediaAttachments.first!.thumbnail)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 2))
                                .padding(.bottom, 15)
                        } else {
                            Image(K.ImageUrl.noImage)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 120, height: 120)
                                .background(.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                .padding(.bottom, 15)
                        }
                }

                
                LineTextField(txt: $mainVM.txtUserName, title: "Tên người dùng", placeHolder: "Nguyễn Văn A")
                
                LineTextField(txt: $mainVM.txtEmail, title: "Email", placeHolder: "abc@gmail.com")
                
                Spacer()

                Button(action: {
                    Task{
                        try await mainVM.signUpAccount()
                    }
                }, label: {
                    Text("Đăng ký")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame( minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 60 )
                        .background(Color.primaryOrange)
                        .cornerRadius(15)
                        .padding(.bottom, 10)
                })
            }
            .padding(.horizontal, 20)
        }
        .alert(isPresented: $mainVM.showError, content: {
            Alert(title: Text(K.AppConstant.appName), message: Text(mainVM.errorMessage),
                  dismissButton: .default(Text("OK"))
            )
        })
        .photosPicker(
            isPresented: $mainVM.isShowPhotoPicker,
            selection: $mainVM.photoPickerItems,
            maxSelectionCount: 1,
            matching: .not(.videos),
            photoLibrary: .shared())
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignUpView()
}
