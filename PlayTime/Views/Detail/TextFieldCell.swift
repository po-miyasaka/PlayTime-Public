//
//  TextFieldCell.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/19.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import PlayTimeObject
import Utilities

class TextFieldCell: UITableViewCell, Nibable, Configurable {

    @IBOutlet weak var ibQuestNameTextField: UITextField!

    var indexPath: IndexPath?
    typealias CellData = TextFieldCellData
    var cellData: CellData?
    func configure(data: CellData, indexPath: IndexPath) {
        self.ibQuestNameTextField.delegate = self
        self.cellData = data
        ibQuestNameTextField.text = data.textFieldValue
        ibQuestNameTextField.placeholder = data.placeHolderValue

        if data.id.isEmpty {
            ibQuestNameTextField.becomeFirstResponder()
        }
    }
}

extension TextFieldCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let title = textField.text, !title.isEmpty {
            self.cellData?.userAction(title)
        } else {
            textField.text = cellData?.textFieldValue
        }

    }
}

struct TextFieldCellData: Diffable {
    static func == (lhs: TextFieldCellData, rhs: TextFieldCellData) -> Bool {
        return lhs.id == rhs.id
    }

    var id: String
    var subject: String
    var textFieldValue: String
    var placeHolderValue: String
    var tapAction: () -> Void
    var userAction: (String) -> Void

    typealias Expression = String
    var expression: String { return subject }
}
