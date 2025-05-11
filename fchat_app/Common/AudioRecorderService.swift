
import Foundation
import AVFoundation
import Combine

final class AudioRecorderService {
    private var audioRecorder : AVAudioRecorder?
    private var startTime : Date?
    private var timer : AnyCancellable?
    @Published private(set) var isRecording = false
    @Published private(set) var elaspedTime : TimeInterval = 0
    
    deinit {
        tearDown()
        print("AudioRecorderService has been deinit")
    }
    
    func startRecording() {
        // Set up
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
            
        } catch {
            print("Fail to set up AVAudioSession")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileURL = documentPath.appendingPathComponent("myRcd_\(Date().displayDate(format: "dd_MM_yyyy_HH_mm_ss")).m4a")
        let settings = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey : 1,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startTime = Date()
            startTimer()
        } catch {
            print("Fail to start record")
        }
    }
    
    func stopRecording(completion: ((_ audioURL: URL?, _ audioDuration: TimeInterval) -> Void)? = nil) {
        guard isRecording else {return}
        let audioDuration = elaspedTime
        audioRecorder?.stop()
        timer?.cancel()
        isRecording = false
        elaspedTime = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setActive(false)
            guard let audioURL = audioRecorder?.url else {return}
            completion?(audioURL, audioDuration)
        } catch {
            print("VoiceRecorderService: Failed to teardown AVAudioSession")
        }
    }
    
    func tearDown(){
        if isRecording {
            stopRecording()
        }
        let fileManager = FileManager.default
        let folder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderContents = try! fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        deleteRecordings(folderContents)
        print("VoiceRecorderService: was successfully teared down")
    }
    
    private func deleteRecordings(_ urls: [URL]){
        for url in urls {
            deleteRecording(at: url)
        }
    }
    
    func deleteRecording(at fileURL: URL){
        do{
            try FileManager.default.removeItem(at: fileURL)
            print("Audio File was deleted at \(fileURL)")
        } catch {
            print("Failed to delete file")
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink{ [weak self] _ in
                guard let startTime = self?.startTime else {return}
                self?.elaspedTime = Date().timeIntervalSince(startTime)
            }
    }
}
