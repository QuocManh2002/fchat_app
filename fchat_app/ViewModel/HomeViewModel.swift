
import Foundation
class HomeViewModel: ObservableObject{
    static var shared : HomeViewModel = HomeViewModel()
    
    @Published var selectTab : Int = 0
    
    @Published var showError = false
    @Published var errorMessage = ""
    
}
