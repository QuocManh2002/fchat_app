
import SwiftUI

struct TabButton: View {
    
    @State var title: String = "Title"
    @State var image: String = "store_tab"
    var isSelect: Bool = false
    var didSelect: (()->())
    
    var body: some View {
        Button(action: {
            didSelect()
        }, label: {
            VStack{
                Image(systemName: image)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(isSelect ? .primaryOrange : .gray)
                    .scaleEffect(isSelect ? 1.25 : 1)
                    .padding(.bottom, 1)
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(isSelect ? .primaryOrange : .gray)
                    .padding(.bottom, 5)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        })
    }
}

#Preview {
    TabButton(image: "ellipsis.message.fill") {
        print("")
    }
}
