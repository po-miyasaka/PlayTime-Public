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

class TextCell: UITableViewCell, Nibable, Configurable {

    @IBOutlet weak var title: UILabel!
    var disposeBag = DisposeBag()
    var indexPath: IndexPath?
    var userAction: (() -> Void)?
    typealias CellData = TextCellData
    func configure(data: CellData, indexPath: IndexPath) {
        self.indexPath = indexPath
        title.text = data.title
        accessoryType = data.isShownAccessary ? .disclosureIndicator : .none
        self.userAction = data.userAction
    }
}

struct TextCellData {
    let title: String
    let isShownAccessary: Bool
    let userAction: (() -> Void)
}
