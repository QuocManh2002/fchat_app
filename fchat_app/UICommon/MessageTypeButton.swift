
import SwiftUI

struct MessageTypeButton: View {
    @State var isShow : Bool = false
    @State var text : String = ""
    @State var isRecording : Bool = false
    @FocusState private var isMessageTextFocused : Bool
    
    var body: some View {
        HStack{
            
            if isMessageTextFocused {
                Button {
                    isMessageTextFocused = false
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.orange)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 5)
            } else {
                Button {
                    Task {
            
                    }
                } label: {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 22))
                }
                .padding(.horizontal, 5)
                
                Button {
                    isRecording.toggle()
                } label: {
                    if isRecording {
                        Image(systemName: "pause.fill")
                            .padding(.all, 5)
                            .foregroundColor(.white)
                            .background(.red)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 22))
                    }
                }
                .padding(.horizontal, 5)
            }
            if isRecording {
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.red)
                    Text("Đang ghi")
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                    Spacer()
                    Text("0:01")
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                }
                .padding(.all, 5)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray, lineWidth: 1)
                )
                                
            } else {
                TextField("Aa", text: $text)
                    .focused($isMessageTextFocused)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
            }
            
            
            Button(action: {
                
            }, label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor("".trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .primaryOrange)
                    .font(.system(size: 22))
            }).padding(.horizontal, 5)
        }
        .padding()
    }
}

#Preview {
    MessageTypeButton()
}
