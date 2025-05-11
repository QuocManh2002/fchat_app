
import SwiftUI

struct LineTextField: View {
    
    @Binding var txt : String
    @State var title : String = ""
    @State var placeHolder : String = ""
    @State var keyboardType : UIKeyboardType = .default
    @FocusState var isFocused : Bool
    
    var body: some View {
        VStack{
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            TextField(placeHolder, text: $txt)
                .font(.system(size: 20))
                .fontWeight(.medium)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .lineLimit(1)
                .padding(.bottom, 5)
                .focused($isFocused)
        }
        .padding(10)
        .background(Color(K.ColorAssets.systemColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.clear)
                .stroke( isFocused ? Color.primaryOrange : .clear, lineWidth: 2)
        )
        .padding(.bottom, 20)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
    }
}

struct LineSecureField: View {
    @Binding var txt: String
    @State var title: String = "Title"
    @State var placeHolder: String = "Placholder"
    @Binding var isShowPassword: Bool
    
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            if (isShowPassword) {
                TextField(placeHolder, text: $txt)
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .modifier( ShowButton(isShow: $isShowPassword))
                    .lineLimit(1)
                    .padding(.bottom, 5)
            }else{
                SecureField(placeHolder, text: $txt)
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .modifier( ShowButton(isShow: $isShowPassword))
                    .lineLimit(1)
                    .padding(.bottom, 5)
            }
        }
    }
}

#Preview {
    UpdateProfileView()
}
