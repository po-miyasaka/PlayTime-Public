//
//  StoryTitleItemCollectionViewCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/26.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit

class StoryTitleItem: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.loadNib()
    }

    internal func loadNib() {
        if let view = Bundle.main.loadNibNamed(StoryTitleItem.className, owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }
}
