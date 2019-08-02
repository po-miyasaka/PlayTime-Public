//
//  CommentWriteVIewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/21.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class CommentWriteViewController: UIViewController {
    let viewModel: DetailQuestViewModel
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardSetUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func bind() {
        ibCancelButton.rx.tap.map { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.subscribe().disposed(by: disposeBag)

        ibDoneButton.rx
            .tap
            .map { [weak self] in
                if let text = self?.ibTextView.text, !text.isEmpty {
                    self?.viewModel.inputs.add(comment: text)
                }
                self?.dismiss(animated: true, completion: nil)
            }
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.outputs.editingCommentDriver.filter { $0 != nil }.map { $0! }.map {[weak self] comment in
            self?.ibTextView.text = comment.expression
            self?.ibDateLabel.text = DateUtil.displayDetail.formatter.string(from: comment.id.id)
            self?.ibQuestNameLabel.text = self?.viewModel.selected?.title
        }.drive().disposed(by: disposeBag)
    }

    @objc func keyboardSetUp(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.5, animations: {
                self.ibBottomConstraint.constant = frame.height + 10
                self.view.layoutIfNeeded()
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        ibTextView.becomeFirstResponder()
    }

    init(viewModel: DetailQuestViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var ibDateLabel: UILabel!
    @IBOutlet weak var ibQuestNameLabel: UILabel!
    @IBOutlet weak var ibBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ibTextView: UITextView!
    @IBOutlet weak var ibCancelButton: UIButton! {
        didSet {
            self.ibCancelButton.setTitle("cancel".localized, for: .normal)
        }
    }

    @IBOutlet weak var ibDoneButton: UIButton! {
        didSet {
            self.ibDoneButton.setTitle("done".localized, for: .normal)
        }
    }
}
