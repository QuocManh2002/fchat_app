
import Foundation
struct HomeItemModel : Identifiable, Equatable{
    let id = UUID()
    var name : String = ""
    var lastMessage : String = ""
    var lastMessageSendedAt : Date = Date()
    var imageUrl : String = ""
    var numOfUnSeenMessage : Int = 0
}
