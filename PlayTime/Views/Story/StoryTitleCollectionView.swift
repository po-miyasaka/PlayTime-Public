//
//  StoryTitleCollectionView.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/27.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import PlayTimeObject
import Utilities

class StoryTitleCollectionView: UICollectionView {

    var disposeBag = DisposeBag()
    weak var selected: StoryTitleItem?
    var indicator: UIView?
    var viewModel: StoriesViewModelProtocol?
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setUp()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setUp()
    }

    func setUp() {
        setUpCollectionView()
        setUpLayer()
        setUpIndicator()
    }

    func bind(viewModel: StoriesViewModelProtocol) {
        self.viewModel = viewModel
        viewModel.outputs.viewsObservable.drive(onNext: {[weak self] _ in
            self?.reloadSections(IndexSet([0]))
        }).disposed(by: disposeBag)

        viewModel.outputs.selectedStoryDriver.drive(onNext: {[weak self] tuple in
            guard let self = self else { return }
            self.adjustMenu(index: viewModel.outputs.views.indexOf(vcType: tuple.after))
        }).disposed(by: disposeBag)
    }

    var cellWidth: CGFloat {
        return self.frame.width / 3.2
    }

    func setUpCollectionView() {
        self.register(StoryTitleItem.self, forCellWithReuseIdentifier: StoryTitleItem.className)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: cellWidth, height: 45)
        self.collectionViewLayout = layout
        self.dataSource = self
        self.delegate = self
    }

    func setUpIndicator() {
        let indicator = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 45), size: CGSize(width: cellWidth, height: 5)))
        indicator.backgroundColor = Colors.mainGold.uiColor
        self.indicator = indicator
        self.addSubview(indicator)
    }

    func setUpLayer() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
    }

}
extension StoryTitleCollectionView:
UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryTitleItem.className, for: indexPath) as? StoryTitleItem,
            let type = viewModel?.outputs.views.safeFetch(indexPath.row) else { return UICollectionViewCell() }

        cell.titleLabel.text = type.title

        if type.story?.id == viewModel?.outputs.selectedStory.after?.story?.id {
            cell.titleLabel.textColor = Colors.mainGold.uiColor
        } else {
            cell.titleLabel.textColor = .gray
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.outputs.views.count ?? 0
    }

}

extension StoryTitleCollectionView:
UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vcType = viewModel?.outputs.views.safeFetch(indexPath.row) {
            viewModel?.inputs.select(vcType: vcType, reason: .select)
        }
    }

    func adjustMenu(index: Int?, isAnimation: Bool = true) {
        guard let index = index else { return }

        let handle: (() -> Void) = {[weak self] in
            guard let self = self else { return }
            if let cell = self.cellForItem(at: IndexPath(row: index, section: 0)) as? StoryTitleItem {
                self.selected?.titleLabel.textColor = .gray
                cell.titleLabel.textColor = Colors.mainGold.uiColor
                self.selected = cell

                let gapBetweenViewAndCell = ((self.width / 2) - (cell.width / 2))

                var cellOffsetX = cell.frame.origin.x - gapBetweenViewAndCell
                var indicatorPositionX: CGFloat

                let gapBetweenViewAndContentView = self.contentSize.width - self.width
                self.setContentOffset(CGPoint(x: cellOffsetX, y: 0), animated: isAnimation)
                if cellOffsetX < 0 {
                    cellOffsetX = 0
                    indicatorPositionX = cell.frame.origin.x + 10
                } else if 0 > gapBetweenViewAndContentView {
                    cellOffsetX = gapBetweenViewAndContentView
                    indicatorPositionX = cell.frame.origin.x
                } else {
                    indicatorPositionX = cellOffsetX + gapBetweenViewAndCell + 10
                }

                guard let indicatorFrame = self.indicator?.frame.changeXBy(transform: { _ in indicatorPositionX }).changeWBy(transform: { _ in cell.width - 20 }) else {
                    return
                }

                UIView.animate(withDuration: isAnimation ? 0.2 : 0, animations: {
                    self.indicator?.frame = indicatorFrame
                    self.layoutIfNeeded()
                }, completion: {_ in
                    self.layoutSubviews()
                })
            }
        }

        if let _ = self.cellForItem(at: IndexPath(row: index, section: 0)) as? StoryTitleItem {
            handle()
        } else {
            self.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: handle)
        }
    }

}
