//
//  Extensions.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/02Tuesday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension NSObjectProtocol {
    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}

protocol StoryBoardInstantiatable {}
extension UIViewController: StoryBoardInstantiatable {}
extension StoryBoardInstantiatable where Self: UIViewController {
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: className, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self // swiftlint:disable:this force_cast
    }

    static func instantiate(withStoryboard storyboard: String) -> Self {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self // swiftlint:disable:this force_cast
    }
}
protocol UIViewInstantiatable {}
extension UIView: UIViewInstantiatable {}
extension UIViewInstantiatable where Self: UIView {
    static func instant() -> Self {
        return UINib(nibName: self.className, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! Self  // swiftlint:disable:this force_cast
    }
}

extension Array {

    func groupBy<T: Hashable>(_ callback: (Iterator.Element) -> T) -> [T: [Iterator.Element]] {
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

    func safeFetch(_ index: Int) -> Element? {
        guard count > index, index >= 0 else { return nil }
        return self[index]
    }

    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension String {
    func timeFormat() -> String {
        return self.count == 1 ? "0" + self : self
    }

    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func toURL() -> URL? {
        guard let url = URL(string: self) else { return nil }
        return url
    }
    
    func truncate(limit: Int) -> String {
        let length = min(self.count, limit)
        let strArr = Array(self)
        return (0..<length).reduce("") { (result: String, index: Int) -> String in
            result + String(strArr[index])
        }
    }
}

extension CGFloat {
    func randomPoint() -> CGFloat {
        return CGFloat(arc4random() % UInt32(self))
    }
}

extension Int {
    func otoshi(_ max: Int) -> Int {
        return self > max ? max : self
    }

    var random: Int {
        return Int(arc4random() % UInt32(self))
    }
    var toCGFloat: CGFloat {
        return CGFloat(self)
    }

    var toDouble: Double {
        return Double(self)
    }

    var toString: String {
        return "\(self)"
    }
}

extension Double {
    var toInt: Int {
        return Int(self)
    }

    var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}

extension String {
    func toDouble() -> Double {
        return Double(self)!
    }

    static func =?(lhs: String?, rhs: String) -> String {
        guard let lhs = lhs, !lhs.isEmpty else { return rhs }
        return lhs
    }
}
infix operator =?

extension UIView {
    var height: CGFloat {
        return frame.height
    }

    var width: CGFloat {
        return frame.width
    }

    func animateShow(target: UIView?) {
        guard let target = target else { return }
        let viewHeight = self.height
        let viewWidth = self.width
        target.center = CGPoint(x: (viewWidth / 2), y: viewHeight + (target.height / 2))
        self.addSubview(target)
        UIView.animate(withDuration: 0.2) {
            target.center = CGPoint(x: (viewWidth / 2), y: viewHeight - (target.height / 2) - 10)
        }
    }

    func remove(target: UIView?, handler: (() -> Void)? = nil) {
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

    var screenShot: UIImage? {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        guard let _ = UIGraphicsGetCurrentContext()  else { return nil }
        self.drawHierarchy(in: rect, afterScreenUpdates: true)
        guard let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return capturedImage
    }

}

extension Optional where Wrapped == UIView {
    func animateShow(target: UIView?) {
        guard let self = self else { return }
        self.animateShow(target: target)
    }

    func remove(target: UIView?, handler: (() -> Void)? = nil) {
        guard let self = self else { return }
        self.remove(target: target, handler: handler)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func viewController<T: UIViewController>(type: T.Type) -> UIViewController? {
        var result: UIViewController?

        while result != nil {
            if self.presentingViewController == nil {
                break
            }
            result = self.presentingViewController as? T
        }

        return result
    }

    var topViewControllerOnNavigationController: UIViewController? {
        return (self as? UINavigationController)?.topViewController ?? self
    }
}

protocol Nibable: NSObjectProtocol {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension Nibable {
    static var nibName: String {
        return className
    }
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ cellType: T.Type) where T: Nibable {
        self.register(cellType.nib, forCellWithReuseIdentifier: cellType.className)
    }

    func dequeue<T: UICollectionViewCell>(type: T.Type, indexPath: IndexPath) -> T {
        let item = self.dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as? T
        return item!
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_ cellType: T.Type) where T: Nibable {
        register(T.nib, forCellReuseIdentifier: T.className)
    }

    func dequeue<T: Configurable>(t: T.Type, indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.className, for: indexPath) as! T // swiftlint:disable:this force_cast
    }
}

extension CGRect {
    func change(x: CGFloat) -> CGRect {
        return CGRect(x: x, y: self.origin.y, width: self.size.width, height: self.size.height)
    }

    func change(y: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x, y: y, width: self.size.width, height: self.size.height)
    }

    func change(width: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: width, height: self.size.height)
    }

    func change(height: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.size.width, height: height)
    }

    func changeXBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: transform(self), y: self.origin.y, width: self.size.width, height: self.size.height)
    }

    func changeYBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: self.origin.x, y: transform(self), width: self.size.width, height: self.size.height)
    }

    func changeWBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: transform(self), height: self.size.height)
    }

    func changeHBy(transform: ((CGRect) -> CGFloat)) -> CGRect {
        return CGRect(x: self.origin.x, y: self.origin.y, width: self.size.width, height: transform(self))
    }

    func randomPoint() -> CGPoint {
        return CGPoint(x: (Int(size.width)).random.toCGFloat, y: (Int(size.height)).random.toCGFloat)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
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
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

extension Array where Element: Hashable {
    var toSet: Set<Element> {
        return Set(self)
    }
}

extension Set {
    var toArray: [Element] {
        return Array(self)
    }
}
