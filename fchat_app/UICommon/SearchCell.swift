

import SwiftUI

struct SearchCell: View {
    
    @StateObject var searchVM = SearchViewModel.shared
    
    @State var search : SearchModel
    @State var contact : ContactModel?
    @State var isTapped = false
    	
    var body: some View {
        NavigationLink(
            destination:MessageView(messageVM: MessageViewModel(contact: ContactModel(from: search))),
            label: {
                HStack{
                    MyImage(url: search.imageUrl, height: 55, width: 55, isCircle: true)
                    .padding(.trailing, 5)
                    
                    VStack(alignment: .leading){
                        Text(search.userName)
                            .lineLimit(1)
                            .font(.system(size: 22))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text(search.searchPhone)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        Divider()
                    }
                    Spacer()
                }
            })
    }
}

#Preview {
    SearchCell( search: SearchModel(dict: [
        K.SearchTable.imageUrlField : K.imageUrl,
        K.SearchTable.userNameField : K.userName,
        K.SearchTable.searchPhone : K.userPhone
    ])
    )
}
