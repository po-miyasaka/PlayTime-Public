//
//  Extensions.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/02Tuesday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation
import UIKit

public extension NSObjectProtocol {
    public static var className: String {
        return String(describing: self)
    }

    public var className: String {
        return type(of: self).className
    }
}

public protocol StoryBoardInstantiatable {}
extension UIViewController: StoryBoardInstantiatable {}
public extension StoryBoardInstantiatable where Self: UIViewController {
    public static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: className, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self // swiftlint:disable:this force_cast
    }

    public static func instantiate(withStoryboard storyboard: String) -> Self {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self // swiftlint:disable:this force_cast
    }
}
public protocol UIViewInstantiatable {}
extension UIView: UIViewInstantiatable {}
public extension UIViewInstantiatable where Self: UIView {
    public static func instant() -> Self {
        return UINib(nibName: self.className, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! Self  // swiftlint:disable:this force_cast
    }
}

public extension Array {

    public func groupBy<T: Hashable>(_ callback: (Iterator.Element) -> T) -> [T: [Iterator.Element]] {
        var grouped = [T: Array<Iterator.Element>]()

        forEach {
            let key = callback($0)
            if var array = grouped[key] {
                array.append($0)
                grouped[key] = array
            } else {
                grouped[key] = [$0]
            }
        }

        return grouped
    }

    public func safeFetch(_ index: Int) -> Element? {
        guard count > index, index >= 0 else { return nil }
        return self[index]
    }

    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

public extension String {
    public func timeFormat() -> String {
        return self.count == 1 ? "0" + self : self
    }

    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func toURL() -> URL? {
        guard let url = URL(string: self) else { return nil }
        return url
    }
    
    public func truncate(limit: Int) -> String {
        let length = min(self.count, limit)
        let strArr = Array(self)
        return (0..<length).reduce("") { (result: String, index: Int) -> String in
            result + String(strArr[index])
        }
    }
}

public extension CGFloat {
    public func randomPoint() -> CGFloat {
        return CGFloat(arc4random() % UInt32(self))
    }
}

public extension Int {
    public func otoshi(_ max: Int) -> Int {
        return self > max ? max : self
    }

    public var random: Int {
        return Int(arc4random() % UInt32(self))
    }
    public var toCGFloat: CGFloat {
        return CGFloat(self)
    }

    public var toDouble: Double {
        return Double(self)
    }

    public var toString: String {
        return "\(self)"
    }
}

public extension Double {
    public var toInt: Int {
        return Int(self)
    }

    public var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}

extension String {
    public func toDouble() -> Double {
        return Double(self)!
    }

    public static func =?(lhs: String?, rhs: String) -> String {
        guard let lhs = lhs, !lhs.isEmpty else { return rhs }
        return lhs
    }
}
infix operator =?

public extension UIView {
    public var height: CGFloat {
        return frame.height
    }

    public var width: CGFloat {
        return frame.width
    }

    public func animateShow(target: UIView?) {
        guard let target = target else { return }
        let viewHeight = self.height
        let viewWidth = self.width
        target.center = CGPoint(x: (viewWidth / 2), y: viewHeight + (target.height / 2))
        self.addSubview(target)
        UIView.animate(withDuration: 0.2) {
            target.center = CGPoint(x: (viewWidth / 2), y: viewHeight - (target.height / 2) - 10)
        }
    }

    public func remove(target: UIView?, handler: (() -> Void)? = nil) {
        guard let target = target else { return }
        let viewHeight = self.height
        let viewWidth = self.width

        UIView.animate(withDuration: 0.2,
                       animations: {
                        target.center = CGPoint(x: (viewWidth / 2), y: viewHeight + (target.height / 2))
        },
                       completion: {_ in
                        target.removeFromSuperview()
                        handler?()
        })
    }

    public var screenShot: UIImage? {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        guard let _ = UIGraphicsGetCurrentContext()  else { return nil }
        self.drawHierarchy(in: rect, afterScreenUpdates: true)
        guard let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return capturedImage
    }

}

public extension Optional where Wrapped == UIView {
    public func animateShow(target: UIView?) {
        guard let self = self else { return }
        self.animateShow(target: target)
    }

    public func remove(target: UIView?, handler: (() -> Void)? = nil) {
        guard let self = self else { return }
        self.remove(target: target, handler: handler)
    }
}

public extension UIViewController {
    public func showAlert(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    public func viewController<T: UIViewController>(type: T.Type) -> UIViewController? {
        var result: UIViewController?

        while result != nil {
            if self.presentingViewController == nil {
                break
            }
            result = self.presentingViewController as? T
        }

        return result
    }

    public var topViewControllerOnNavigationController: UIViewController? {
        return (self as? UINavigationController)?.topViewController ?? self
    }
}

public protocol Nibable: NSObjectProtocol {
    static var nibName: String { get }
    static var nib: UINib { get }
}

public extension Nibable {
    public static var nibName: String {
        return className
    }
    public static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}

public extension UICollectionView {
    public func register<T: UICollectionViewCell>(_ cellType: T.Type) where T: Nibable {
        self.register(cellType.nib, forCellWithReuseIdentifier: cellType.className)
    }

    public func dequeue<T: UICollectionViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        let item = self.dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as? T
        return item!
    }
}

public extension UITableView {
    public func register<T: UITableViewCell>(_ cellType: T.Type) where T: Nibable {
        register(T.nib, forCellReuseIdentifier: T.className)
    }

    public func dequeue<T: Configurable>(t: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T // swiftlint:disable:this force_cast
    }
}

public extension CGRect {
    public func change(x: CGFloat) -> CGRect {
        return CGRect(x: x, y: self.origin.y, width: self.size.width, height: self.size.height)
    }

    public func change(y: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x, y: y, width: self.size.width, height: self.size.height)
    }

    public func change(width: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: width, height: self.size.height)
    }

    public func change(height: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.size.width, height: height)
    }

    public func changeXBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: transform(self), y: self.origin.y, width: self.size.width, height: self.size.height)
    }

    public func changeYBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: self.origin.x, y: transform(self), width: self.size.width, height: self.size.height)
    }

    public func changeWBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: transform(self), height: self.size.height)
    }

    public func changeHBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.size.width, height: transform(self))
    }

    public func randomPoint() -> CGPoint {
        return CGPoint(x: (Int(size.width)).random.toCGFloat, y: (Int(size.height)).random.toCGFloat)
    }
}

public extension UIColor {
    public convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

public extension Array where Element: Hashable {
    public var toSet: Set<Element> {
        return Set(self)
    }
}

public extension Set {
    public var toArray: [Element] {
        return Array(self)
    }
}

public protocol Configurable: NSObjectProtocol {
    associatedtype CellData
    func configure(data: CellData, indexPath: IndexPath)
    var indexPath: IndexPath? { get }
}
