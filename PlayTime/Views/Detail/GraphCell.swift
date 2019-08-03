//
//  GraphCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/19.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import Utilities

class GraphCell: UITableViewCell, Nibable, Configurable {
    var indexPath: IndexPath?
    typealias CellData = GraphCellData
    func configure(data: GraphCellData, indexPath: IndexPath) {

    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

struct GraphCellData {
    var userAction: () -> Void
}
