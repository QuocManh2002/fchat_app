
import SwiftUI

struct WelcomeView: View {

    @StateObject var mainVM = MainViewModel.shared
    
    var body: some View {

        NavigationStack{
            VStack{
                Image("bg_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 20)
                Text("Tiếp tục bằng số điện thoại")
                    .font(.system(size: 26))
                    .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(K.ColorAssets.primaryText))
                    .padding(.bottom, 25)
                
                HStack{
                    Button(action: {}, label: {                        Text("+84")
                            .fontWeight(.semibold)
                            .foregroundColor(Color(K.ColorAssets.primaryText))
                            .font(.system(size: 22))
                        
                    })
                    TextField("Nhập số điện thoại", text: $mainVM.txtPhone)
                        .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: .infinity)
                        .font(.system(size: 22))
                        .foregroundColor(Color(K.ColorAssets.primaryText))
                        .lineLimit(1)
                }
                Divider()
                    .padding(.bottom, 25)
                
                Spacer()

                Button(action: {
                    mainVM.submitPhoneNumber()
                }, label: {
                    Text("Tiếp tục")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame( minWidth: 0, maxWidth: .infinity, minHeight: 50, maxHeight: 60 )
                        .background(Color.primaryOrange)
                        .cornerRadius(15)
                        .padding(.bottom, 10)
                })
                
                
                //                        Text("Hoặc tiếp tục bằng")
                //                            .foregroundColor(.gray)
                //                            .fontWeight(.semibold)
                //                            .font(.system(size: 18))
                //                            .padding(.bottom, 25)
                //
                //                        NavigationLink {
                //                            SignInView()
                //                        } label: {
                //                            Image("google_logo")
                //                                .resizable()
                //                                .frame(width: 30, height: 30)
                //                            Text("Tiếp tục với Google")
                //                                .font(.system(size: 18))
                //                                .fontWeight(.semibold)
                //                                .foregroundColor(.white)
                //                                .multilineTextAlignment(.center)
                //                        }
                //                        .frame( minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60 )
                //                        .background(.green)
                //                        .cornerRadius(20)
                //                        .padding(.bottom, 10)
                //
                //
                //
                //                        Button {
                //
                //                        } label: {
                //                            Image("facebook_logo")
                //                                .resizable()
                //                                .frame(width: 25, height: 25)
                //                            Text("Tiếp tục với Facebook")
                //                                .font(.system(size: 18))
                //                                .fontWeight(.semibold)
                //                                .foregroundColor(.white)
                //                                .multilineTextAlignment(.center)
                //                        }
                //                        .frame( minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60 )
                //                        .background(.blue)
                //                        .cornerRadius(20)
                
            }
            .padding()
            .alert(isPresented: $mainVM.showError, content: {
                Alert(title: Text("F-Chat"), message: Text(mainVM.errorMessage), dismissButton: .default(Text("Ok")))
            })
            .navigationDestination(isPresented: $mainVM.showOTP) {
                OTPView()
        }
        }
    }
}

#Preview {
    NavigationStack{
        WelcomeView()
    }
}
