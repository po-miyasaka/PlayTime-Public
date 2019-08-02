//
//  SettingCell.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/02/21Wednesday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift
import RxCocoa

class SortCell: UITableViewCell, Nibable, Configurable {
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var sub: UILabel!

    var viewModel: SettingsViewModelProtocol?
    var disposeBag = DisposeBag()
    var indexPath: IndexPath?
    var userAction: (() -> Void)?
    typealias CellData = SortCellData

    func configure(data: CellData, indexPath: IndexPath) {
        self.indexPath = indexPath
        title.text = data.title
        self.userAction = data.userAction
        data.sort
            .map { $0.displayText }
            .drive(self.sub.rx.text)
            .disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

}

struct SortCellData {
    let title: String
    let sort: Driver<SortType>
    let userAction: (() -> Void)
}
