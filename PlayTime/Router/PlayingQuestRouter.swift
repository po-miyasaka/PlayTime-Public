//
//  PlayingQuestRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/18.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol PlayingQuestRouterProtocol: Router {
    func fadeClose()
    func close()
    func pop()
}

class PlayingQuestRouter: NSObject, PlayingQuestRouterProtocol {

    weak var transitioner: Transitioner?
    var shouldFade: Bool = false

    convenience init(transitiner: Transitioner?) {
        self.init(transitioner: transitiner)
    }

    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func fadeClose() {
        shouldFade = true
        (transitioner as? PlayingQuestViewController)?.navigationController?.transitioningDelegate = self
        transitioner?.dismissFromRoot(true)
    }

    func close() {
        (transitioner as? PlayingQuestViewController)?.navigationController?.transitioningDelegate = self
        transitioner?.dismissFromRoot(true)
    }

    func pop() {
        transitioner?.pop(true, delegate: (transitioner as? UIViewController)?.navigationController?.delegate)
    }
}

extension PlayingQuestRouter: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let pvc = dismissed.topViewControllerOnNavigationController as? PlayingQuestViewController else {
            return nil
        }

        let dragonTransitionView = SKView(frame: pvc.ibDragonDotView.frame)
        dragonTransitionView.allowsTransparency = true
        dragonTransitionView.presentScene(pvc.ibDragonDotView.scene?.copy() as? SKScene)

        guard let originFrame = pvc.ibDragonDotView.superview?.convert(dragonTransitionView.frame, to: nil) else {
            return nil
        }
        dragonTransitionView.frame = originFrame
        return PlayingQuestDismissAnimator(originFrame: originFrame,
                                           dragonTransitionView: dragonTransitionView,
                                           playingQuestViewController: pvc,
                                           shouldFade: shouldFade)
    }
}

class PlayingQuestDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    let originFrame: CGRect
    let dragonTransitionView: SKView
    let shouldFade: Bool
    weak var playingQuestViewController: PlayingQuestViewController?

    init(duration: TimeInterval = 0.5,
         originFrame: CGRect,
         dragonTransitionView: SKView,
         playingQuestViewController: PlayingQuestViewController,
         shouldFade: Bool) {
        self.duration = duration
        self.originFrame = originFrame
        self.dragonTransitionView = dragonTransitionView
        self.playingQuestViewController = playingQuestViewController
        self.shouldFade = shouldFade
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // アニメーションフィールド
        let containerView = transitionContext.containerView
        // 遷移先
        guard let svc = (transitionContext.viewController(forKey: .to) as? StoriesViewController) else { return }
        guard let pvc = self.playingQuestViewController else { return }
        guard let screenShot = pvc.view.screenShot else { return }

        pvc.ibDragonDotView.isHidden = true

        let imageView = UIImageView(image: screenShot)
        imageView.frame = svc.view.frame
        containerView.alpha = 0
        svc.view.addSubview(imageView)
        svc.view.addSubview(dragonTransitionView)

        let destinationFrame = svc.ibDragonDotView.convert(svc.view.frame, to: nil)
        if !shouldFade {
            svc.showFinishWithFade()
        }

        UIView.animate(withDuration: duration,
                       animations: {
                        if self.shouldFade {
                            self.dragonTransitionView.alpha = 0
                        } else {
                            self.dragonTransitionView.frame = self.dragonTransitionView.frame.change(x: destinationFrame.origin.x).change(y: destinationFrame.origin.y)
                        }

                        imageView.alpha = 0
        },
                       completion: { _ in
                        svc.showFinishDragonView()
                        self.dragonTransitionView.removeFromSuperview()
                        imageView.removeFromSuperview()
                        transitionContext.completeTransition(true)
        })

    }

}
