
import Foundation
import SwiftUI
import AVFoundation

struct MediaPicker : UIViewControllerRepresentable {
    @Binding var mediaURL : URL?
    @Binding var image : UIImage?
    @Binding var showError : Bool
    @Binding var errorMessage : String
    
    private let controller = UIImagePickerController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.image", "public.movie"] // Allow both images and videos
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                // Check video file size
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                if let fileSize = attributes?[.size] as? NSNumber {
                    let sizeInMB = fileSize.doubleValue / (1024 * 1024) // Convert to MB
                    if sizeInMB > 20.0 {
                        parent.showError = true
                        parent.errorMessage = K.ErrorMessages.fileTooLarge
                        picker.dismiss(animated: true)
                        return
                    }
                }
                print(url)
                parent.mediaURL = url
                parent.image = nil
            } else if let image = info[.originalImage] as? UIImage {
                // Check image size
                if let data = image.jpegData(compressionQuality: 1.0) {
                    let sizeInMB = Double(data.count) / (1024 * 1024) // Convert to MB
                    if sizeInMB > 20.0 {
                        parent.showError = true
                        parent.errorMessage = K.ErrorMessages.fileTooLarge
                        picker.dismiss(animated: true)
                        return
                    }
                }
                parent.image = image
                parent.mediaURL = nil
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
