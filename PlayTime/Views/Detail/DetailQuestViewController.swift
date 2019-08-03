//
//  DetailQuestViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/03/02.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation
import NotificationCenter
import SpriteKit
import PlayTimeObject
import Utilities

class DetailQuestViewController: UIViewController, UIGestureRecognizerDelegate {

    var scene: SKScene?
    var viewModel: DetailQuestViewModel?
    var disposeBag = DisposeBag()
    var pickerView: TimerPickerView?
    var commentsView: CommentsView?
    var didCalledViewDidAppear = false
    var didScrollBottom = false
    var isRemovingPicker: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpCommentsView()
        bind()
        setUpBackgroundView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !didCalledViewDidAppear {
            didCalledViewDidAppear.toggle()
            setUpScroll()
        }
    }

    func setUpScroll() {
        ibContentViewAdjustConstraint.constant = 280
        let sa = self.view.height - ibScrollView.contentSize.height
        ibContentViewAdjustConstraint.constant += sa + 100
        self.ibScrollView.delegate = self
        view.layoutIfNeeded()
    }

    func removePicker() {
        if !isRemovingPicker {
            isRemovingPicker.toggle()
            view.remove(target: pickerView) {
                self.isRemovingPicker.toggle()
            }
        }
    }

    func scrollForDismiss(y: CGFloat) {
        let value = y
        if value >= 0 {
            let move = CGAffineTransform(translationX: 0, y: ( value * 0.3))
            let by = (max(1, value) * 0.2) / view.height
            let scale = 1.0 - min(0.05, by)
            let changeScale = CGAffineTransform(scaleX: scale, y: scale)
            view.transform = changeScale.concatenating(move)

            if value > 75 {
                viewModel?.inputs.close()
            }
        }
    }

    func setUpBackgroundView() {
        view.backgroundColor = .clear
        parent?.view.backgroundColor = .clear
        ibScrollView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // boundsに対して設定するんだね
        parent?.view.insertSubview(blurEffectView, at: 0)
    }

    func setUpCommentsView() {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 70, width: view.bounds.width, height: UIScreen.main.bounds.size.height - 75)
        let commentView = CommentsView(frame: frame)
        commentsView = commentView
        commentView.viewModel = viewModel
        commentView.configure()
        self.view.addSubview(commentView)
        self.view.sendSubviewToBack(commentView)
        self.view.exchangeSubview(at: 0, withSubviewAt: self.view.subviews.count - 1)

        if viewModel?.isFinished == true {
            commentView.showCommentView(isAdd: true)
        }
    }

    func bind() {
        viewModel?.inputs.setUp()

        ibStartButton.rx
            .tap
            .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
            .map { [weak self] _ in self?.viewModel?.inputs.start() }
            .subscribe()
            .disposed(by: disposeBag)

        viewModel?.outputs
            .itemsAllDriver
            .map {[weak self] _ in
                self?.ibTableView.reloadData()
            }
            .drive()
            .disposed(by: disposeBag)

        viewModel?.outputs
            .dragonIllustDriver
            .drive(ibDragonImageView.rx.image)
            .disposed(by: disposeBag)

        viewModel?.outputs
            .selectedDriver
            .filter { $0 != nil }.map {[weak self] (quest: Quest!) -> Void in
                guard let self = self else { return () }
                self.ibQuestNameLabel.text = quest.title =? ""
                self.ibQuestNameTextField.placeholder = quest.title =? ""
                self.ibStoryNameButton.setTitle(quest.story.title, for: .normal)
                self.ibSumExprienceLabel.text = quest.playTime().displayText()
                self.ibSumCountLabel.text = "\(quest.meanTimes.count)" + "count".localized
                self.ibCreatedDateLabel.text = DateUtil.display.formatter.string(from: quest.id.id)
                self.ibSumExprienceLabel.text = quest.playTime().displayText()
                self.ibConsectiveDaysLabel.text = String(format: "days".localized, quest.continueCount())
                self.ibMaxConsectiveLabel.text = String(format: "days".localized, quest.maxContinueCount())

                if let sa = quest.latestDate?.daysGap(), sa > 1 {
                    self.ibLatestDateLabel.text = "\(sa)" + "daysAgo".localized
                } else {
                    self.ibLatestDateLabel.isHidden = true
                }

            }.drive()
            .disposed(by: disposeBag)

        viewModel?.outputs
            .dragonDriver
            .map { [weak self] in
                guard let self = self, let dragon = $0 else { return }
                self.ibNeededExprienceLabel.text = "\(dragon.necessaryExperience ?? 0)" + "hour".localized
                dragon.presentOn(parent: self.ibDragonDotView)
                self.ibDragonNameLabel.text = dragon.nameString

            }.drive()
            .disposed(by: disposeBag)

        viewModel?.outputs
            .showAlertSignal
            .map {[weak self] in
                self?.showAlert(title: $0.title, message: $0.message)
            }
            .emit()
            .disposed(by: disposeBag)

        ibStoryNameButton.rx
            .tap
            .map { [weak self] in self?.setStorySelector() }
            .subscribe()
            .disposed(by: disposeBag)

        ibCloseButton.rx
            .tap
            .map {[weak self] in
                self?.viewModel?.inputs.close()
            }
            .subscribe()
            .disposed(by: disposeBag)

    }

    @objc func setStorySelector() {

        let vc = UINavigationController(rootViewController: SelectStoryViewController(viewModel: SelectStoryViewModel(type: .detail)))
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: view.width * 0.7, height: view.height * 0.7)
        vc.popoverPresentationController?.sourceView = self.ibStoryNameButton
        vc.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint.zero, size: self.ibStoryNameButton.bounds.size)
        vc.popoverPresentationController?.permittedArrowDirections = .any
        vc.popoverPresentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc func setDragonSelector() {

        let vc = UINavigationController(rootViewController: SelectDragonViewController(viewModel: SelectDragonViewModel(type: .detail)))
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: view.width * 0.9, height: view.height * 0.9)
        vc.popoverPresentationController?.sourceView = self.ibDragonImageView
        vc.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint.zero, size: self.ibDragonImageView.bounds.size)
        vc.popoverPresentationController?.permittedArrowDirections = .any
        vc.popoverPresentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }

    func setUpTableView() {
        ibTableView.register(TextFieldCell.self)
        ibTableView.register(SubTextCell.self)
        ibTableView.register(SwitchCell.self)
        ibTableView.register(CommentCell.self)
        ibTableView.register(DragonCell.self)
        ibTableView.register(GraphCell.self)

        ibTableView.delegate = self
        ibTableView.dataSource = self

        self.ibTableView.tableHeaderView =
            UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 0.5))
        self.ibTableView.tableHeaderView?.backgroundColor = UIColor.lightGray
    }

    @objc func ibQuestNameTapOn() {
        self.ibQuestNameLabel.isHidden.toggle()
        self.ibQuestNameTextField.isHidden.toggle()
        self.ibQuestNameTextField.becomeFirstResponder()
        setUpScroll()
    }

    @IBOutlet private weak var ibStoryNameButton: UIButton!
    @IBOutlet private weak var ibLatestDateLabel: UILabel!
    @IBOutlet private weak var ibDragonHeaderLabel: UILabel! {
        didSet {
            ibDragonHeaderLabel.text = "raisingDragon".localized
        }
    }

    @IBOutlet private weak var ibEvolveHeadLabel: UILabel! {
        didSet {
            ibEvolveHeadLabel.text = "evolveIn".localized
        }
    }
    @IBOutlet private weak var ibNeededExprienceLabel: UILabel!
    @IBOutlet private weak var ibSumExperienceHeadLabel: UILabel! {
        didSet {
            ibSumExperienceHeadLabel.text = "playTime".localized
        }
    }
    @IBOutlet private weak var ibSumExprienceLabel: UILabel!
    @IBOutlet private weak var ibSumCountHeadLabel: UILabel! {
        didSet {
            ibSumCountHeadLabel.text = "playCount".localized
        }
    }
    @IBOutlet private weak var ibSumCountLabel: UILabel!
    @IBOutlet private weak var ibTableView: UITableView!
    @IBOutlet private weak var ibStartButton: UIButton! {
        didSet {
            ibStartButton.setTitle("startNow".localized, for: .normal)
            ibStartButton.layer.borderColor = UIColor(hexString: "CFBC0A").cgColor
            ibStartButton.layer.borderWidth = 3
        }
    }

    @IBOutlet weak var ibConsectiveDaysHeadLabel: UILabel! {
        didSet {
            ibConsectiveDaysHeadLabel.text = "consectiveDate".localized
        }
    }
    @IBOutlet weak var ibConsectiveDaysLabel: UILabel!

    @IBOutlet weak var ibCreatedDateHeadLabel: UILabel! {
        didSet {
            ibCreatedDateHeadLabel.text = "createdDate".localized
        }
    }
    @IBOutlet weak var ibCreatedDateLabel: UILabel!

    @IBOutlet weak var ibMaxConsectiveHeadLabel: UILabel! {
        didSet {
            ibMaxConsectiveHeadLabel.text = "continuityDate".localized
        }
    }
    @IBOutlet weak var ibMaxConsectiveLabel: UILabel!

    @IBOutlet weak var ibDragonNameLabel: UILabel!
    @IBOutlet weak var ibCloseButton: UIButton! {
        didSet {
            ibCloseButton.setTitle("close".localized, for: .normal)
        }
    }

    @IBOutlet private weak var ibScrollView: UIScrollView!
    @IBOutlet private weak var ibSumPlayTimeStackView: UIStackView!
    @IBOutlet private weak var ibContentViewAdjustConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var ibTextFieldBaseView: UIView!

    @IBOutlet weak var ibDragonDotView: SKView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(setDragonSelector))
            ibDragonDotView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet private weak var ibQuestNameLabel: UILabel! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(ibQuestNameTapOn))
            ibQuestNameLabel.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet private weak var ibDragonImageView: UIImageView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(setDragonSelector))
            ibDragonImageView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet private weak var ibQuestNameTextField: UITextField! {
        didSet {
            ibQuestNameTextField.delegate = self
        }
    }

}

extension DetailQuestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ibQuestNameTextField.resignFirstResponder()
        removePicker()
        scrollForDismiss(y: scrollView.contentOffset.y * -1)
    }
}

extension DetailQuestViewController: UIPopoverPresentationControllerDelegate {
    // デフォルトの代わりにnoneを返すことで、iPhoneでもpopover表示ができるようになる
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    // Popoverの外をタップしたら閉じるべきかどうかを指定できる（吹き出し内のボタンで閉じたい場合に利用）
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

extension DetailQuestViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.inputs.editQuestName(textField.text =? (textField.placeholder ?? ""))
        self.ibQuestNameLabel.isHidden.toggle()
        self.ibQuestNameTextField.isHidden.toggle()

        setUpScroll()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DetailQuestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard let cell = viewModel?
            .outputs
            .items(section: indexPath.section).safeFetch(indexPath.row) else { return }

        switch cell {
        case .timer:
            guard view.viewWithTag(1) == nil else { return }
            let pickerView = TimerPickerView.instant()
            pickerView.tag = 1
            self.pickerView = pickerView
            pickerView.frame = pickerView.frame.change(width: view.frame.width - 40)
            view.animateShow(target: pickerView)
            pickerView.setUp(with: viewModel?.outputs.selected?.limitTime ?? 0)
                .map { [weak self] in
                    self?.viewModel?.inputs.editLimitTime($0)
                    self?.view.remove(target: pickerView)
                    self?.pickerView = nil
                }
                .subscribe()
                .disposed(by: disposeBag)
        default:
            break
        }

    }

}

extension DetailQuestViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?
            .outputs
            .itemsAll
            .count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?
            .outputs
            .items(section: section).count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel?.outputs
            .items(section: indexPath.section)
            .safeFetch(indexPath.row)?
            .dequeue(tableView: tableView, indexPath: indexPath)
            ?? UITableViewCell()
        return cell
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return  viewModel?.outputs
            .items(section: indexPath.section)
            .safeFetch(indexPath.row)?.sholudHighlight == true
    }

}

extension DetailQuestViewController: Transitioner {
    var presentingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [ibDragonImageView].compactMap { $0 } }
}
