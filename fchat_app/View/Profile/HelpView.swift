
import SwiftUI

struct HelpView: View {
    @Environment(\.presentationMode) var mode : Binding<PresentationMode>
    
    var body: some View {
        ZStack{
            Color(K.ColorAssets.lightGray)
                .onTapGesture {
                    dismissKeyboard()
                }.ignoresSafeArea()
            VStack{
                HStack(spacing: 25) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                            .foregroundColor(Color(K.ColorAssets.primaryText))
                    }
                    Text("Trợ giúp")
                        .font(.system(size: 27))
                        .fontWeight(.medium)
                        .foregroundColor(Color(K.ColorAssets.primaryText))
                    Spacer()
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                .background(Color(K.ColorAssets.systemColor))
                Spacer()
                Text("Coming soon...")
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(K.ColorAssets.primaryText))
                Spacer()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    HelpView()
}
