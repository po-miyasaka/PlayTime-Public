//
//  SubTextCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/19.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import PlayTimeObject
import Utilities

class SubTextCell: UITableViewCell, Nibable, Configurable {

    @IBOutlet weak var ibSubjectLabel: UILabel!

    @IBOutlet weak var ibSubTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    var indexPath: IndexPath?
    typealias CellData = SubTextCellData
    func configure(data: CellData, indexPath: IndexPath) {
        self.indexPath = indexPath
        ibSubjectLabel.text = data.subject
        ibSubTextLabel.text = data.subText
    }
}

struct SubTextCellData {
    var subject: String
    var subText: String
}
