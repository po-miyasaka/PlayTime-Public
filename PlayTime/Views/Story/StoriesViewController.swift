//
//  StoriesViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/26.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import SpriteKit
import PlayTimeObject
import Utilities

class StoriesViewController: UIViewController {
    lazy var viewModel = StoriesViewModel(router: StoriesRouter(transitioner: self))
    @IBOutlet weak var ibDragonDotView: SKView!
    var disposeBag = DisposeBag()
    @IBOutlet weak var ibShowDragonButton: UIButton!
    @IBOutlet private weak var ibSettingButton: UIButton!
    @IBOutlet private weak var storyTitleCollectionView: StoryTitleCollectionView!
    @IBOutlet private weak var deletingButtonView: DeletingButtonView!
    @IBOutlet weak var ibFinishedQuestLabel: UILabel!
    @IBOutlet private weak var ibAddButton: UIButton!
    @IBOutlet weak var ibReturnBaseLabel: UILabel! {
        didSet {
            ibReturnBaseLabel.text = "returnBaseExpression".localized
        }
    }

    @IBOutlet private weak var ibFinishingView: UIView! {
        didSet {
            self.ibFinishingView.alpha = 0
            let gesture = UITapGestureRecognizer(target: self, action: #selector(finishViewTapOn))
            self.ibFinishingView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet weak var ibLeadCommentLabel: UILabel! {
        didSet {
            ibLeadCommentLabel.text = "askWriteComment".localized
        }
    }

    var currentPageInt = 0
    var pageAction: (() -> Int)?
    var pageViewController: UIPageViewController? {
        return self.children.compactMap { $0 as? UIPageViewController }.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPageViewController()
        bind()
    }

    func setUpPageViewController() {
        pageViewController?.delegate = self
        pageViewController?.dataSource = self
    }

    func bind() {
        viewModel.setUp()
        deletingButtonView?.bind(viewModel: viewModel)
        storyTitleCollectionView?.bind(viewModel: viewModel)

        viewModel
            .outputs
            .showAlertSignal
            .emit(onNext: {[weak self] in
                self?.showAlert(title: $0.title, message: $0.message)})
            .disposed(by: disposeBag)

        viewModel.outputs
            .selectedStoryDriver
            .drive(onNext: {[weak self] select in
                guard let self = self else { return }
                guard let targetType = select.after else { return }

                switch select.reason {
                case .swipe:
                    return
                case .select:
                    break
                case .launch:
                    break
                }

                let move = self.directionFrom(tuple: select)
                switch targetType {
                case .story(let dto):
                    let q = QuestListViewController(viewModel: QuestListViewModel(story: dto, storiesRouter: self.viewModel.router))
                    self.pageViewController?.setViewControllers([q], direction: move.0 ?? .forward, animated: move.1, completion: nil)

                case .add:
                    let viewModel = EditStoryViewModel(selected: nil, isStoriesViewController: true)
                    let vc = EditStoryViewController(viewModel: viewModel)
                    self.pageViewController?.setViewControllers([vc], direction: move.0 ?? .forward, animated: move.1, completion: nil)
                }

                self.currentPageInt = self.viewModel.outputs.views.index(where: {
                    type in
                    type.isEqual(type: select.after!)
                }) ?? 0 // FIXME

            }).disposed(by: disposeBag)

        viewModel.outputs.showTutorialSignal.map { [weak self] in
            guard let self = self else { return }
            let page0 = TutorialPageData(forcusFrame: nil, expression: "story_tutorial1".localized, image: nil)
            let page1 = TutorialPageData(forcusFrame: nil, expression: "story_tutorial2".localized, image: UIImage(named: "tut1"))
            let page2 = TutorialPageData(forcusFrame: self.ibAddButton.superview!.convert(self.ibAddButton.frame, to: nil), expression: "story_tutorial3".localized)
            let page3 = TutorialPageData(forcusFrame: self.storyTitleCollectionView.frame, expression: "story_tutorial4".localized)
            let page4 = TutorialPageData(forcusFrame: self.ibAddButton.superview!.convert(self.ibSettingButton.frame, to: nil), expression: "story_tutorial5".localized)
            let page5 = TutorialPageData(forcusFrame: nil, expression: "story_tutorial6".localized, image: UIImage(named: "shadowDragon"))

            self.showTutorial(pages: [page0, page1, page2, page3, page4, page5])
        }.emit().disposed(by: disposeBag)

        ibSettingButton.rx
            .tap
            .map(viewModel.inputs.settingButtonTapped)
            .subscribe()
            .disposed(by: disposeBag)

        ibShowDragonButton.rx
            .tap
            .map(viewModel.inputs.dragonButtonTapped)
            .subscribe()
            .disposed(by: disposeBag)

        ibAddButton.rx
            .tap
            .map(viewModel.inputs.addQuest)
            .subscribe()
            .disposed(by: disposeBag)
    }

    func showFinishWithFade() {
        guard let finished = viewModel.outputs.showFinished else { return }

        self.ibDragonDotView.scene?.removeAllChildren()
        let scene = SKScene(size: CGSize(width: 180, height: 200))
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        self.ibDragonDotView.presentScene(scene)

        self.ibFinishedQuestLabel.text = finished.quest.title
        self.ibFinishingView.isHidden = false
        self.ibFinishingView.alpha = 1
        self.ibDragonDotView.backgroundColor = .clear
        self.ibDragonDotView.allowsTransparency = true

    }

    func showFinishDragonView() {
        guard let finished = viewModel.outputs.showFinished else { return }
        finished.dragon.presentOn(parent: ibDragonDotView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            let act = SKAction.move(to: CGPoint(x: self.ibDragonDotView.frame.width + (Dragon.profileWidth / 2), y: 0), duration: 3.5)

            self.ibDragonDotView
                .scene?
                .childNode(withName: finished.dragon.nameString)?
                .run(act, completion: {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.ibFinishingView.alpha = 0
                    }, completion: { _ in
                        self.ibFinishingView.isHidden = true
                        self.ibFinishingView.viewWithTag(1)?.removeFromSuperview()
                    })

                })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        viewModel.inputs.viewDidAppear(animated: animated)
        view.layoutIfNeeded()
    }

    var tutorial: TutorialPresentation?
    func showTutorial(pages: [TutorialPageData]) {
        self.tutorial = TutorialPresentation(parent: self.view, targets: pages)
        self.tutorial?.show()
    }

    func directionFrom(tuple: (before: VCType?, after: VCType?, reason: SelectReason)) -> (UIPageViewController.NavigationDirection?, Bool) {

        guard let before = self.viewModel.outputs.views.index(where: { $0.isEqual(type: tuple.before ?? .add) }) else {
            return (nil, false)
        }

        guard let after = self.viewModel.outputs.views.index(where: { $0.isEqual(type: tuple.after ?? .add) }) else {
            return (nil, false)
        }

        if before == after {
            return (nil, false)
        }

        return (before < after ? .forward : .reverse, true)
    }

    @objc func finishViewTapOn() {
        viewModel.inputs.finishViewTapOn()
    }

}

extension StoriesViewController: UIPageViewControllerDelegate {

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPageInt
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let selected: VCType
            if let vc = pageViewController.viewControllers?.first as? QuestListViewController {

                selected = VCType.story(vc.viewModel.outputs.story)
                self.currentPageInt = viewModel
                    .outputs
                    .views
                    .indexOf(vcType: selected)

            } else {
                self.currentPageInt = max(viewModel.outputs.views.count - 1, 0)
                selected = .add
            }

            viewModel.inputs.select(vcType: selected, reason: .swipe)
        }

    }

}

extension StoriesViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return change(page: currentPageInt - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return change(page: currentPageInt + 1)
    }

    func change(page: Int) -> UIViewController? {

        guard let type = viewModel.outputs.views.safeFetch(page) else { return nil }

        switch type {
        case .add:
            let viewModel = EditStoryViewModel(selected: nil, isStoriesViewController: true)
            return EditStoryViewController(viewModel: viewModel)
        case .story(let dto):
            let q = QuestListViewController(viewModel: QuestListViewModel(story: dto, storiesRouter: viewModel.router))
            //            q.view.frame = self.storyTitleCollectionView.frame

            return q
        }
    }

}

extension StoriesViewController: Transitioner {
    var presentingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
}
