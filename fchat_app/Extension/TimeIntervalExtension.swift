
import Foundation

extension TimeInterval {
    var formatElapsedTime: String{
        let minute = Int(self) / 60
        let second = Int(self) % 60
        
        return String(format: "%02d:%02d", minute, second)
    }
    
    static var stubTimeInterval: TimeInterval{
        return TimeInterval()
    }
}
