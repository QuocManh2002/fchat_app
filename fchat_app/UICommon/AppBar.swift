
import Foundation
import SwiftUI

struct AppBar: View{
    var body: some View{
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.last
        VStack(spacing: 20) {
            HStack{
                Image(K.ImageUrl.appLogo).resizable().frame(width: 30,height: 30).padding(.trailing, 10)
                Text(K.AppConstant.appName).italic().font(.system(size: 25)).fontWeight(.bold).foregroundColor(.primaryWhite)
                Spacer()
                NavigationLink {
                    SearchView()
                } label: {
                    Image(systemName: "magnifyingglass").font(.system(size: 22)).fontWeight(.bold).foregroundColor(.primaryWhite)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                }

                
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "plus").font(.system(size: 22)).fontWeight(.bold
                    ).foregroundColor(.primaryWhite)
                })
            }
            .padding().padding(
                .top, (window?.safeAreaInsets.top)!
            )
            .background(Color.primaryOrange)
        }
    }
}
