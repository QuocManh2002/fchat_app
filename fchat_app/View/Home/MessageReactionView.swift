
import SwiftUI

struct MessageReactionView: View {
    let message: MessageModel
    
    private var isDuplicateReaction: Bool {
        return message.senderReaction != nil &&
        message.receiverReaction != nil &&
        message.senderReaction == message.receiverReaction
    }
    
    var body: some View {
        HStack{
            if isDuplicateReaction {
                Text(message.senderReaction!.emoji)
                    .font(.system(size: 10))
                Text("2")
                    .font(.system(size: 10))
                    .fontWeight(.light)
            } else {
                    if message.senderReaction != nil {
                        Text(message.senderReaction!.emoji)
                            .font(.system(size: 10))
                    }
                    if message.receiverReaction != nil {
                        Text(message.receiverReaction!.emoji)
                            .font(.system(size: 10))
                    }
                }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Capsule().fill(Color(K.ColorAssets.lightGray)))
        .overlay {
            Capsule().stroke(message.isMyMessage ? Color.primaryOrange : Color.primaryWhite , lineWidth: 2)
        }
    }
}

#Preview {
    MessageReactionView(message: .stubSendMessage)
}
