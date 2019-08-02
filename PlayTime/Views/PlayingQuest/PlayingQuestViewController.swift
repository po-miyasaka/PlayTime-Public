//
//  PlayingQuestViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/03.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//
import SpriteKit
import Foundation
import RxSwift
import RxCocoa

class PlayingQuestViewController: UIViewController {
    let viewModel: PlayingQuestViewModelProtocol
    let disposeBag = DisposeBag()
    var groundSize: CGSize = .zero

    lazy var skView: SKView = {
        let fieldView = SKView(frame: questingView.frame)
        fieldView.presentScene(baseScene)
        baseScene.position = CGPoint(x: 0, y: 0)
        fieldView.backgroundColor = .clear
        return fieldView
    }()

    lazy var baseScene: SKScene = {
        var scene = SKScene(size: questingView.frame.size) // viewのフレームサイズと同じにしたいがview.frame.sizeではない
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        return scene
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    func setUpView() {
        self.questingView.addSubview(skView)

        if viewModel.outputs.fromType == .detail ||
            viewModel.outputs.fromType == .list {
            setUpDetail()
        } else if viewModel.outputs.fromType == .launch {
            setUpLaunch()
        }

        let ground = setupGround()
        let fields = PlayingFields.allCases
            .map { layer -> [NodeAndAction] in
                if layer == .ground {
                    return ground
                } else {
                    return setComponent(layer: layer)
                }
            }
            .flatMap { $0 }

        fields.forEach {
            $0.addChild(on: baseScene)
            $0.run()
        }

    }

    func bind() {

        viewModel.outputs
            .dragonDriver
            .map {[weak self] dragon in
                guard let self = self, let dragon = dragon else { return }
                dragon.presentOn(parent: self.ibDragonDotView)
            }
            .drive()
            .disposed(by: disposeBag)

        ibCancelButton.rx
            .tap
            .map { [weak self] in self?.viewModel.inputs.cancel() }
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.outputs
            .activeQuestDriver
            .map { [weak self] quest in
                guard let self = self else { return }
                self.ibQuestNameLabel.text = quest?.title

            }
            .drive()
            .disposed(by: disposeBag)

        Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
            .map { [weak self] _ in
                guard let self = self,
                    let quest = self
                        .viewModel
                        .outputs
                        .activeQuest else { return }
                self.ibPlaytimeLabel.text = quest.playTime(true).displayText()

                let leftTime = quest.limitTime - quest.activeMeanTime

                if leftTime < 0 {
                    self.viewModel.inputs.finish(with: quest.limitTime)
                } else {
                    self.ibTimerLabel.text = (leftTime).displayMunitesAndSecondText()
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        ibBackButton.rx
            .tap
            .map {
                [weak self] in
                self?.viewModel.inputs.finish(with: nil)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func setUpCount() {
        self.ibCancelButton.isHidden = true
        self.ibStartingView.isHidden = true
        self.ibCountDownLabel.alpha = 0
        self.ibActiveQuestView.alpha = 1
        self.ibBackButton.isHidden = true
        self.ibTimerHeadLabel.isHidden = true
        self.ibTimerLabel.isHidden = true
        self.ibPlaytimeHeadLabel.isHidden = true
        self.ibPlaytimeLabel.isHidden = true
    }

    func setUpDetail() {
        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
            .map { 3 - ($0 / 13) }
            .map {[weak self] value in
                self?.ibCountDownLabel.text = String(max(value, 1))
                return value
            }
            .filter { $0 <= 0 }
            .map { _ in () }
            .single()
            .map { [weak self] in self?.viewModel.inputs.countDownDone() }
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.outputs
            .countDownDoneSignal
            .map { [weak self] in self?.removeStartQuestingView() }
            .emit()
            .disposed(by: disposeBag)
    }

    func setQuestingView() {
        self.ibCancelButton.alpha = 0
        self.ibStartingView.transform = CGAffineTransform(translationX: -self.view.width, y: 0)
        self.ibCountDownLabel.alpha = 0
        self.ibActiveQuestView.alpha = 1
    }

    func setUpLaunch() {
        setQuestingView()
    }

    init(viewModel: PlayingQuestViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupGround() -> [NodeAndAction] {
        // 地面の場合だけ必要な処理、他のコンポーネントは地面のサイズに依存する。
        let groundNode = PlayingFields.ground.node
        let groundWidth = groundNode.frame.width
        let groundCount = Int((skView.frame.width / groundWidth) + 1)

        let groundSet1 = SKNode()
        (0...groundCount).forEach { num in
            let node = PlayingFields.ground.node
            node.position = CGPoint(x: num.toCGFloat * node.size.width, y: 0)
            groundSet1.addChild(node)
        }

        let groundSetSize = CGSize(width: groundSet1.calculateAccumulatedFrame().width, height: groundNode.calculateAccumulatedFrame().height)
        groundSet1.position = CGPoint(x: 0.0, y: 0.0)
        groundSet1.zPosition = PlayingFields.ground.zPosition

        let groundSet2 = (groundSet1.copy() as? SKNode)!
        groundSet2.position = CGPoint(x: groundSetSize.width - 1, y: 0.0)
        groundSet2.zPosition = PlayingFields.ground.zPosition
        let tmp = roopActionTmplate(groundSetSize: groundSetSize, layer: .ground)

        let ground1Result = NodeAndAction(node: groundSet1, action: SKAction.sequence([tmp.ztl, tmp.ztr, tmp.rtz ]))
        let ground2Result = NodeAndAction(node: groundSet2, action: SKAction.sequence([tmp.rtz, tmp.ztl, tmp.ztr]))
        groundSize = groundSetSize
        return ([ground1Result, ground2Result])
    }

    func setComponent(layer: PlayingFields) -> [NodeAndAction] {
        let node1 = layer.node
        node1.position = CGPoint(x: groundSize.width * layer.startX, y: groundSize.height * layer.yFromGround)
        node1.zPosition = layer.zPosition
        node1.xScale = layer.scale
        node1.yScale = layer.scale

        let tmp = roopActionTmplate(groundSetSize: groundSize, layer: layer)
        let result1 = NodeAndAction(node: node1, action: SKAction.sequence([tmp.ztl, tmp.ztr, tmp.rtz ]))

        return ([result1])
    }

    func roopActionTmplate(groundSetSize: CGSize, layer: PlayingFields) -> (rtz: SKAction, ztl: SKAction, ztr: SKAction) {

        let offset = groundSetSize.width * layer.startX
        let rightToZero = SKAction.moveTo(x: offset, duration: layer.duration)
        let zeroToLeft = SKAction.moveTo(x: -groundSetSize.width + offset, duration: layer.duration)
        let leftToRight = SKAction.moveTo(x: groundSetSize.width + offset, duration: 0)
        return (rightToZero, zeroToLeft, leftToRight)
    }

    func removeStartQuestingView() {

        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseIn,
                       animations: {

                        self.setQuestingView()
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.ibActiveQuestView.alpha = 1
                self.ibSaveAttentionWithStartingLabel.textColor = .white
            })
        })
    }

    @IBOutlet weak var questingView: UIView!
    @IBOutlet private weak var ibBackButton: UIButton! {
        didSet {
            ibBackButton.setTitle("returnBase".localized, for: .normal)
        }
    }

    @IBOutlet private weak var ibCountDownLabel: UILabel!
    @IBOutlet weak var ibCancelButton: UIButton! {
        didSet {
            ibCancelButton.setTitle("cancel".localized, for: .normal)
        }
    }
    @IBOutlet weak var ibStartingView: UIView!
    @IBOutlet weak var ibDragonDotView: SKView!
    @IBOutlet weak var ibActiveQuestView: UIView! {
        didSet {
            ibActiveQuestView.alpha = 0
        }
    }

    @IBOutlet weak var ibSaveAttentionWithStartingLabel: UILabel! {
        didSet {
            ibSaveAttentionWithStartingLabel.text = "willSave".localized
        }
    }

    @IBOutlet weak var ibQuestNameLabel: UILabel!

    @IBOutlet weak var ibPlaytimeHeadLabel: UILabel! {
        didSet {
            ibPlaytimeHeadLabel.text = "playTime".localized
        }
    }

    @IBOutlet weak var ibPlaytimeLabel: UILabel!

    @IBOutlet weak var ibTimerHeadLabel: UILabel! {
        didSet {
            ibTimerHeadLabel.text = "timer".localized
        }
    }

    @IBOutlet weak var ibTimerLabel: UILabel!

}

enum PlayingFields: String, CaseIterable {
    case kokumo
    case kokumo3
    case kumo3
    case kumo2
    case kumo1
    case ki3
    case ki1
    case dhiguda
    case kusa1
    case ground

    var node: SKSpriteNode {
        let tutiNode = SKSpriteNode(imageNamed: self.fileName)
        tutiNode.anchorPoint = CGPoint(x: 0.0, y: 0.0)

        if self == .ground {
            tutiNode.size = CGSize(width: tutiNode.size.width, height: 80)
        }
        return tutiNode
    }

    var fileName: String {
        return self.rawValue
    }

    var yFromGround: CGFloat {
        switch self {
        case .kokumo:
            return 5
        case .kokumo3:
            return 4
        case .kumo3:
            return 0.5
        case .kumo2:
            return 0.6
        case .kumo1:
            return 0.7
        case .ki3:
            return 0.8
        case .ki1:
            return 0.8
        case .dhiguda:
            return 0.9
        case .kusa1:
            return 0.9
        case .ground:
            return 1
        }
    }

    var scale: CGFloat {
        switch self {
        case .kokumo:
            return 1
        case .kokumo3:
            return 1
        case .kumo3:
            return 1
        case .kumo2:
            return 1.2
        case .kumo1:
            return 1.4
        case .ki3:
            return 0.5
        case .ki1:
            return 0.5
        case .dhiguda:
            return 0.4
        case .kusa1:
            return 0.3
        case .ground:
            return 1
        }
    }

    var duration: TimeInterval {
        if self == .ground {
            return 30.0
        }

        return PlayingFields.ground.duration * speedAgainstGround
    }

    var startX: CGFloat {
        switch self {
        case .kokumo:
            return 0.6
        case .kokumo3:
            return 0.3
        case .kumo3:
            return 0.2
        case .kumo2:
            return 0.6
        case .kumo1:
            return -0.5
        case .ki3:
            return 0.7
        case .ki1:
            return 0.2
        case .dhiguda:
            return 0.5
        case .kusa1:
            return 0.5
        case .ground:
            return 0
        }
    }

    var zPosition: CGFloat {
        switch self {
        case .kokumo:
            return 2
        case .kokumo3:
            return 2
        case .kumo3:
            return 3
        case .kumo2:
            return 4
        case .kumo1:
            return 5
        case .ki3:
            return 6
        case .ki1:
            return 7
        case .dhiguda:
            return 8
        case .kusa1:
            return 9
        case .ground:
            return 10
        }
    }

    var speedAgainstGround: TimeInterval {
        switch self {
        case .kokumo:
            return 10
        case .kokumo3:
            return 10
        case .kumo3:
            return 7
        case .kumo2:
            return 6
        case .kumo1:
            return 5
        case .ki3:
            return 2
        case .ki1:
            return 1
        case .dhiguda:
            return 1
        case .kusa1:
            return 1
        case .ground:
            return 1
        }
    }
}

struct NodeAndAction {
    let node: SKNode
    let action: SKAction

    func run() {
        node.run(.repeatForever(action))
    }

    func addChild(on parent: SKNode) {
        parent.addChild(node)
    }
}

extension NodeAndAction {
    init(node: SKNode, action: SKAction, isRepeat: Bool = true) {
        self.node = node
        self.action = action
    }
}

extension PlayingQuestViewController: Transitioner {
    var presentingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
}
