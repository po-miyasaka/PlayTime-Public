//
//  EditStoryViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/10.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EditStoryViewController: UIViewController {

    let viewModel: EditStoryViewModelProtocol
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    func bind() {
        ibRenameTextField.rx
            .text
            .debounce(RxTimeInterval.milliseconds(3), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .map { $0 ?? "" }
            .map(viewModel.inputs.input)
            .subscribe()
            .disposed(by: disposeBag)

        ibDoneButton.rx
            .tap
            .map(viewModel.inputs.done)
            .subscribe()
            .disposed(by: disposeBag)

        ibDeleteButton.rx
            .tap
            .map(viewModel.inputs.delete)
            .subscribe()
            .disposed(by: disposeBag)

        ibBackButton.rx
            .tap
            .map(viewModel.inputs.back)
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBOutlet private weak var ibBackButton: UIButton! {
        didSet {
            self.ibBackButton.isHidden = viewModel.outputs.isStoriesViewController
        }
    }

    @IBOutlet private weak var ibDeleteButton: UIButton! {
        didSet {
            self.ibDeleteButton.isHidden = viewModel.outputs.selected == nil
        }
    }

    @IBOutlet private weak var ibDoneButton: UIButton!
    @IBOutlet private weak var ibRenameTextField: UITextField! {
        didSet {
            ibRenameTextField.text = viewModel
                .outputs.selected?.title
        }}

    init(viewModel: EditStoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "storyEdit".localized
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EditStoryViewController: Transitioner {
    var presentingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
}
