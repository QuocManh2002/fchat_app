
import SwiftUI

extension Int {
    func parseMessageTypeFromInt() -> MessageType {
        switch self {
        case 0:
            return .text
        case 1:
            return .photo
        case 2:
            return .audio
        case 3:
            return .video
        default:
            return .text
        }
    }
    
    func parseReactionFromInt() -> E.Reaction {
        switch self {
        case 0:
            return .heart
        case 1:
            return .laugh
        case 2:
            return .shocked
        case 3:
            return .sad
        case 4:
            return .angry
        case 5:
            return .like
        case 6:
            return .more
        default:
            return .heart
        }
    }
}
