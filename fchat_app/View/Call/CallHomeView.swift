
import SwiftUI

struct CallHomeView: View {


    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.primaryOrange)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
    }

    @State private var selectedType : E.CallTypes = .all

    var body: some View {

            VStack{
                Picker("Select call type", selection: $selectedType) {
                    ForEach(E.CallTypes.allCases, id: \.self){
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                ScrollView{
                    VStack{
//                        ForEach(selectedType == .all ? callVM.allCallList : callVM.missCallList, id: \.id){ call in
//                            CallCell(call: call)
//                        }
                    }
                }.padding(.horizontal, 10)
                Spacer()
            }

    }
}

