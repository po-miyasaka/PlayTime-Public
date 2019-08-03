//
//  QuestCell.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/14Sunday.
//  Copyright © 2018 pennet. All rights reserved.
//

import UIKit
import SpriteKit
import RxSwift
import PlayTimeObject
import Utilities

class QuestItem: UICollectionViewCell, Nibable {

    @IBOutlet private weak var ibTitle: UILabel!

    @IBOutlet private weak var ibDragonImage: UIImageView!

    @IBOutlet private weak var ibPlaytime: UILabel!

    @IBOutlet private weak var ibPlaycount: UILabel!

    @IBOutlet private weak var ibTimer: UILabel! {
        didSet {
            ibTimer.isHidden = true
        }
    }

    @IBOutlet private weak var ibContinuing: UILabel!

    @IBOutlet private weak var ibComment: UILabel!

    @IBOutlet private weak var itemWidth: NSLayoutConstraint!

    @IBOutlet private weak var ibDetailButton: UIButton!

    @IBOutlet private weak var ibSelectedView: UIView!

    @IBOutlet weak var ibSoonStartButton: UIButton! {
        didSet {
            ibSoonStartButton.setTitle("startNow".localized, for: .normal)
            ibSoonStartButton.layer.borderColor = UIColor(hexString: "CFBC0A").cgColor
        }
    }

    var viewModel: QuestListViewModelProtocol?
    var indexPath: IndexPath?
    var disposeBag = DisposeBag()
    var itemData: QuestItemData?

    func configure(itemData: QuestItemData, indexPath: IndexPath) {
        self.itemData = itemData
        self.indexPath = indexPath

        ibTitle.text = itemData.quest.title
        ibDragonImage.image = itemData.dragon?.images.illust

        ibPlaytime.text = itemData.quest.playTime().displayText()
        ibPlaycount.text = "\(itemData.quest.meanTimes.count)" + "count".localized

        ibComment.text = itemData.quest
            .comments.filter { $0.isEditing }
            .sorted(by: {lhs, rhs in
                lhs.id.id > rhs.id.id
            }).first?.expression

        if itemData.quest.continueCount() > 0 {
            ibContinuing.isHidden = false
            ibContinuing.text = String(format: "consectiveDays".localized, itemData.quest.continueCount())
        } else {
            ibContinuing.isHidden = true
        }

        ibSelectedView.isHidden = !itemData.quest.beingSelectedForDelete

        ibSoonStartButton.rx.tap.map {[weak self] in
            guard let self = self else { return }
            self.viewModel?.inputs.startNow(indexPath: indexPath)
        }.subscribe().disposed(by: disposeBag)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        self.itemWidth.constant = UIScreen.main.bounds.width - 50

        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false

        ibSelectedView.layer.cornerRadius = 10
        ibSelectedView.layer.masksToBounds = true

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
