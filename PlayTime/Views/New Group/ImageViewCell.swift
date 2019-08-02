//
//  ImageViewCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/05.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell, Configurable, Nibable {

    @IBOutlet weak var ibImageView: UIImageView!
    typealias CellData = ImageCellData
    var indexPath: IndexPath?

    func configure(data: CellData, indexPath: IndexPath) {
        self.ibImageView.image = data.image
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.layoutIfNeeded()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    internal func loadNib() {
        if let view = Bundle.main.loadNibNamed(ImageViewCell.className, owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.loadNib()
    }
}

struct ImageCellData {
    let image: UIImage?
}
