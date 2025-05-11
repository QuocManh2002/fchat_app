
import Foundation

extension Date{
    func displayDate(format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+7")
        return dateFormatter.string(from: self)
    }
    
    func getDateMessageString() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self){
            return "Hôm nay"
        } else if calendar.isDateInYesterday(self){
            return "Hôm qua"
        } else if isCurrentWeek() {
            return displayDate(format: "EEEE")
        } else {
            return displayDate(format: "dd/MM/yyyy")
        }
    }
    
    func isCurrentWeek() -> Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekday)
    }
    
    func isSameDate(with otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}
