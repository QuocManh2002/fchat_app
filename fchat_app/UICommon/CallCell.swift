
import SwiftUI

struct CallCell: View {
    
    @State var call : CallModel
    
    var body: some View {
        HStack{
            MyImage(url: call.imageUrl, height: 50, width: 50, isCircle: true)
            .padding(.trailing, 5)
            Text(call.name)
                .lineLimit(1)
                .font(.system(size: 23))
                .fontWeight(.semibold)
                .foregroundColor(call.isMissed ? .red : .black)
            Spacer()
            Text(call.createdAt)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .padding(.leading, 10)
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.primaryBlue)
            }).padding(.trailing, 5)
        }.padding(.all, 10)
    }
}
