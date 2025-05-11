
import SwiftUI

struct EmojiReaction {
    let reaction: E.Reaction
    var isAnimating: Bool = false
    var opacity: CGFloat = 1
}

struct ChatReactionPickerView: View {
    let message: MessageModel
    @State private var animateBackgroundView: Bool = false
    @State private var emojiStates: [EmojiReaction] = [
        EmojiReaction(reaction: .heart),
        EmojiReaction(reaction: .laugh),
        EmojiReaction(reaction: .shocked),
        EmojiReaction(reaction: .sad),
        EmojiReaction(reaction: .angry),
        EmojiReaction(reaction: .like),
        EmojiReaction(reaction: .more)
    ]
    let onTapHandler: (_ selectedEmoji: E.Reaction) -> Void
    
    var body: some View {
        HStack(spacing: 10){
            ForEach(Array(emojiStates.enumerated()), id: \.offset){ index, emojiReaction in
                reactionButton(emojiReaction, at: index)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(backgroundView())
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear{
            withAnimation(.easeIn(duration: 0.2)) {
                animateBackgroundView = true
            }
        }
    }
    
    private func isSelectedReaction(_ item: E.Reaction) -> Bool {
        return (message.isMyMessage && message.senderReaction == item) ||
        (!message.isMyMessage && message.receiverReaction == item)
    }
    
    private var springAnimation: Animation {
        return Animation.spring(response: 0.55, dampingFraction: 0.6, blendDuration: 0.05).speed(4)
    }
    
    private func getAnimationIndex(_ index: Int) -> Int {
        if message.isMyMessage {
            return emojiStates.count - 1 - index
        } else {
            return index
        }
    }
    
    private func reactionButton(_ item: EmojiReaction, at index: Int) -> some View {
        Button {
            onTapHandler(item.reaction)
        } label: {
            buttonLabel(item)
                .scaleEffect(emojiStates[index].isAnimating ? 1 : 0)
                .opacity(item.opacity)
                .onAppear{
                    let dynamicIndex = getAnimationIndex(index)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        withAnimation(springAnimation.delay(Double(dynamicIndex) * 0.05)) {
                            emojiStates[index].isAnimating = true
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private func buttonLabel(_ item: EmojiReaction) -> some View {
        if item.reaction == .more {
            Image(systemName: "plus")
                .bold()
                .padding(10)
                .background(Color.gray.opacity(0.15))
                .clipShape(Circle())
                .foregroundColor(.gray)
                
        } else {
            if isSelectedReaction(item.reaction)
            {
                Text(item.reaction.emoji)
                    .font(.system(size: 30))
                    .background(Color.primaryOrange.opacity(0.2)
                        .frame(width: 40, height: 40)
                        .clipShape(.circle))
            } else {
                Text(item.reaction.emoji)
                    .font(.system(size: 30))
            }
        }
    }
    
    private func backgroundView() -> some View {
        Capsule()
            .fill(Color(K.ColorAssets.lightGray))
            .mask {
                Capsule()
                    .fill(Color(K.ColorAssets.lightGray))
                    .scaleEffect(animateBackgroundView ? 1 : 0, anchor: message.isMyMessage ? .trailing : .leading)
                    .opacity(animateBackgroundView ? 1 : 0)
            }
    }
}

#Preview {
    ChatReactionPickerView(message: .stubReceiveMessage){selectedEmoji in
        
    }
}
