
import SwiftUI

struct ProfileView: View {
    @StateObject var mainVM = MainViewModel.shared
    
    var body: some View {
        VStack{
            HStack {
                MyImage(url: mainVM.accountObj.imageUrl, height: 100, width: 100, isCircle: true)
                    .padding(.trailing, 5)
                VStack(alignment: .leading, spacing: 5){
                    Text(mainVM.accountObj.userName)
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(K.ColorAssets.primaryText))
                    Text(mainVM.accountObj.phone)
                        .font(.system(size: 20))
                        .foregroundColor(Color(K.ColorAssets.primaryText))
                }
                Spacer()
                
                NavigationLink  {
                    UpdateProfileView()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .foregroundColor(.primaryBlue)
                        .padding(.trailing, 10)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 10)
            
            List{
                
                Button {
                    mainVM.isShowChangeAccountAlert.toggle()
                } label: {
                    HStack{
                        Image(systemName: "rectangle.2.swap")
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .frame(width: 35, height: 35)
                            .background(.red.opacity(0.5))
                            .clipShape(Circle())
                        
                        Text("Đổi tài khoản")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                    }.padding(.vertical, 1)
                }

                
                NavigationLink {
                    HelpView()
                } label: {
                    HStack{
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .frame(width: 35, height: 35)
                            .background(Color(.blue))
                            .clipShape(Circle())
                        
                        Text("Trợ giúp")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                    }.padding(.vertical, 1)
                }
                
                NavigationLink {
                    PolicyView()
                } label: {
                    HStack{
                        Image(systemName: "doc.text")
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .frame(width: 35, height: 35)
                            .background(.gray.opacity(0.7))
                            .clipShape(Circle())
                        
                        Text("Chính sách")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                    }.padding(.vertical, 1)
                }
                
                Button {
                    mainVM.isShowLogoutAlert.toggle()
                } label: {
                    HStack{
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .foregroundColor(.white)
                            .padding(.all, 3)
                            .frame(width: 35, height: 35)
                            .background(.green)
                            .clipShape(Circle())
                        
                        Text("Đăng xuất")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                    }.padding(.vertical, 1)
                    
                }
                
            }
            Spacer()
        }
        .alert("Đăng xuất", isPresented: $mainVM.isShowLogoutAlert) {
            Button("Đồng ý") {
                mainVM.logOut()
            }
            Button("Huỷ", role: .cancel) {
                
            }
            
        } message: {
            Text("Bạn có muốn kết thúc phiên đăng nhập này không?")
        }
        .alert("Đổi tài khoản", isPresented: $mainVM.isShowChangeAccountAlert) {
            
        } message: {
            Text("Coming soon...")
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
