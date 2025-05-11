
import Foundation
import UIKit
import FirebaseStorage

struct MediaHelper {
    func upLoadMediaToFirebase(_ attachment: MediaAttachment, completion: @escaping (Result<String, Error>) -> Void) async throws {
        let rsId = UUID().uuidString
        
        switch attachment.type {
        case .photo(let thumbnail):
            let imageRef = Storage.storage().reference(withPath: rsId)
            guard let imageData = thumbnail.jpegData(compressionQuality: 0.5) else {return}
            imageRef.putData(imageData, metadata: nil) { metaData, error in
                if error != nil {
                    completion(.failure(error!))
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if error != nil {
                        completion(.failure(error!))
                        return
                    }
                    if let downloadUrl = url?.absoluteString {
                        completion(.success(downloadUrl))
                    }
                }
            }
        case .audio(_, _):
            let audioRef = Storage.storage().reference(withPath:rsId)
            
            audioRef.putFile(from: attachment.fileURL!){ metaData, error in
                if error != nil {
                    completion(.failure(error!))
                    return
                }
                
                audioRef.downloadURL { url, error in
                    if error != nil {
                        completion(.failure(error!))
                        return
                    }
                    if let downloadUrl = url?.absoluteString{
                        completion(.success(downloadUrl))
                    }
                }
            }
        case .video(_, _):
            let videoRef = Storage.storage().reference(withPath: rsId)
            let videoData = try Data(contentsOf: attachment.fileURL!)
            
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "video/quicktime"
            
            videoRef.putData(videoData, metadata: uploadMetadata){ metaData, error in
                if error != nil {
                    completion(.failure(error!))
                    return
                }
                
                videoRef.downloadURL { url, error in
                    if error != nil {
                        completion(.failure(error!))
                        return
                    }
                    if let downloadUrl = url?.absoluteString{
                        completion(.success(downloadUrl))
                    }
                }
            }
        }
    }
    
    func getImageHeight(_ url: String,  completion: @escaping (Result<CGFloat, Error>) -> Void) {
        guard let imageUrl = URL(string: url) else { return }
        var imageHeight: CGFloat = 0
        var photoWidth = CGFloat(0)
        var photoHeight = CGFloat(0)
        let maxImageWidth = UIWindowScene.current?.maxImageWidth ?? 0
        let task = URLSession.shared.dataTask(with: imageUrl){ data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    photoWidth = uiImage.size.width
                    photoHeight = uiImage.size.height
                    imageHeight = CGFloat(photoHeight / photoWidth * maxImageWidth)
                    completion(.success(imageHeight))
                }
            } else {
                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
    }
}
