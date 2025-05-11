
import SwiftUI
import AVKit

struct FullScreenMediaView : View {
    
    var url: URL?
    let player: AVPlayer?
    let attachmentType: MediaAttachmentType
    let dismissPlayer: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            switch attachmentType {
            case .photo(_):
                AsyncImage(url: url){ phase in
                    if let image = phase.image{
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth:0, maxWidth: .infinity,minHeight: 0, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if phase.error != nil {
                        Text(phase.error?.localizedDescription ?? "error")
                            .foregroundColor(.pink)
                            .frame(width: 100, height: 100)
                    } else {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                }
            case .audio( _, _):
                VideoPlayer(player: player)
                    .frame(minWidth:0, maxWidth: .infinity,minHeight: 0, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onAppear {
                        player!.play()
                    }
            case .video( _, _):
                VideoPlayer(player: player)
                    .frame(minWidth:0, maxWidth: .infinity,minHeight: 0, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onAppear {
                        player!.play()
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topTrailing) {
            dismissButton()
        }
    }
    
    private func dismissButton() -> some View {
        Button(action: {
            withAnimation {
                dismissPlayer()
            }
        }, label: {
            Image(systemName: "xmark")
                .foregroundColor(.white)
                .padding()
                .background(Color.white.opacity(0.35))
                .clipShape(Circle())
        })
        .padding()
    }
}
