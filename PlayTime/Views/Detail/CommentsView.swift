//
//  CommentsView.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import PlayTimeObject
import Utilities

class CommentsView: UIView {
    var disposeBag = DisposeBag()
    weak var viewModel: DetailQuestViewModel?

    var transFormIdentity: CGAffineTransform {
        return CGAffineTransform.identity
    }

    @IBOutlet weak var ibAddButton: UIButton!

    var transformGoal: CGAffineTransform {
        return CGAffineTransform(translationX: CGAffineTransform.identity.tx, y: 20)
    }

    var anchorForPan: CGAffineTransform?

    @IBOutlet private weak var ibCommentsHeadLabel: UILabel! {
        didSet {
            ibCommentsHeadLabel.text = "activity".localized
        }
    }
    @IBOutlet private weak var ibTableView: UITableView!

    @IBOutlet weak var ibCommentSegment: UISegmentedControl! {
        didSet {
            self.ibCommentSegment.setTitle("userComment".localized, forSegmentAt: 0)
            self.ibCommentSegment.setTitle("play".localized, forSegmentAt: 1)
            self.ibCommentSegment.setTitle("all".localized, forSegmentAt: 2)
            self.ibCommentSegment.alpha = 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setUp() {
        if let view = UINib(nibName: CommentsView.className, bundle: .main).instantiate(withOwner: self, options: nil).first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }

    func configure() {
        setUp()
        setUpFluidInterface()
        setUpTableView()
        bind()
    }

    func setUpTableView() {
        self.ibTableView.delegate = self
        self.ibTableView.dataSource = self
        self.ibTableView.register(CommentCell.self)
    }

    func setUpFluidInterface() {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(CommentsView.pan(gesture:)))
        gesture.delegate = self
        self.addGestureRecognizer(gesture)
    }

    func bind() {
        ibAddButton.rx.tap.map {[weak self] in
            self?.viewModel?.inputs.editing(Comment.new(text: "", type: .creating))
        }.subscribe().disposed(by: disposeBag)

        viewModel?.outputs
            .commentsDriver
            .map {[weak self] diff in

                guard let self = self else { return }
                let tuple = diff.classifyIndice()
                self.ibTableView.beginUpdates()
                if tuple.reloaded.isNotEmpty {
                    self.ibTableView.reloadRows(at: tuple.reloaded, with: .fade)
                }
                if tuple.deleted.isNotEmpty {
                    self.ibTableView.deleteRows(at: tuple.deleted, with: .fade)
                }
                if tuple.inserted.isNotEmpty {
                    self.ibTableView.insertRows(at: tuple.inserted, with: .fade)
                }
                self.ibTableView.endUpdates()

            }
            .drive()
            .disposed(by: disposeBag)

        viewModel?.outputs.editingCommentDriver.filter { $0 != nil }.map {[weak self] _ in
            self?.showCommentView()
        }.drive()
            .disposed(by: disposeBag)

        ibCommentSegment.rx.selectedSegmentIndex.do(onNext: {[weak self] at in
            self?.viewModel?.inputs.segmentChanged(at: SegmentType(rawValue: at) ?? SegmentType.user)
        }).subscribe().disposed(by: disposeBag)
    }

}

extension CommentsView: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self) else { return false }
        return abs(velocity.x) < abs(velocity.y)
    }

    @objc func pan(gesture: UIPanGestureRecognizer) { //  tableviewのスワイプの邪魔になる
        let velocity = gesture.velocity(in: self)
        switch gesture.state {
        case .began:
            self.anchorForPan = self.transform
        case .changed:
            if velocity.y > 500 {
                hideCommentView()
            } else if velocity.y < -500 {
                showCommentView()
            }
        case .ended:
            break
        default: break
        }
    }

    func showCommentView(isAdd: Bool = false) {
        let tf = CGAffineTransform(translationX: self.anchorForPan?.tx ?? 0, y: -UIScreen.main.bounds.size.height + 150)

        let duration: TimeInterval = isAdd ? 0.0 : 0.3
        animation(tf: tf, duration: duration, segmentAlpha: 1)

        if isAdd {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[weak self] in
                self?.viewModel?.inputs.editing(Comment.new(text: "", type: .creating))
            }
        }
    }

    func hideCommentView() {
        let tf = CGAffineTransform(translationX: self.anchorForPan?.tx ?? 0, y: 0)
        animation(tf: tf, segmentAlpha: 0)
    }

    func animation(tf: CGAffineTransform, duration: TimeInterval = 0.3, segmentAlpha: CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = tf
            self.ibCommentSegment.alpha = segmentAlpha
        })
    }
}

extension CommentsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let comment = viewModel?.comments.safeFetch(indexPath.row), comment.isEditing else { return }
        viewModel?.inputs.editing(comment)
    }
}

extension CommentsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.outputs.comments.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(t: CommentCell.self, indexPath: indexPath)

        if let data = viewModel?.outputs.comments.safeFetch(indexPath.row) {
            cell.configure(data: data, indexPath: indexPath)
        }
        return cell
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return actSwipe(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return actSwipe(indexPath: indexPath)
    }

    func actSwipe(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let action = UIContextualAction(style: .destructive, title: "delete".localized, handler: {[weak self] _, _, handler  in
            guard let comment = self?.viewModel?.comments.safeFetch(indexPath.row), comment.isEditing else {
                return }

            self?.viewModel?.inputs.delete(comment)
            handler(true)
        })

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel?.comments.safeFetch(indexPath.row)?.isEditing == true
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01 //  0だと 無効
    }
}

extension CommentsView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let y = scrollView.contentOffset.y
        if y < -50 {
            hideCommentView()
        }
    }
}

extension CommentsView: UITextViewDelegate {

    private func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            viewModel?.inputs.add(comment: text)

        }
        textField.text = ""
        ibTableView.tableHeaderView = nil
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
