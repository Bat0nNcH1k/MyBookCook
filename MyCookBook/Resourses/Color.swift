import UIKit

extension UIColor {
    static let text = UIColor { $0.userInterfaceStyle == .light ? .black : .white }
    static let background = UIColor { $0.userInterfaceStyle == .light ? .white : .black }
    static let backgroundGray = UIColor.lightGray.withAlphaComponent(0.2)
}
