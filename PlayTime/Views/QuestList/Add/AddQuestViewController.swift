//
//  AddQuestViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/01.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SpriteKit

class AddQuestViewController: UIViewController, Transitioner {

    var scene: SKScene?
    let viewModel: AddQuestViewModelProtocol
    let disposeBag = DisposeBag()
    init(viewModel: AddQuestViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setUpGesture()
    }

    func bind() {
        viewModel.inputs.setUp()
        makeButton.rx
            .tap
            .map {[weak self] _ in
                self?.ibQuestNameField.endEditing(true)
                self?.viewModel.inputs.make()
            }
            .subscribe()
            .disposed(by: disposeBag)

        ibBackButton.rx
            .tap
            .map {[weak self] _ in
                // router
                self?.dismiss(animated: true, completion: nil)
            }.subscribe().disposed(by: disposeBag)

        viewModel.outputs
            .dragonDriver
            .map {[weak self] dragon -> Void in
                guard let self = self else { return }

                self.ibDragonImageView.image = dragon.images.illust

                self.ibExperienceLabel.text = "\(dragon.necessaryExperience ?? 0)" + "hour".localized
                dragon.presentOn(parent: self.ibDragonDotView)

            }
            .drive()
            .disposed(by: disposeBag)

        viewModel.outputs
            .questNameDriver
            .map {[weak self] name in
                self?.ibQuestNameLabel.isHidden = false
                self?.ibQuestNameField.isHidden = true
                self?.ibQuestNameLabel.text = name
                self?.ibQuestNameField.text = name

                if name.isEmpty {
                    self?.ibQuestNameLabel.text = "newQuest".localized
                    self?.ibQuestNameLabel.textColor = .lightGray
                } else {
                    self?.ibQuestNameLabel.textColor = .black
                }
            }
            .drive()
            .disposed(by: disposeBag)

        viewModel.outputs
            .storyDriver
            .map {[weak self] story in

                self?.ibStoryButton.setTitle(story.title, for: .normal)
            }
            .drive()
            .disposed(by: disposeBag)

        viewModel.outputs
            .showAlertSignal
            .map {[weak self] in
                self?.showAlert(title: $0.title, message: $0.message)
            }
            .emit()
            .disposed(by: disposeBag)
    }

    func setUpGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)

    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func showDragonSelector() {
        let vc = UINavigationController(rootViewController: SelectDragonViewController(viewModel: SelectDragonViewModel(type: .add)))
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: view.width * 0.9, height: view.height * 0.9)
        vc.popoverPresentationController?.sourceView = self.ibDragonDotView
        vc.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint.zero, size: self.ibDragonDotView.bounds.size)
        vc.popoverPresentationController?.permittedArrowDirections = .any
        vc.popoverPresentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc func showStorySelector() {
        let vc = UINavigationController(rootViewController:
            SelectStoryViewController(viewModel: SelectStoryViewModel(type: .add)))
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: view.width * 0.9, height: view.height * 0.9)
        vc.popoverPresentationController?.sourceView = self.ibStoryButton
        vc.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint.zero, size: self.ibStoryButton.bounds.size)
        vc.popoverPresentationController?.permittedArrowDirections = .any
        vc.popoverPresentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }

    @objc func questNameTapOn() {
        self.ibQuestNameField.isHidden = false
        self.ibQuestNameLabel.isHidden = true
        self.ibQuestNameField.becomeFirstResponder()
    }

    var presentingAnimationTargetViews: [UIView] { return [] }
    var dismissingAnimationTargetViews: [UIView] { return [] }

    @IBOutlet weak var ibStoryView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(showStorySelector))
            ibStoryView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet weak var ibStoryHeadLabel: UILabel! {
        didSet {
            ibStoryHeadLabel.text = "story".localized
        }
    }

    @IBOutlet weak var ibQuestNameHeadLabel: UILabel! {
        didSet {
            ibQuestNameHeadLabel.text = "questName".localized
        }
    }

    @IBOutlet weak var ibDraognNameHeadLabel: UILabel! {
        didSet {
            ibDraognNameHeadLabel.text = "raisingDragon".localized
        }
    }

    @IBOutlet weak var ibChangeEnableLabel: UILabel! {
        didSet {
            ibChangeEnableLabel.text = "fixAfterCreated".localized
        }
    }

    @IBOutlet weak var ibStoryButton: UIButton!

    @IBOutlet weak var ibTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var ibQuestNameLabel: UILabel!

    @IBOutlet weak var ibDragonImageView: UIImageView!

    @IBOutlet weak var ibDragonDotView: SKView!

    @IBOutlet weak var ibExperienceLabel: UILabel!

    @IBOutlet weak var ibExperienceHeadLabel: UILabel! {
        didSet {
            ibExperienceHeadLabel.text = "evolveIn".localized
        }
    }

    @IBOutlet weak var ibDragonView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(showDragonSelector))
            ibDragonView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet private weak var ibQuestNameField: UITextField! {
        didSet {
            ibQuestNameField.delegate = self
        }
    }

    @IBOutlet weak var ibQuestNameView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(questNameTapOn))
            ibQuestNameView.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet private weak var makeButton: UIButton! {
        didSet {
            makeButton.setTitle("create".localized, for: .normal)
        }
    }

    @IBOutlet private weak var ibBackButton: UIButton! {
        didSet {
            ibBackButton.setTitle("cancel".localized, for: .normal)
        }
    }

}

extension AddQuestViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

extension AddQuestViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.viewModel.inputs.quest(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
