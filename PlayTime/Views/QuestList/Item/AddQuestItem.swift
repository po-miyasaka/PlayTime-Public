//
//  AddQuestCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/01.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AddQuestItem: UICollectionViewCell, Nibable {

    @IBOutlet private weak var emptyLabel: UILabel!
    @IBOutlet private weak var emptyImage: UIImageView!
    @IBOutlet private weak var itemWidth: NSLayoutConstraint!

    var disposeBag = DisposeBag()

    @IBOutlet private weak var ibEmptyQuest: UILabel! {
        didSet {
            ibEmptyQuest.text = "questEmpty".localized
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        // Code below is needed to make the self-sizing cell work when building for iOS 12 from Xcode 10.0:
        let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
        let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
        let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        self.itemWidth.constant = UIScreen.main.bounds.width - 20

        contentView.tag = 113
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    internal func loadNib() {
        guard let view = subviews.first ?? UINib(nibName: AddQuestItem.className, bundle: nil).instantiate(withOwner: self).first as? UIView else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = self.bounds
        view.tag = 112
        let leftConstraint = view.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        let rightConstraint = view.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        let topConstraint = view.topAnchor.constraint(equalTo: contentView.topAnchor)
        let bottomConstraint = view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
        self.addSubview(view)

    }

}
