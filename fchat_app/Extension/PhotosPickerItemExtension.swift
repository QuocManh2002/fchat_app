
import Foundation
import SwiftUI
import PhotosUI

extension PhotosPickerItem {
    var isVideo: Bool {
        let videoUTTypes: [UTType] = [
            .avi,
            .video,
            .mpeg2Video,
            .mpeg4Movie,
            .movie,
            .quickTimeMovie,
            .audiovisualContent,
            .mpeg,
            .appleProtectedMPEG4Video
        ]
        return videoUTTypes.contains(where: supportedContentTypes.contains)
    }
}
