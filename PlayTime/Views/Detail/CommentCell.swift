//
//  CommentCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/19.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell, Nibable, Configurable {

    @IBOutlet private weak var ibExpressionLabel: UILabel!
    @IBOutlet private weak var ibDateLabel: UILabel!

    @IBOutlet weak var ibPassedDayCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    var indexPath: IndexPath?
    typealias CellData = Comment
    func configure(data: CellData, indexPath: IndexPath) {
        self.indexPath = indexPath
        ibExpressionLabel.text = data.expression
        ibDateLabel.text = data.id.getIDString()
        let dayGap = data.id.id.daysGap()

        if dayGap > 0 {
            ibPassedDayCountLabel.text = "\(data.id.id.daysGap())" + "daysAgo".localized
            ibPassedDayCountLabel.isHidden = false
        } else {
            ibPassedDayCountLabel.isHidden = true
        }
    }
}
