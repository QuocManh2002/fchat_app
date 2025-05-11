
import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageListController
    private var messageVM: MessageViewModel
    
    init(_ messageVM: MessageViewModel) {
        self.messageVM = messageVM
    }
    
    func makeUIViewController(context: Context) -> MessageListController {
        let messageListController = MessageListController(messageVM)
        return messageListController
    }
    
    func updateUIViewController(_ uiViewController: MessageListController, context: Context) {
        
    }
}

