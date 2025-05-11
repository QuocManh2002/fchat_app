
import SwiftUI

struct ButtonMenu: View {
    var icon : String
    var title : String
    var action : () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(alignment: .center){
                Image(systemName: icon)
                    .font(.footnote)
                    .frame(width: 30, height: 30, alignment: .center)
                    .background(.gray.opacity(0.3), in: Circle())
                Text(title)
            }
        })
    }
}

#Preview {
    ButtonMenu(
        icon: "camera.fill", title: "Hình ảnh") {
            
        }
}
