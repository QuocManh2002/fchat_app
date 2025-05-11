
import SwiftUI

struct MessageCell: View {
    @State var message : MessageModel
    @State var isShowDateMessage: Bool
    let actionHandler: () -> Void
    
    var body: some View {
        VStack{
            if isShowDateMessage {
                dateTimeMessageTextView()
                    .padding(.vertical, 10)
            }
            getMessageCellView()
                .frame(maxWidth: .infinity, alignment: message.isMyMessage ? .trailing : .leading)
            
        }
        .padding(.vertical, 3)
    }
    
    @ViewBuilder
    private func getMessageCellView() -> some View {
        HStack(alignment: .bottom){
            if message.isMyMessage {
                timeStampText()
            }
            
            MessageContentView(content: message.content, type: message.type, isMyMessage: message.isMyMessage,
                               imageHeight: message.thumbnailSize?.height ?? 0,
                               thumbnailURL: message.thumbnailURL,
                               audioDuration: message.audioDuration,
                               actionHandler: actionHandler)
            .overlay(alignment: message.isMyMessage ? .bottomLeading : .bottomTrailing) {
                if message.senderReaction != nil || message.receiverReaction != nil {
                    MessageReactionView(message: message)
                        .offset(x: message.isMyMessage ? 10 : -10, y: 10)
                }
            }
            if !message.isMyMessage {
                timeStampText()
            }
        }
    }
    
    private func timeStampText() -> some View {
        return Text(message.sendedAt.displayDate(format: "HH:mm"))
            .font(.system(size: 10))
            .foregroundColor(.gray)
            .padding(.bottom, 1)
    }
    
    private func dateTimeMessageTextView() -> some View {
        return Text(message.sendedAt.getDateMessageString())
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal)
            .background(Color.gray.opacity(0.1))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    MessageCell(message: .stubReceiveMessage, isShowDateMessage: true){
        print("")
    }
}
