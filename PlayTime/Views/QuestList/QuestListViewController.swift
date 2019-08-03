//
//  StoryListViewController.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/20Saturday.
//  Copyright © 2018 pennet. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlayTimeObject
import Utilities

@IBDesignable
final class QuestListViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!

    let disposeBag = DisposeBag()
    let viewModel: QuestListViewModelProtocol
    lazy var dataSource = QuestListViewControllerDataSource(viewModel: viewModel)

    init(viewModel: QuestListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.setUp()
        collectionView.register(AddQuestItem.self)
        collectionView.register(QuestItem.self)

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumLineSpacing = 100
        collectionView.collectionViewLayout = layout

        collectionView.dataSource = dataSource
        collectionView.delegate = self

        viewModel
            .outputs
            .isEditingQuestDriver
            .drive(onNext: {[weak self] in
                self?.setEditing($0, animated: true)})
            .disposed(by: disposeBag)

        viewModel
            .outputs
            .itemsDriver
            .skip(1)
            .drive(onNext: {[weak self] items in

                // 重要なのは performBatchUpdates
                self?.collectionView.performBatchUpdates({
                    let tuple = items.classifyIndice()

                    if tuple.reloaded.isNotEmpty {
                        self?.collectionView.reloadItems(at: tuple.reloaded)
                    }

                    if tuple.deleted.isNotEmpty {
                        self?.collectionView.deleteItems(at: tuple.deleted)
                    }

                    if tuple.inserted.isNotEmpty {
                        self?.collectionView.insertItems(at: tuple.inserted)
                    }
                }, completion: { _ in
                    self?.view.layoutIfNeeded()
                })

            }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        view.layoutIfNeeded()
    }

}

extension QuestListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 10, height: 25)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 10, height: 25)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

}

extension QuestListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) else { return }
        let itemFrame = item.superview!.convert(item.frame, to: nil)
        viewModel.inputs.itemTapped(indexPath: indexPath, itemFrame: itemFrame)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)

        switch editing {
        case true:
            collectionView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.4, animations: {
            }, completion: { bool in
                self.collectionView.isUserInteractionEnabled = bool
                self.view.layoutSubviews()
            })
        case false:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
