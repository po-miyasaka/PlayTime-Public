//
//  DragonCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/19.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DragonCell: UITableViewCell, Nibable, Configurable {

    var disposeBag = DisposeBag()

    @IBOutlet weak var ibDragonNameHeadLabel: UILabel!

    @IBOutlet weak var ibEvolveTimeHeadLabel: UILabel!

    @IBOutlet private weak var ibDragonImageView: UIImageView!
    @IBOutlet private weak var ibDragonNameLabel: UILabel!
    @IBOutlet private weak var ibEvolveTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    var indexPath: IndexPath?
    typealias CellData = DragonCellData
    func configure(data: CellData, indexPath: IndexPath) {

        ibDragonImageView.image = data.dragon?
            .images
            .illust

        ibDragonNameLabel.text = data.dragon?.nameString

        ibEvolveTimeLabel.text = "\(data.dragon?.necessaryExperience ?? 0)"
    }
}

struct DragonCellData {
    var dragon: Dragon?
    var userAction: () -> Void
}
