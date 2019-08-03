//
//  SwitchCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/19.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PlayTimeObject
import Utilities

class SwitchCell: UITableViewCell, Nibable, Configurable {

    @IBOutlet private weak var ibSubjectLabel: UILabel!
    @IBOutlet private weak var ibSwitch: UISwitch!
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    var indexPath: IndexPath?
    typealias CellData = SwitchCellData
    func configure(data: CellData, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.ibSubjectLabel.text = data.subject
        self.ibSwitch.isOn = data.value

        ibSwitch.rx
            .isOn
            .changed
            .map(data.userAction)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
struct SwitchCellData {
    var subject: String
    var value: Bool
    var userAction: (Bool) -> Void
}
