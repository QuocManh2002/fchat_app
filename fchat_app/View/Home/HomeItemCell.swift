
import SwiftUI

struct HomeItemCell: View {
    @Binding var item : ContactModel
    
    var body: some View {
        NavigationLink {
            MessageView(messageVM: MessageViewModel(contact: item))
        } label: {
            HStack{
                MyImage(url: item.imageUrl, height: 50, width: 50, isCircle: true)
                    .padding(.trailing, 5)
                VStack(alignment: .leading){
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.userName)
                                .font(.system(size: 20))
                                .foregroundColor(Color(K.ColorAssets.primaryText))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            if item.type == .text {
                                Text(item.content)
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(K.ColorAssets.lightText))
                                    .lineLimit(1)
                            } else {
                                HStack(spacing: 5){
                                    Image(systemName: item.type == .audio ? "mic.fill" : "photo.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(K.ColorAssets.lightText))
                                    Text(item.type.title)
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(K.ColorAssets.lightText))
                                }
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing,spacing: 5){
                            Text(item.sendedAt.displayDate(format: "dd/MM"))
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(K.ColorAssets.primaryText))
                        }
                    }
                    Divider()
                }
            }
            .padding(.all, 10)
        }
    }
}
