//
//  Router.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/11.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit

protocol Router {
    var transitioner: Transitioner? { get }
    init(transitioner: Transitioner?)
}

// weakで持つためにAnyObjectに準拠
protocol Transitioner: NSObject {
    func push(_ :UIViewController?, _ animate: Bool, delegate: UINavigationControllerDelegate?)
    func present(_ : UIViewController?, _ animate: Bool)
    func pop(_ animate: Bool, delegate: UINavigationControllerDelegate?)
    func dismiss()
    func dismissFromRoot(_ animate: Bool)
    func setBarHidden(_ isHidden: Bool)
    func setModalPresentationStyle(style: UIModalPresentationStyle)
    var presentingAnimationTargetViews: [UIView] { get }
    var dismissingAnimationTargetViews: [UIView] { get }
    var uiViewController: UIViewController { get }

}

// Self: UIViewController と　Self　== UIViewController は違うんだね
extension Transitioner where Self: UIViewController {

    var uiViewController: UIViewController { return self }
    func push(_ viewController: UIViewController?, _ animate: Bool = true, delegate: UINavigationControllerDelegate? = nil) {
        if let viewController = viewController {
            self.navigationController?.delegate = delegate
            self.navigationController?.pushViewController(viewController, animated: animate)
        }
    }

    func present(_ viewController: UIViewController?, _ animate: Bool = true) {
        if let viewController = viewController {
            self.definesPresentationContext = true
            self.present(viewController, animated: animate, completion: nil)
        }
    }

    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    func pop(_ animate: Bool = true, delegate: UINavigationControllerDelegate? = nil) {
        self.navigationController?.delegate = delegate
        self.navigationController?.popViewController(animated: animate)
    }

    func dismissFromRoot(_ animate: Bool = true) {
        self.navigationController?.dismiss(animated: animate, completion: nil)
    }

    func setBarHidden(_ isHidden: Bool) {
        self.navigationController?.setNavigationBarHidden(isHidden, animated: true)
    }

    func setModalPresentationStyle(style: UIModalPresentationStyle) {
        self.modalPresentationStyle = style
    }
}
