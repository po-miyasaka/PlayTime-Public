//
//  PennetExcuteButtonView.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/23Tuesday.
//  Copyright © 2018 pennet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DeletingButtonView: UIView {
    var disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    func setUp() {
        if subviews.isEmpty {
            if let view = UINib(nibName: DeletingButtonView.className, bundle: .main).instantiate(withOwner: self, options: nil).first as? UIView {
                self.frame = view.bounds
                self.addSubview(view)
            }
        }
    }

    func bind(viewModel: StoriesViewModel) {

        viewModel
            .isEditingQuestDriver
            .map { !$0 }
            .drive(rx.isHidden)
            .disposed(by: disposeBag)

        leftButton
            .rx
            .tap
            .map {_ in
                viewModel.inputs.deleteCancel()
            }
            .subscribe()
            .disposed(by: disposeBag)

        rightButton
            .rx
            .tap
            .map {_ in
                viewModel.inputs.excuteDeleting()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBOutlet private weak var leftButton: UIButton! {
        didSet {
            leftButton.setTitle("cancel".localized, for: .normal)
        }
    }

    @IBOutlet private weak var rightButton: UIButton! {
        didSet {
            rightButton.setTitle("delete".localized, for: .normal)
        }
    }

}
