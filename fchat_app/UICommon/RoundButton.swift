
import SwiftUI

struct RoundButton: View {
    @State var title : String = "Title"
    var onTap : (() -> ())?
    var body: some View {
        Button{
            onTap?()
        } label: {
            Text(title)
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 60, maxHeight: 60)
        .background(Color(.orange))
        .cornerRadius(20)
    }
}

#Preview {
    RoundButton()
}
