//
//  DragonRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/07.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import PlayTimeObject

protocol DragonRouterProtocol: Router {
    func close()
    func showDetail(dragon: Dragon)
}

class DragonRouter: NSObject, DragonRouterProtocol {

    weak var transitioner: Transitioner?
    var shouldFade: Bool = false
    convenience init(transitiner: Transitioner?) {
        self.init(transitioner: transitiner)
    }

    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func showDetail(dragon: Dragon) {
        let viewModel = DetailDragonViewModel(dragon: dragon)
        let viewController = DetailDragonViewController(viewModel: viewModel)
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .overCurrentContext
        transitioner?.present( viewController, true)
    }

    func close() {
        self.transitioner?.dismissFromRoot(true)
    }
}

extension DragonRouter: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let draVC = presenting.topViewControllerOnNavigationController as? DragonViewController,
            let deVC = presented.topViewControllerOnNavigationController as? DetailDragonViewController {
            return DragonPresentingAnimator(dragonViewController: draVC,
                                            detailDragonViewController: deVC)
        }
        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let draVC = dismissed.presentingViewController?.topViewControllerOnNavigationController as? DragonViewController,
            let deVC = dismissed.topViewControllerOnNavigationController as? DetailDragonViewController {
            return DragonDismissAnimator(dragonViewController: draVC,
                                         detailDragonViewController: deVC)
        }
        return nil
    }

}

class DragonPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    weak var dragonViewController: DragonViewController?
    weak var detailViewController: DetailDragonViewController?

    init(duration: TimeInterval = 0.3,
         dragonViewController: DragonViewController?,
         detailDragonViewController: DetailDragonViewController?
        ) {
        self.duration = duration
        self.dragonViewController = dragonViewController
        self.detailViewController = detailDragonViewController
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // アニメーションフィールド
        let containerView = transitionContext.containerView
        // 遷移先
        guard let draVC = dragonViewController else { return }
        guard let deVC = detailViewController else { return }

        containerView.addSubview(deVC.view)

        deVC.view.frame = draVC.ibDragonLibraryView.frame.changeHBy { $0.height }
        deVC.view.layoutIfNeeded()

        let imageView = UIImageView(image: deVC.viewModel.outputs.dragon.images.illust)
        var initialFrame: CGRect = .zero
        if let targetView = draVC.presentingAnimationTargetViews.first,
            let targetFrame = targetView.superview?.convert(targetView.frame, to: nil) {
            initialFrame = targetFrame
        }
        draVC.presentingAnimationTargetViews.first?.isHidden = true

        imageView.frame = initialFrame
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)
        deVC.ibDragonIllustImage.alpha = 0
        deVC.view.alpha = 0

        let imageFinalFrame = deVC.ibDragonIllustImage.superview?.convert(deVC.ibDragonIllustImage.frame, to: nil)

        UIView.animate(withDuration: duration,
                       animations: {
                        imageView.frame = imageFinalFrame ?? deVC.ibDragonIllustImage.frame
                        deVC.view.alpha = 1
        },
                       completion: { _ in
                        deVC.ibDragonIllustImage.alpha = 1
                        transitionContext.completeTransition(true)
                        imageView.removeFromSuperview()
        })

    }

}

class DragonDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    weak var dragonViewController: DragonViewController?
    weak var detailViewController: DetailDragonViewController?

    init(duration: TimeInterval = 0.3,
         dragonViewController: DragonViewController?,
         detailDragonViewController: DetailDragonViewController?
        ) {
        self.duration = duration
        self.dragonViewController = dragonViewController
        self.detailViewController = detailDragonViewController
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        // アニメーションフィールド
        let containerView = transitionContext.containerView
        // 遷移先
        guard let draVC = dragonViewController else { return }
        guard let deVC = detailViewController else { return }

        let imageView = UIImageView(image: deVC.viewModel.outputs.dragon.images.illust)
        var initialFrame: CGRect = .zero
        if let targetFrame = deVC.ibDragonIllustImage.superview?.convert(deVC.ibDragonIllustImage.frame, to: nil) {
            initialFrame = targetFrame
        }

        draVC.presentingAnimationTargetViews.first?.isHidden = true

        imageView.frame = initialFrame
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(deVC.view)
        containerView.addSubview(imageView)
        deVC.ibDragonIllustImage.alpha = 0
        var finalFrame: CGRect = .zero

        if let target = draVC.presentingAnimationTargetViews.first,
            let targetFrame = target.superview?.convert(target.frame, to: nil) {
            finalFrame = targetFrame
        }

        UIView.animate(withDuration: duration,
                       animations: {
                        imageView.frame = finalFrame
                        deVC.view.alpha = 0
        },
                       completion: { _ in
                        draVC.presentingAnimationTargetViews.first?.isHidden = false
                        imageView.removeFromSuperview()
                        transitionContext.completeTransition(true)

        })
    }

}
