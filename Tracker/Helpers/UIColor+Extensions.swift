import UIKit

extension UIColor {
    static var ypSearchBar: UIColor { UIColor(named: "YP search bar") ?? UIColor.white}
    static var ypWhiteSimple: UIColor { UIColor(named: "YP white simple") ?? UIColor.white}
    static var ypSeparator: UIColor { UIColor(named: "YP separator") ?? UIColor.white}
    static var ypBackground: UIColor { UIColor(named: "YP Background") ?? UIColor.white}
    static var dateColor: UIColor { UIColor(named: "YP date") ?? UIColor.white}
    static var titleColor: UIColor { UIColor(named: "YP White Title") ?? UIColor.white}
    static var ypBlue: UIColor { UIColor(named: "YP Blue") ?? UIColor.blue }
    static var ypGreen: UIColor { UIColor(named: "YP Green") ?? UIColor.green }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? UIColor.white }
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? UIColor.black }
    static var ypPink: UIColor { UIColor(named: "YP Pink") ?? UIColor.systemPink }
    static func rgbColors(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
    static let activeColor = UIColor.rgbColors(red: 26, green: 27, blue: 34, alpha: 1)
    static let inactiveColor = UIColor.rgbColors(red: 174, green: 175, blue: 180, alpha: 1)
}
