
import SwiftUI

struct MyImage: View {
    var url : String
    var height : Double = 0
    var width : Double = 0
    var isCircle : Bool = false
    
    var body: some View {
        if url.isEmpty {
            Image(systemName: "person.fill")
                .resizable()
                .padding(height / 5)
                .scaledToFill()
                .frame(width: self.width, height: self.height)
                .foregroundColor(.gray)
                .background(.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(.gray, lineWidth: 1))
        } else {
            AsyncImage(url: URL(string: url)){ phase in
                if let image = phase.image{
                    if isCircle {
                        image.resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipShape(Circle())
                    } else {
                        image.resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                } else if phase.error != nil{
                    Text(phase.error?.localizedDescription ?? "error")
                        .foregroundColor(.pink)
                        .frame(width: width, height: height)
                } else {
                    ProgressView()
                        .frame(width: width, height: height)
                }
            }
        }
    }
}

#Preview {
    MyImage(url: K.imageUrl, height: 100, width: 100, isCircle: true)
}
