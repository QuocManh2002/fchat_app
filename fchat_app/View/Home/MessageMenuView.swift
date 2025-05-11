
import SwiftUI

struct MessageMenuView: View {
    let message: MessageModel
    @State private var animateBackgroundView: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 1){
            ForEach(E.MessageMenuAction.allCases, id: \.id){ action in
                buttonLabel(action)
                
                if action != .delete {
                    Divider()
                }
            }
        }
        .background(Color(K.ColorAssets.lightGray))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .frame(maxWidth: UIWindowScene.current?.maxImageWidth)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .scaleEffect(animateBackgroundView ? 1 : 0, anchor: message.isMyMessage ? .trailing : .leading)
        .opacity(animateBackgroundView ? 1 : 0)
        .onAppear{
            withAnimation(.easeIn(duration: 0.2)) {
                animateBackgroundView = true
            }
        }
        
    }
    
    private func buttonLabel(_ action: E.MessageMenuAction) -> some View {
        Button {
            
        } label: {
            HStack {
                Text(action.VietNameseId)
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: action.systemImageName)
                    
            }
            .foregroundColor(action == .delete ? .red : .black)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
 
        }

    }
}

#Preview {
    MessageMenuView(message: .stubSendMessage)
}
