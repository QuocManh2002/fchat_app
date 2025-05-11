
import SwiftUI

struct SignInView: View {
    
    @StateObject var loginVM = MainViewModel.shared
    @Environment(\.presentationMode) var mode : Binding<PresentationMode>
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    mode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                })
                
                Spacer()
            }
            
            Image("app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 30)
            
            Text("Đăng nhập")
                .font(.system(size: 28))
                .fontWeight(.bold)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
            
            Text("Hãy nhập email và mật khẩu")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 25)
            
            LineTextField(txt: $loginVM.txtEmail, title: "Email", placeHolder: "abc@gmail.com")
                .padding(.bottom, 20)
            
            Button(action: {
                print("Quen mat khau")
            }, label: {
                Text("Quên mật khẩu?")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
            })
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 10)
            
            RoundButton(title: "Đăng nhập") {
                
            }
            .padding(.bottom, 20)
            
            NavigationLink {
                SignUpView()
            } label: {
                HStack{
                    Text("Chưa có tài khoản?")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Text("Đăng ký")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }.padding(.horizontal, 20)
            .alert(isPresented: $loginVM.showError, content: {
                Alert(title: Text(K.AppConstant.appName), message: Text(loginVM.errorMessage),
                      dismissButton: .default(Text("OK"))
                )
            })
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
    }
}

#Preview {
    SignInView()
}
