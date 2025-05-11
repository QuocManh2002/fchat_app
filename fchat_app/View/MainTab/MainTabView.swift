
import SwiftUI

struct MainTabView: View {
    @StateObject var homeVM = HomeViewModel.shared
    @StateObject var customCallVM = CustomCallViewModel.shared
    
    init(homeVM: HomeViewModel = HomeViewModel.shared) {
        UISlider.appearance().setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
    }
    
    var body: some View {
        ZStack {
            
            if homeVM.selectTab == 0{
                HomeView()
            }else if homeVM.selectTab == 1{
                CallHomeView()
            }else {
                ProfileView()
            }
            
            
            VStack {
                Spacer()
                HStack{
                    TabButton(title: K.tabbarItems[0].title, image: K.tabbarItems[0].image, isSelect: homeVM.selectTab == 0) {
                        DispatchQueue.main.async {
                            withAnimation {
                                homeVM.selectTab = 0
                            }
                        }
                    }
                    TabButton(title: K.tabbarItems[1].title, image: K.tabbarItems[1].image, isSelect: homeVM.selectTab == 1) {
                        DispatchQueue.main.async {
                            withAnimation {
                                homeVM.selectTab = 1
                            }
                        }
                    }
                    TabButton(title: K.tabbarItems[2].title, image: K.tabbarItems[2].image, isSelect: homeVM.selectTab == 2) {
                        DispatchQueue.main.async {
                            withAnimation {
                                homeVM.selectTab = 2
                            }
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
                .background(.background.opacity(0.8))
                .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: -2)
            }
            .ignoresSafeArea()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}


