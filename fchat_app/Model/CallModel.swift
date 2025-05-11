
import Foundation
struct CallModel : Identifiable, Equatable{
    let id = UUID()
    var name : String = ""
    var imageUrl : String = ""
    var createdAt : String = ""
    var isMissed : Bool = false
}
