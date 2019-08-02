//
//  SelectDragonItem.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/26.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import SpriteKit
import RxSwift
import RxCocoa

class SelectDragonItem: UICollectionViewCell, Configurable, Nibable {

    var disposeBag = DisposeBag()
    @IBOutlet weak var ibDragonIllustImageView: UIImageView!
    @IBOutlet weak var ibDragonNameLabel: UILabel!
    @IBOutlet weak var ibPlaytimeHeadLabel: UILabel! {
        didSet {
            ibPlaytimeHeadLabel.text = "evolveIn".localized
        }
    }
    @IBOutlet weak var ibPlaytimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        scene = nil
        disposeBag = DisposeBag()

    }

    @IBOutlet weak var ibDragonDotImageView: SKView!

    var scene: SKScene?

    var indexPath: IndexPath?
    typealias CellData = Dragon
    func configure(data: Dragon, indexPath: IndexPath) {

        ibDragonIllustImageView.image = data.images
            .illust
        ibDragonNameLabel.text = data.nameString
        ibPlaytimeLabel.text = "\(data.necessaryExperience ?? 0)" + "hour".localized

        data.presentOn(parent: ibDragonDotImageView)
    }

}
