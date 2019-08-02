//
//  DetailQuestRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/14.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

protocol DetailQuestRouterProtocol: Router {
    func close()
    func closeForFinish()
    func toStart()
    func toEditingComment(viewModel: DetailQuestViewModel?)
}

class DetailQuestRouter: NSObject, DetailQuestRouterProtocol {

    weak var transitioner: Transitioner?
    var dragonTransitionView = SKView()
    var odirinDragonFrame: CGRect = .zero

    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func close() {
        (transitioner as? DetailQuestViewController)?.navigationController?.transitioningDelegate = nil
        transitioner?.dismissFromRoot(true)
    }

    func closeForFinish() {
        transitioner?.dismiss()
    }

    func toStart() {
        let viewModel = PlayingQuestViewModel(fromType: .detail)
        let viewController = PlayingQuestViewController(viewModel: viewModel)
        viewModel.router = PlayingQuestRouter(transitiner: viewController)
        transitioner?.push(viewController, true, delegate: self)
    }

    func toEditingComment(viewModel: DetailQuestViewModel?) {
        if let viewModel = viewModel {
            let viewController = CommentWriteViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: viewController)
            switch viewModel.outputs.editingComment?.type {
            case .creating?:
                viewController.title = "newComment".localized
            default:
                viewController.title = "editComment".localized
            }
            transitioner?.present(navigationController, true)
        }
    }
}

extension DetailQuestRouter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        var detailQuestViewController: DetailQuestViewController?
        var playingQuestViewController: PlayingQuestViewController?

        if let fromVC = fromVC as? DetailQuestViewController {
            let dragonTransitionView = SKView(frame: fromVC.ibDragonDotView.frame)
            dragonTransitionView.allowsTransparency = true
            dragonTransitionView.presentScene(fromVC.ibDragonDotView.scene?.copy() as? SKScene)
            self.dragonTransitionView = dragonTransitionView
            odirinDragonFrame = fromVC.ibDragonDotView.superview!.convert(dragonTransitionView.frame, to: nil)
            dragonTransitionView.frame = odirinDragonFrame
            detailQuestViewController = fromVC
        } else if let toVC = toVC as? DetailQuestViewController {
            detailQuestViewController = toVC
        }

        if let toVC = toVC as? PlayingQuestViewController {
            playingQuestViewController = toVC
        } else if let fromVC = fromVC as? PlayingQuestViewController {
            playingQuestViewController = fromVC
        }

        return DetailQuestTransitionAnimator(isPresenting: operation == .push, dragonTransitionView: dragonTransitionView,
                                             dragonOriginFrame: odirinDragonFrame,
                                             detailQuestViewController: detailQuestViewController,
                                             playingQuestViewController: playingQuestViewController)
    }
}

class DetailQuestTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval
    let isPresenting: Bool
    var dragonOriginFrame: CGRect
    weak var dragonTransitionView: SKView?
    weak var detailQuestViewController: DetailQuestViewController?
    weak var playingQuestViewController: PlayingQuestViewController?

    init(duration: TimeInterval = 0.3,
         isPresenting: Bool,
         dragonTransitionView: SKView?,
         dragonOriginFrame: CGRect,
         detailQuestViewController: DetailQuestViewController?,
         playingQuestViewController: PlayingQuestViewController?) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.dragonTransitionView = dragonTransitionView
        self.dragonOriginFrame = dragonOriginFrame
        self.detailQuestViewController = detailQuestViewController
        self.playingQuestViewController = playingQuestViewController
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        if isPresenting {
            present(transitionContext: transitionContext)
        } else {
            dismiss(transitionContext: transitionContext)
        }

    }

    func present(transitionContext: UIViewControllerContextTransitioning) {

        guard let detailQuestViewController = detailQuestViewController else { return }
        guard let playingQuestViewController = playingQuestViewController else { return }
        guard let dragonTransitionView = dragonTransitionView else { return }

        let containerView = transitionContext.containerView
        containerView.addSubview(detailQuestViewController.view)
        containerView.addSubview(playingQuestViewController.view)
        containerView.addSubview(dragonTransitionView)

        playingQuestViewController.view.alpha = 0
        playingQuestViewController.ibDragonDotView.isHidden = true

        playingQuestViewController.view.layoutIfNeeded()
        playingQuestViewController.ibCancelButton.alpha = 0
        detailQuestViewController.ibDragonDotView.alpha = 0

        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {

                        playingQuestViewController.view.alpha = 1
                        dragonTransitionView.frame = self.dragonOriginFrame
                            .change(x: 0)
                            .change(y: playingQuestViewController.view.height - dragonTransitionView.height - 72)

                        playingQuestViewController.ibCancelButton.alpha = 1

        }, completion: {_ in
            dragonTransitionView.alpha = 0
            playingQuestViewController.ibDragonDotView.isHidden = false
            transitionContext.completeTransition(true)
        })

    }

    func dismiss(transitionContext: UIViewControllerContextTransitioning) {

        guard let detailQuestViewController = detailQuestViewController else { return }
        guard let playingQuestViewController = playingQuestViewController else { return }
        guard let dragonTransitionView = dragonTransitionView else { return }

        let containerView = transitionContext.containerView

        containerView.addSubview(detailQuestViewController.view)
        containerView.addSubview(playingQuestViewController.view)
        containerView.addSubview(dragonTransitionView)

        detailQuestViewController.view.layoutIfNeeded()
        dragonTransitionView.alpha = 1
        playingQuestViewController.ibDragonDotView.isHidden = true

        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {

                        dragonTransitionView.frame = self.dragonOriginFrame
                        playingQuestViewController.view.alpha = 0
                        detailQuestViewController.view.layoutIfNeeded()

        }, completion: {_ in

            dragonTransitionView.alpha = 0
            detailQuestViewController.ibDragonDotView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }

}
