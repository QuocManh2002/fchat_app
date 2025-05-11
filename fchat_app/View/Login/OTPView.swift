
import SwiftUI

struct OTPView: View {
    @StateObject var mainVM = MainViewModel.shared
    
    var body: some View {
        VStack {
            Text("Nhập mã 6 số được gửi về số điện thoại")
                .font(.system(size: 17))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            Text(mainVM.txtPhone.isEmpty ? "0123 456 789" : mainVM.txtPhone.phoneNumberStringFormat())
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 1)
                .padding(.bottom, 60)
            
            OTPTextField(enteredValue: $mainVM.txtCode)
            
            Spacer()
            
            HStack{
                Text("Không nhận được mã ?")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                
                Button(action: {
                    mainVM.sendSMS()
                }, label: {
                    Text("Gửi lại")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.primaryOrange)
                })
            }
            .padding(.bottom, 10)

            Button(action: {
                mainVM.verifyCode()
            }, label: {
                Text("Tiếp tục")
                    .font(.system(size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame( minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60 )
                    .background(Color.primaryOrange)
                    .cornerRadius(20)
                    .padding(.bottom, 10)
            })
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $mainVM.showError, content: {
            Alert(title: Text("F-Chat"), message: Text(mainVM.errorMessage), dismissButton: .default(Text("Ok")))
        })
        
        
    }
}

#Preview {
    OTPView()
}
