//
//  EditStoryViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/10.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
class EditStoriesViewController: UIViewController {

    @IBOutlet private weak var ibTableView: UITableView!
    let viewModel: EditStoriesViewModelProtocol
    let disposeBag = DisposeBag()

    @IBOutlet private weak var ibBackButton: UIButton!
    @IBOutlet private weak var ibAddStoryButton: UIButton!
    @IBOutlet weak var ibSwipeDeleteLabel: UILabel! {
        didSet {
            ibSwipeDeleteLabel.text = "swipeDelete".localized
        }
    }

    override func viewDidLoad() {
        setUpView()
        bind()
    }

    func setUpView() {
        ibTableView.register(TextFieldCell.self)
        ibTableView.delegate = self
        ibTableView.dataSource = self

        navigationItem.hidesBackButton = true
    }

    func bind() {
        viewModel.inputs.setUp()
        viewModel.outputs.cellDatasObservable.map {[weak self] diff in
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

        }.subscribe().disposed(by: disposeBag)
        ibBackButton.rx.tap.map(viewModel.inputs.back).subscribe().disposed(by: disposeBag)
        ibAddStoryButton.rx.tap.map(viewModel.inputs.add).subscribe().disposed(by: disposeBag)
    }

    init(viewModel: EditStoriesViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditStoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.cellDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(t: TextFieldCell.self, indexPath: indexPath)
        if let data = viewModel.outputs.cellDatas.safeFetch(indexPath.row) {
            cell.configure(data: data, indexPath: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return view.height / 2
    }

}

extension EditStoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell {
            cell.ibQuestNameTextField.becomeFirstResponder()
        }

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
            guard let cellData = self?.viewModel.outputs.cellDatas.safeFetch(indexPath.row) else {
                return }

            self?.viewModel.inputs.delete(cellData)
            handler(true)
        })

        return UISwipeActionsConfiguration(actions: [action])
    }

}

extension EditStoriesViewController: Transitioner {
    var presentingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
}
