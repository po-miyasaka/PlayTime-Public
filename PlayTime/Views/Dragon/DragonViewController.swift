//
//  DragonViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/24.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa

class DragonViewController: UIViewController, Transitioner {

    var presentingAnimationTargetViews: [UIView] { return [ibDragonLibraryView.selectedDragonItem].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [] }

    let disposeBag = DisposeBag()

    @IBOutlet weak var ibBackButton: UIButton!

    @IBOutlet weak var ibFilterView: UIView!

    @IBOutlet weak var ibDragonLibraryView: DragonLibraryView!

    @IBOutlet weak var ibDragonLibraryButton: UIButton!
    lazy var scene: SKScene = {
        var scene = SKScene(size: view.frame.size)
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        return scene
    }()

    lazy var fieldView: SKView = {
        let fieldView = SKView(frame: view.frame)
        fieldView.presentScene(scene)
        fieldView.backgroundColor = .clear
        return fieldView
    }()

    lazy var viewModel: DragonViewModelProtocol = DragonViewModel(router: DragonRouter(transitiner: self))

    override func viewDidDisappear(_ animated: Bool) {
        // 必要ないけどメモリーリーク防止。
        // 一旦バックグラウンドにするとメモリは開放されるっぽい
        scene.removeAllActions()
        scene.removeAllChildren()
        scene.removeFromParent()
        fieldView.removeFromSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLibraryView()
        bind()
        setUpGesture()
    }

    func setUpGesture() {
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(close))
        downSwipeGesture.direction = .down
        self.view.addGestureRecognizer(downSwipeGesture)

        let upSwipeGesture = UISwipeGestureRecognizer(target: self.ibDragonLibraryView, action: #selector(DragonLibraryView.showLibrary))
        upSwipeGesture.direction = .up
        view.addGestureRecognizer(upSwipeGesture)
    }

    func setUpLibraryView() {
        ibDragonLibraryView.filterView = ibFilterView
        ibDragonLibraryView.set(viewModel: DragonLibraryViewModel(router: viewModel.outputs.router))
        ibDragonLibraryView.ibDragonLibraryOriginFrame = self.ibDragonLibraryView.frame.change(width: self.view.width - 40).change(height: self.view.height - 80)
        ibDragonLibraryView.alpha = 0
        ibDragonLibraryView.isUserInteractionEnabled = false
    }

    func bind() {

        ibBackButton.rx
            .tap
            .do(onNext: {[weak self] in
                self?.close()
            })
            .subscribe()
            .disposed(by: disposeBag)

        ibDragonLibraryButton.rx
            .tap
            .do(onNext: {[weak self] in
                guard let self = self else { return }
                if self.ibDragonLibraryView.alpha == 0 {
                    self.ibDragonLibraryView.showLibrary()
                } else {
                    self.ibDragonLibraryView.hideLibrary()
                }
            }).subscribe()
            .disposed(by: disposeBag)

        viewModel.outputs
            .dragons
            .enumerated()
            .forEach {[weak self]  _, dragon in
                guard let self = self else { return }
                let node = dragon.createNode()
                node.position = view.frame.change(height: view.frame.height * 0.75).randomPoint()
                scene.addChild(node)

                self.view.addSubview(fieldView)
                self.view.bringSubviewToFront(ibBackButton)
                self.view.bringSubviewToFront(ibFilterView)
                self.view.bringSubviewToFront(ibDragonLibraryView)
                self.view.bringSubviewToFront(ibDragonLibraryButton)
            }

        PublishRelay<Int>
            .interval(1.0, scheduler: MainScheduler.asyncInstance)
            .bind(onNext: {[weak self] _ in
                guard let self = self else { return }
                self.scene.children.sorted(by: {lhs, rhs in
                    lhs.position.y > rhs.position.y
                }).enumerated().forEach {
                    $0.element.zPosition = $0.offset.toCGFloat
                }

                self.viewModel.outputs.dragons.forEach {
                    $0.move(fieldFrame: self.view.frame.changeHBy { $0.height * 0.75 })
                }
            })
            .disposed(by: disposeBag)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        ibDragonLibraryView.collectionViewLayout.invalidateLayout()
        ibDragonLibraryView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        viewModel.inputs.viewDidAppear()
    }

    @objc func close() {
        viewModel.inputs.close()
    }

}
