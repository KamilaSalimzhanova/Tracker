import UIKit

extension UIColor {
    static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? UIColor.blue }
    static var ypGreen: UIColor { UIColor(named: "YP Green") ?? UIColor.green }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white }
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black }
    static var ypPink: UIColor { UIColor(named: "YP Pink") ?? UIColor.systemPink }
    static func rgbColors(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
