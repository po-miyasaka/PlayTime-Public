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

class PlayTimeCell: UITableViewCell, Nibable, Configurable {

    @IBOutlet private weak var title: UILabel!
    var viewModel: SettingsViewModelProtocol?
    var disposeBag = DisposeBag()
    var indexPath: IndexPath?
    typealias CellData = PlayTimeCellData
    func configure(data: CellData, indexPath: IndexPath) {
        self.indexPath = indexPath

        data.time
            .map { $0.displayText() }
            .drive(title.rx.text)
            .disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}

struct PlayTimeCellData {
    let time: Driver<TimeInterval>
}
