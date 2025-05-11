
import SwiftUI

struct OTPTextField: View {
    
    @Binding var enteredValue : [String]
    @FocusState private var fieldFocus : Int?
    
    var body: some View {
        HStack{
            ForEach(0..<6, id: \.self){ index in
                TextField("", text: $enteredValue[index])
                    .keyboardType(.numberPad)
                    .fontWeight(.bold)
                    .textContentType(.oneTimeCode)
                    .frame(width: 45, height: 45)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(7)
                    .multilineTextAlignment(.center)
                    .focused($fieldFocus, equals: index)
                    .tag(index)
                    .onChange(of: enteredValue[index]) { (oldValue, newValue) in
                        if enteredValue[index].count > 1 {
                            let currentValue = enteredValue[index]
                            
                            if currentValue == oldValue{
                                enteredValue[index] = String(enteredValue[index].suffix(1))
                            } else {
                                enteredValue[index] = String(enteredValue[index].prefix(1))
                            }
                        }
                        if !newValue.isEmpty {
                            if index == 5 {
                                fieldFocus = nil
                            } else {
                                fieldFocus = (fieldFocus ?? 0) + 1
                            }
                        } else {
                            fieldFocus = (fieldFocus ?? 0) - 1
                        }
                    }
            }
        }
    }
}

struct OTPTextField_Previews: PreviewProvider {
    @State static var enteredValue = Array(repeating: "", count: 6)
    
    static var previews: some View{
        OTPTextField(enteredValue: $enteredValue)
    }
}
