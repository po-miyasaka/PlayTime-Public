//
//  StoryCollectionDataSource.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/14Sunday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation
import UIKit
//import FirebaseAnalytics

class QuestListViewControllerDataSource: NSObject, UICollectionViewDataSource {

    var viewModel: QuestListViewModelProtocol
    init(viewModel: QuestListViewModelProtocol) {
        self.viewModel = viewModel
        super.init()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputs.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let type = viewModel.outputs
            .items
            .safeFetch(indexPath.row) else {
                return UICollectionViewCell()
        }

        switch type {
        case .quest(let itemData):
            let item = collectionView.dequeue(type: QuestItem.self,
                                              indexPath: indexPath)
            item.configure(itemData: itemData, indexPath: indexPath)
            item.viewModel = viewModel
            return item
        case .add:
            let item = collectionView.dequeue(type: AddQuestItem.self,
                                              indexPath: indexPath)
            return item
        }
    }

}
