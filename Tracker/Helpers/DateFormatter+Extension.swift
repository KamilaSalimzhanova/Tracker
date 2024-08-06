import Foundation

extension DateFormatter {
    static func weekday(date: Date) -> String {
        guard let weekdayNumber = Calendar.current.dateComponents([.weekday], from: date).weekday else {
            return "Нет такого дня недели"
        }
        var weekday = ""
        switch weekdayNumber {
        case 1: weekday = Weekdays.Sunday.rawValue
        case 2: weekday = Weekdays.Monday.rawValue
        case 3: weekday = Weekdays.Tuesday.rawValue
        case 4: weekday = Weekdays.Wednesday.rawValue
        case 5: weekday = Weekdays.Thursday.rawValue
        case 6: weekday = Weekdays.Friday.rawValue
        case 7: weekday = Weekdays.Saturday.rawValue
        default: weekday = "Нет такого дня недели"
        }
        return weekday
    }
}
