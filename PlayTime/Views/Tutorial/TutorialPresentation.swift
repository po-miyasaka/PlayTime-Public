//
//  TutorialUtility.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/12.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit

protocol TutorialPresentationProtocol {
    func show()
}

class TutorialPageData {
    var forcusFrame: CGRect?
    let expression: String
    let image: UIImage?

    init(forcusFrame: CGRect?, expression: String, image: UIImage? = nil) {
        self.forcusFrame = forcusFrame
        self.expression = expression
        self.image = image
    }
}

class TutorialPresentation: TutorialPresentationProtocol {

    weak var parent: UIView?
    var targets: [TutorialPageData]
    var tutorialIndex: Int = 0
    var forcusView: UIView
    var expressionView: UIView
    var expressionLabel: UILabel?
    var expressionImageView: UIImageView?
    var backLayer: CALayer

    func adjustLabel(text: String) {
        guard let parent = parent else { return }
        if expressionLabel == nil {
            let expressionLabel = UILabel()
            expressionLabel.textColor = .white
            expressionLabel.font = UIFont.boldSystemFont(ofSize: 17)
            expressionLabel.adjustsFontSizeToFitWidth = true
            expressionLabel.textAlignment = .center
            expressionLabel.numberOfLines = 0
            expressionView.addSubview(expressionLabel)
            self.expressionLabel = expressionLabel
        }

        expressionLabel?.text = text
        let size = expressionLabel?.intrinsicContentSize ?? .zero
        expressionLabel?.frame = CGRect(x: parent.width / 2 - size.width / 2, y: 100, width: size.width, height: size.height)
    }

    init(parent: UIView, targets: [TutorialPageData]) {
        self.parent = parent
        self.targets = targets
        forcusView = UIView(frame: parent.bounds)
        expressionView = UIView()
        expressionView.frame = parent.bounds
        expressionView.addSubview(forcusView)
        let backLayer = CALayer()
        backLayer.frame = parent.bounds
        backLayer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
        self.backLayer = backLayer
        forcusView.layer.addSublayer(backLayer)

        let tapToNextLabel = UILabel()
        tapToNextLabel.textColor = .white
        tapToNextLabel.font = UIFont.boldSystemFont(ofSize: 17)
        tapToNextLabel.adjustsFontSizeToFitWidth = true
        tapToNextLabel.textAlignment = .center
        tapToNextLabel.numberOfLines = 0
        tapToNextLabel.text = "Tap to next ▷"
        tapToNextLabel.frame = parent.frame
            .change(height: tapToNextLabel.intrinsicContentSize.height)
            .change(width: tapToNextLabel.intrinsicContentSize.width)
            .change(y: parent.height - tapToNextLabel.intrinsicContentSize.height - 20)
            .change(x: parent.width - tapToNextLabel.intrinsicContentSize.width - 10)
        expressionView.addSubview(tapToNextLabel)

    }

    @objc func show() {
        defer { tutorialIndex += 1 }
        guard let parent = parent,
            let target = targets.safeFetch(tutorialIndex) else {
                finish()
                return
        }

        if tutorialIndex == 0 {
            parent.addSubview(expressionView)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(TutorialPresentation.show))
            forcusView.isUserInteractionEnabled = true
            forcusView.addGestureRecognizer(gesture)
        }

        let maskLayer = CAShapeLayer()
        if let forcusFrame = target.forcusFrame {
            let path = UIBezierPath(rect: forcusFrame)
            path.append(UIBezierPath(rect: parent.bounds))
            maskLayer.path = path.cgPath
            maskLayer.fillRule = .evenOdd // 子レイヤーが決める。自分のfillmode交差点に依存
            backLayer.mask = maskLayer
        } else {
            backLayer.mask = nil
        }

        if let image = target.image {
            if expressionImageView == nil {
                let iv = UIImageView(frame: CGRect(x: 10, y: 200, width: parent.width - 20, height: parent.height - 250))
                iv.contentMode = .scaleAspectFit
                expressionView.addSubview(iv)
                expressionImageView = iv
            }

            expressionImageView?.image = image
            expressionImageView?.alpha = 1
        } else {
            expressionImageView?.alpha = 0
        }

        adjustLabel(text: target.expression)

    }

    func finish() {
        parent?.remove(target: expressionView)
    }
}
