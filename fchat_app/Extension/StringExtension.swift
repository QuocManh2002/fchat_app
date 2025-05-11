
import Foundation

extension String{
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func stringDateToDate(format: String = "yyyy-MM-dd HH:mm:ss Z") -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.timeZone = TimeZone(abbreviation: "GMT")
        
        guard let dateInGmt = dateFormat.date(from: self) else {
            print("Invalid date string")
            return nil
        }
        
        let outputFormat = DateFormatter()
        outputFormat.dateFormat = format
        outputFormat.timeZone = TimeZone(abbreviation: "GMT+7")
        
        let outputString = outputFormat.string(from: dateInGmt)
        
        return outputFormat.date(from: outputString)
    }
    
    func isPhoneNumber() -> Bool {
        let numericSet = CharacterSet.decimalDigits
        return self.rangeOfCharacter(from: numericSet.inverted) == nil
    }
    
    func phoneNumberStringFormat () -> String {
        let firstEndIndex = self.index(self.startIndex, offsetBy: 4)
        let first = String(self[..<firstEndIndex])
        
        let secondEndInput = self.index(self.startIndex, offsetBy: 7)
        let second = String(self[firstEndIndex..<secondEndInput])
        
        let third = String(self[secondEndInput...])
        
        return "\(first) \(second) \(third)"
    }
    
    func convertArrayToString(_ input : [String]) -> String {
        var result : String = ""
        for char in input {
            result += char
        }
        return result
    }
}
