
import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @StateObject var searchVM = SearchViewModel.shared
    
    var body: some View {
        
        VStack{
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Tìm kiếm", text: $searchVM.txtSearch)
                        .lineLimit(1)
                        .onChange(of: searchVM.txtSearch) { oldValue, newValue in
                            if newValue.count == 10{
                                searchVM.searchAccount()
                            }
                        }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.trailing, 5)
                Button(action: {
//                    searchVM.txtSearch = ""
//                    searchVM.searchResult = nil
                    mode.wrappedValue.dismiss()
                }, label: {
                    Text("Huỷ")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryOrange)
                })
            }
            .padding(.bottom, 15)
            
            if searchVM.txtSearch.count == 0 {
                if searchVM.recentSearchList.count != 0 {
                    VStack {
                        HStack{
                            Text("Tìm kiếm gần đây")
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: {
                                searchVM.deleteRecent()
                            }, label: {
                                Text("Xoá tất cả")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primaryOrange)
                            })
                        }
                        ForEach(searchVM.recentSearchList, id: \.id) { recent in
                            NavigationLink {
                                MessageView()
                            } label: {
                                SearchCell(search: recent, contact: searchVM.contact)
                            }.onTapGesture {

                            }
                        }
                    }
                } else {
                    Text("Không có tìm kiếm gần đây")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 26))
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.gray)
                        .frame(minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                }
            } else {
                if !searchVM.isSearching {
                    if let resultList = searchVM.searchResult {
                        if resultList.isEmpty {
                            Text("Không tìm thấy người dùng")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 26))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .frame(minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                        } else {
                            SearchCell(search: resultList.first!, contact: searchVM.contact)
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        .padding(.horizontal, 15)
        .padding(.vertical, 5)
    }
}

#Preview {
    SearchView()
}
