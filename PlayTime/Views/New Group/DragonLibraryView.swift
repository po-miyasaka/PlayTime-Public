//
//  DragonLibraryView.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/05.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import UIKit

class DragonLibraryView: UICollectionView {
    weak var filterView: UIView?
    var viewModel: DragonLibraryViewModelProtocol?
    let disposeBag = DisposeBag()
    var ibDragonLibraryOriginFrame: CGRect = .zero
    var selectedDragonItem: UIImageView?

    func set(viewModel: DragonLibraryViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.outputs.viewsDriver.map {[weak self] _ in
            self?.reloadData()
        }.drive().disposed(by: disposeBag)
        delegate = self
        dataSource = self
    }

    func loadNib() {
        register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.className)

        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        layout.minimumLineSpacing = 100

        collectionViewLayout = layout
        delegate = self
        dataSource = self

    }

    @objc func showLibrary() {
        self.contentInset.top = 10
        self.contentOffset.y = 0
        frame =
            ibDragonLibraryOriginFrame.change(y: ibDragonLibraryOriginFrame.origin.y + 100)
        isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.frame = self.ibDragonLibraryOriginFrame
            self.filterView?.alpha = 1
        }
    }
    var isHiddeing = false
    func hideLibrary() {
        isHiddeing = true
        frame =
        ibDragonLibraryOriginFrame
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.frame =
                self.ibDragonLibraryOriginFrame.change(y: self.ibDragonLibraryOriginFrame.origin.y + 100)
            self.filterView?.alpha = 0
            self.isHiddeing = false
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= -10, (scrollView.isTracking), !isHiddeing {// simuratorだとisTrackingが常にtrue。。
            hideLibrary()
        } else if scrollView.contentOffset.y <= 10, scrollView.isDecelerating {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
}

extension DragonLibraryView: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.outputs.views.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.views.safeFetch(section)?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return  CGSize(width: self.width, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return  CGSize(width: self.width, height: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // cellのuserInteractionがtrueだとここよばれない。
        guard let item = viewModel?.outputs
            .views
            .safeFetch(indexPath.section)?
            .items.safeFetch(indexPath.row) else { return }

        switch item {
        case .hatena:
            return
        case .item(let dragon, _):
            selectedDragonItem =
                (collectionView.cellForItem(at: indexPath) as? ImageViewCell)?.ibImageView
            viewModel?.inputs.selected(dragon: dragon)
        }

    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DragonLibraryView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        collectionView.collectionViewLayout.invalidateLayout()
        guard let data = viewModel?.outputs.views.safeFetch(indexPath.section)?.items.safeFetch(indexPath.row) else {
            return UICollectionViewCell()
        }

        switch data {
        case .item(let dragon, let cellData):
            switch dragon.process {
            case .egg:
                let cell = dequeue(type: ImageViewCell.self, indexPath: indexPath)
                cell.configure(data: cellData, indexPath: indexPath)
                cell.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.9 )
                return cell
            default:
                return UICollectionViewCell()
            }

        case .hatena(let dragon, let cellData):

            switch dragon.process {
            case .egg:
                let cell = dequeue(type: ImageViewCell.self, indexPath: indexPath)
                cell.configure(data: cellData, indexPath: indexPath)
                cell.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.5 )
                return cell

            default:
                return UICollectionViewCell()
            }
        }

    }

}

extension DragonLibraryView: UICollectionViewDelegateFlowLayout {
    var viewMargin: CGFloat { return 2 }
    var cellMargin: CGFloat { return 2 }
    var cellPadding: CGFloat { return 2 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellPadding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizing(indexPath: indexPath)
    }

    func sizing(indexPath: IndexPath) -> CGSize {
        // zeroをかえすとcellforitemよばれない😇
        guard let dragon = viewModel?.outputs.views.safeFetch(indexPath.section)?.items.safeFetch(indexPath.row)?.dragon else {
            return CGSize(width: (self.width / 2), height: (self.width / 2))
        }

        switch dragon.process {

        case .egg:
            return  CGSize(width: (self.width / 4) - cellMargin, height: (self.width / 4) - cellMargin )
        default:
            return .zero
        }
    }
}
