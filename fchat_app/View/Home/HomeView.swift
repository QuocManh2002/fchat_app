
import SwiftUI
import StreamVideoSwiftUI

struct HomeView: View {
    
    @ObservedObject var contactVM = ContactViewModel.shared
    
    var body: some View {
        VStack {
            AppBar()
            ScrollView {
                LazyVStack(spacing: 0){
                    ForEach($contactVM.contactList) { item in
                      HomeItemCell(item: item)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}
