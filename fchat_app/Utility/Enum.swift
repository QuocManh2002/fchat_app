

struct E {
    
    enum CallTypes : String, CaseIterable{
        case all = "Tất cả"
        case miss = "Gọi nhỡ"
    }
    
    enum MessageMenuAction: String, CaseIterable, Identifiable {
        case reply, forward, copy, delete
        
        var id: String {
            return rawValue
        }
        
        var systemImageName: String {
            switch self {
            case .reply:
                return "arrowshape.turn.up.left.fill"
            case .forward:
                return "arrowshape.turn.up.right.fill"
            case .delete:
                return "trash.fill"
            case .copy:
                return "document.on.document.fill"
            }
        }
        
        var VietNameseId: String{
            switch self {
            case .reply:
                return "Trả lời"
            case .forward:
                return "Chuyển tiếp"
            case .delete:
                return "Xoá"
            case .copy:
                return "Sao chép"
            }
        }
    }
    
    enum Reaction: Int, CaseIterable, Identifiable {
        
        case heart
        case laugh
        case shocked
        case sad
        case angry
        case like
        case more
        
        var id: Int {
            return rawValue
        }
        
        var emoji: String {
            switch self {
            case .like:
                return "👍"
            case .heart:
                return "❤"
            case .laugh:
                return "😆"
            case .shocked:
                return "😮"
            case .sad:
                return "😢"
            case .angry:
                return "😡"
            case .more:
                return "+"
            }
        }
    }
    
}
