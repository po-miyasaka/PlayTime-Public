//
//  SelectStoryViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/26.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SelectStoryViewController: UIViewController {

    @IBOutlet weak var ibTableView: UITableView!
    let viewModel: SelectStoryViewModelProtocol
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        self.title = "storySelected".localized
    }

    func bind() {
        viewModel.inputs.setUp()
        ibTableView.delegate = self
        ibTableView.register(TextCell.self)
        viewModel.outputs
            .storiesObservable
            .bind(to: ibTableView.rx.items(cellIdentifier: TextCell.className, cellType: TextCell.self)) {_, data, cell in
                cell.title.text = data.title
                cell.accessoryType = .none
            }.disposed(by: disposeBag)
    }

    init(viewModel: SelectStoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectStoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selected = viewModel.outputs.stories.safeFetch(indexPath.row) {
            viewModel.inputs.selected(story: selected)
            dismiss(animated: true, completion: nil)
        }
    }
}
