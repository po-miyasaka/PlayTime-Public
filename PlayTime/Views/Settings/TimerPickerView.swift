//
//  TimerPickerView.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/03/28Wednesday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimerPickerView: UIView {

    var times: [TimeInterval] {
        return (1...72).map { TimeInterval($0) }.map {
            $0 * 60 * 5
        }
    }

    override func awakeFromNib() {
        ibPicker.setValue(UIColor.black, forKeyPath: "textColor")
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false

    }

    func setUp(with value: TimeInterval) -> Observable<TimeInterval> {
        let row = times.firstIndex(where: { $0 == value }) ?? 0
        ibPicker.selectRow( row, inComponent: 0, animated: true)
        return pickerResult.asObservable()
    }

    @IBOutlet weak var ibPicker: UIPickerView! {
        didSet {
            ibPicker.dataSource = self
            ibPicker.delegate = self
        }

    }
    private let pickerResult = PublishRelay<TimeInterval>()
    @IBAction func ibCloseButton(_ sender: UIButton) {
        if let time = times.safeFetch(ibPicker.selectedRow(inComponent: 0)) {
            pickerResult.accept(time)
        }
    }

    deinit {
    }

}

extension TimerPickerView: UIPickerViewDelegate {

}

extension TimerPickerView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let time = times.safeFetch(row) ?? 0
        return String(Int(time / 60)) + "minutes".localized
    }
}
