import UIKit

extension Int {
    func dayStringEnding() -> String {
        var dayString: String = ""
        if self % 10 == 1{
            dayString = "день"
        } else if self % 10 >= 2 && self % 10 <= 4 {
            dayString = "дня"
        } else if self % 10 == 0 || (self % 10 >= 5 && self % 10 <= 9) {
            dayString = "дней"
        } else {
            dayString = "дней"
        }
        return "\(self) " + dayString
    }
}
