
import SwiftUI

struct MediaAttachmentView: View {
    let mediaAttachment: [MediaAttachment]
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(mediaAttachment){attachment in
                    if attachment.type == .audio(.stubURL, .stubTimeInterval){
                        audioAttachment(attachment)
                    } else {
                        thumbnailImageView(attachment)
                    }
                }
            }
        }
        .frame(height: Constants.listHeight)
        .frame(maxWidth: .infinity)
        .background(.white)
        .padding(.horizontal, 10)
    }
    
    private func thumbnailImageView(_ attachment: MediaAttachment) -> some View {
        Image(uiImage: attachment.thumbnail)
            .resizable()
            .scaledToFill()
            .frame(width: Constants.imageDimen, height: Constants.listHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                cancelButton(attachment)
            }
            .overlay {
                playButton(false, attachment)
                    .opacity(attachment.type == .video(UIImage(), .stubURL) ? 1 : 0)
            }
        
    }
    
    private func cancelButton(_ attachment: MediaAttachment) -> some View{
        Button {
            actionHandler(.remove(attachment))
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .padding(5)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(.circle)
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func playButton(_ isAudio: Bool,_ attachment: MediaAttachment) -> some View{
        Button {
            actionHandler(.play(attachment))
        } label: {
            Image(systemName: isAudio ? "mic.fill" : "play.fill")
                .scaledToFit()
                .imageScale(.small)
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(.circle)
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func audioAttachment(_ attachment: MediaAttachment) -> some View {
        ZStack{
            LinearGradient(colors: [.green, .green.opacity(0.8), .teal], startPoint: .topLeading, endPoint: .bottom)
            playButton(true, attachment)
        }
        .frame(width: Constants.imageDimen * 1.5, height: Constants.listHeight)
        .cornerRadius(5)
        .clipped()
        .overlay(alignment: .topTrailing) {
            cancelButton(attachment)
        }
        .overlay(alignment: .bottomLeading) {
            Text(attachment.fileURL?.absoluteString ?? "Unknown")
                .lineLimit(1)
                .font(.caption)
                .padding(2)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
        }
    }
}

extension MediaAttachmentView {
    enum Constants {
        static let listHeight: CGFloat = 100
        static let imageDimen: CGFloat = 120
        static let cancelIcon: String = "xmark"
        static let playIcon: String = "play.fill"
        static let micIcon: String = ""
    }
    
    enum UserAction {
        case play(_ item: MediaAttachment)
        case remove(_ item: MediaAttachment)
    }
}
