//
//  SelectDragonViewController.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/26.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectDragonViewController: UIViewController {

    @IBOutlet weak var ibCollectionView: UICollectionView!
    let viewModel: SelectDragonViewModelProtocol
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "selectDragon".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpCollectionView()
    }

    func setUpCollectionView() {
        self.ibCollectionView.register(SelectDragonItem.self)

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 280, height: 300)
        layout.scrollDirection = .vertical
        ibCollectionView.delegate = self
        ibCollectionView.dataSource = self
    }

    init(viewModel: SelectDragonViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectDragonViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selected = viewModel.outputs.dragons.safeFetch(indexPath.row) else { return }
        viewModel.inputs.selected(dragon: selected.name)
        self.dismiss(animated: true, completion: nil)
    }
}

extension SelectDragonViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.dragons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ibCollectionView.dequeue(type: SelectDragonItem.self, indexPath: indexPath)

        if let data = viewModel.outputs.dragons.safeFetch(indexPath.row) {
            cell.configure(data: data, indexPath: indexPath)
        }
        return cell
    }

}

extension SelectDragonViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 280, height: 300)
    }
}
