//
//  DragonDetailViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/07.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa

class DetailDragonViewController: UIViewController {

    var scene: SKScene?
    let viewModel: DetailDragonViewModelProtocol
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    func setUpView() {
        self.ibDragonNameLabel.text = viewModel.outputs.dragon.nameString
        self.ibDragonIllustImage.image = viewModel.outputs.dragon.images.illust
        viewModel.outputs.dragon.presentOn(parent: ibDragonDotView)
        ibDragonExpressionLabel.text = viewModel.outputs.dragon.expression
    }

    func bind() {
        ibBackButton.rx
            .tap
            .map {[weak self] in
                self?.close()
            }.subscribe()
            .disposed(by: disposeBag)

        ibDesignerLinkButton.rx.tap.map {
            if let url = URL(string: "https://twitter.com/zui_0"),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }.subscribe().disposed(by: disposeBag)
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    init(viewModel: DetailDragonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var ibDragonNameLabel: UILabel! {
        didSet {
            self.ibDragonNameLabel.frame = ibDragonNameLabel.frame.change(height: ibDragonNameLabel.frame.height + 10)
        }
    }

    @IBOutlet weak var ibDragonIllustImage: UIImageView!
    @IBOutlet weak var ibDragonDotView: SKView!
    @IBOutlet weak var ibDragonExpressionLabel: UILabel!
    @IBOutlet weak var ibBackButton: UIButton!
    @IBOutlet weak var ibScrollView: UIScrollView!
    @IBOutlet weak var ibDesignerLinkButton: UIButton!
}
