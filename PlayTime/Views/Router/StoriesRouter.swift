//
//  StoriesRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/12.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import PlayTimeObject
import Utilities

protocol StoriesRouterProtocol: Router {
    func toSettings()
    func toDetail(originFrame: CGRect, for isFinished: Bool)
    func toDragon()
    func toAddQuest(story: Story)
    func close()
    func toPlayingQuest(fromType: ActiveRoot)
}

class StoriesRouter: NSObject, StoriesRouterProtocol {

    weak var transitioner: Transitioner?
    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    let backgroundView: UIView? = {
        let closeView = UIView(frame: UIScreen.main.bounds)
        closeView.backgroundColor = Colors.backgroundLightClearBlack.uiColor
        return closeView
    }()

    func close() {
        transitioner?.dismissFromRoot(true)
    }

    func toSettings() {
        let viewController = SettingsViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        viewController.title = "setting".localized
        navigationController.transitioningDelegate = self
        navigationController.modalPresentationStyle = .overCurrentContext
        transitioner?.present(navigationController, true)
    }

    func toDetail(originFrame: CGRect, for isFinished: Bool = false) {
        let viewController = DetailQuestViewController.instantiate()
        let viewModel = DetailQuestViewModel(router: DetailQuestRouter(transitioner: viewController), isFinished: isFinished)
        viewController.viewModel = viewModel
        let nvc = UINavigationController(rootViewController: viewController)
        nvc.modalPresentationStyle = .overCurrentContext
        nvc.setNavigationBarHidden(true, animated: false)
        nvc.definesPresentationContext = true
        transitioner?.present(nvc, true)
    }

    func toDragon() {
        let viewController = DragonViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.transitioningDelegate = self
        navigationController.modalPresentationStyle = .overCurrentContext
        transitioner?.present(navigationController, true)
    }

    func toPlayingQuest(fromType: ActiveRoot) {

        let viewModel = PlayingQuestViewModel(fromType: fromType)
        let viewController = PlayingQuestViewController(viewModel: viewModel)
        viewModel.router = PlayingQuestRouter(transitiner: viewController)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.modalTransitionStyle = .crossDissolve
        navigationController.setNavigationBarHidden(true, animated: false)
        transitioner?.present(navigationController, true)
    }

    func toAddQuest(story: Story) {
        guard let viewModel = AddQuestViewModel(addStore: AddQuestStore(defaultStory: story, dragonName: .nii))
            else {
                return
        }
        let viewController = AddQuestViewController(viewModel: viewModel)

        viewModel.router = AddQuestRouter(transitioner: viewController)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        viewController.title = "createQuest".localized
        transitioner?.present(navigationController, true)
    }
}

extension StoriesRouter: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch presented.topViewControllerOnNavigationController {
        case is SettingsViewController:
            return ToSettingsPresentingAnimator(presented: presented, presenting: presenting, backgroundView: backgroundView)
        case is DragonViewController:
            return ToDragonPresentingAnimator(presented: presented, presenting: transitioner?.uiViewController, backgroundView: backgroundView)
        default:
            return nil
        }
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissed.topViewControllerOnNavigationController {
        case is SettingsViewController, is EditStoriesViewController:
            return ToSettingsDismissingAnimator(presented: dismissed, presenting: transitioner?.uiViewController, closeView: backgroundView)
        case is DragonViewController:
            return ToDragonDismissingAnimator(presented: dismissed, presenting: transitioner?.uiViewController, backgroundView: backgroundView)
        default:
            return nil
        }
    }

}

class ToSettingsPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    weak var presented: UIViewController?
    weak var presenting: UIViewController?
    weak var backgroundView: UIView?

    init(duration: TimeInterval = 0.5,
         presented: UIViewController?,
         presenting: UIViewController?,
         backgroundView: UIView?
        ) {
        self.duration = duration
        self.presented = presented
        self.presenting = presenting
        self.backgroundView = backgroundView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let presenting = presenting else { return }
        guard let presented = presented else { return }

        let transitionView = transitionContext.containerView

        let initialFrame = presenting.view.frame.changeXBy { -$0.width }
        let finalFrame = presenting.view.frame.changeWBy { $0.width * 0.8 }

        presented.view.frame = initialFrame

        if let backgroundView = backgroundView {
            let tapGesture = UITapGestureRecognizer(target: presented.topViewControllerOnNavigationController, action: #selector(SettingsViewController.close))
            backgroundView.addGestureRecognizer(tapGesture)

            let swipeGesture = UISwipeGestureRecognizer(target: presented.topViewControllerOnNavigationController, action: #selector(SettingsViewController.close))
            swipeGesture.direction = .left
            presented.view.addGestureRecognizer(swipeGesture)
            transitionView.addSubview(backgroundView)
            backgroundView.backgroundColor = Colors.backgroundLightClearBlack.uiColor
            backgroundView.alpha = 0
        }

        transitionView.addSubview(presented.view)
        transitionContext.completeTransition(true)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       animations: {
                        presented.view.frame = finalFrame
                        self.backgroundView?.alpha = 1
        })

    }

}

class ToSettingsDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    weak var presented: UIViewController?
    weak var presenting: UIViewController?
    weak var closeView: UIView?

    init(duration: TimeInterval = 0.5,
         presented: UIViewController?,
         presenting: UIViewController?,
         closeView: UIView?
        ) {
        self.duration = duration
        self.presented = presented
        self.presenting = presenting
        self.closeView = closeView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let presenting = presenting else { return }
        guard let presented = presented else { return }

        let transitionView = transitionContext.containerView
        let initialFrame = presented.view.frame
        let finalFrame = presented.view.frame.changeXBy { -$0.width }

        presented.view.frame = initialFrame
        transitionView.addSubview(presented.view)

        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       animations: {
                        presented.view.frame = finalFrame
                        self.closeView?.alpha = 0
        },
                       completion: { _ in
                        transitionContext.completeTransition(true)
        })

    }

}

class ToDragonPresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    weak var presented: UIViewController?
    weak var presenting: UIViewController?
    weak var backgroundView: UIView?

    init(duration: TimeInterval = 0.5,
         presented: UIViewController?,
         presenting: UIViewController?,
         backgroundView: UIView?
        ) {
        self.duration = duration
        self.presented = presented
        self.presenting = presenting
        self.backgroundView = backgroundView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let presenting = presenting as? StoriesViewController else { return }
        guard let presented = presented else { return }

        presented.view.frame = presenting.view.frame

        let transitionView = transitionContext.containerView
        if let closeView = backgroundView {
            transitionView.addSubview(closeView)
            closeView.backgroundColor = Colors.backgroundWhite.uiColor
        }

        transitionView.addSubview(presented.view)
        let mask = CAShapeLayer()

        let initialFrame = presenting.ibShowDragonButton.superview!.convert(presenting.ibShowDragonButton.frame, to: nil)
        let initialPath = CGPath(ellipseIn: initialFrame, transform: nil)

        let finishFrame = presenting.view
            .frame
            .changeXBy { -$0.width }
            .changeYBy { -$0.height / 2 }
            .changeWBy { $0.height * 3 }
            .changeHBy { $0.height * 3 }

        let finishPath = CGPath(ellipseIn: finishFrame, transform: nil)

        mask.path = initialPath
        presented.view.layer.mask = mask
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = initialPath
        animation.toValue = finishPath
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)

        presented.view.layer.mask?.add(animation, forKey: "circular")
        backgroundView?.alpha = 1
        transitionContext.completeTransition(true)
    }

}

class ToDragonDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    weak var presented: UIViewController?
    weak var presenting: UIViewController?
    weak var backgroundView: UIView?

    init(duration: TimeInterval = 0.5,
         presented: UIViewController?,
         presenting: UIViewController?,
         backgroundView: UIView?
        ) {
        self.duration = duration
        self.presented = presented
        self.presenting = presenting
        self.backgroundView = backgroundView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let presenting = presenting as? StoriesViewController else { return }
        guard let presented = presented?.topViewControllerOnNavigationController as? DragonViewController else { return }

        let mask = CAShapeLayer()

        let initialFrame = presenting.view
            .frame
            .changeXBy { -$0.width }
            .changeYBy { -$0.height / 2 }
            .changeWBy { $0.height * 3 }
            .changeHBy { $0.height * 3 }

        let finishFrame = presenting.ibShowDragonButton
            .superview?
            .convert(presenting.ibShowDragonButton.frame, to: nil) ?? .zero

        let initialPath = CGPath(ellipseIn: initialFrame, transform: nil)
        let finishPath = CGPath(ellipseIn: finishFrame, transform: nil)

        mask.path = initialPath
        presented.view.layer.mask = mask

        backgroundView?.alpha = 0
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = initialPath
        animation.toValue = finishPath
        animation.duration = duration
        animation.timingFunction = .init(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        presented.view.layer.mask?.add(animation, forKey: "circular")
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       animations: {
                        presented.ibBackButton.alpha = 0
        },
                       completion: { _ in
                        transitionContext.completeTransition(true)
        })

    }

}
