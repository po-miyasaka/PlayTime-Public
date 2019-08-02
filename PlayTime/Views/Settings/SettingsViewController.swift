//
//  SettingViewController.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/21Sunday.
//  Copyright © 2018 pennet. All rights reserved.
//

import UIKit
import SwiftyXMLParser
import APIKit
import RxSwift
import RxCocoa

import UserNotifications
class SettingsViewController: UIViewController {

    lazy var viewModel: SettingsViewModelProtocol = SettingsViewModel(router: SettingsRouter(transitioner: self))
    let disposeBag = DisposeBag()
    weak var timerPickerView: TimerPickerView?
    lazy var dataSource = SettingViewControllerDataSource(viewModel: viewModel)
    @IBOutlet private weak var ibTableView: UITableView!
    @IBOutlet private weak var ibCloseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setUpTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpTableViewFooter()
    }

    func bind() {
        viewModel.inputs.setUp()

        viewModel.outputs
            .settingsDriver
            .drive(onNext: { [weak self] _ in self?.ibTableView.reloadData() })
            .disposed(by: disposeBag)

        viewModel.outputs
            .showAlertSignal
            .emit(onNext: {[weak self] in
                self?.showAlert(title: $0.title)
            })
            .disposed(by: disposeBag)

        viewModel.outputs
            .showSortActionSignal
            .emit(onNext: {
                [weak self] in
                self?.selectSort()
            })
            .disposed(by: disposeBag)
    }

    func setUpTableView() {
        ibTableView.register(SortCell.self)
        ibTableView.register(PlayTimeCell.self)
        ibTableView.register(TextCell.self)
        self.ibTableView.delegate = self
        self.ibTableView.dataSource = dataSource
    }
    func setUpTableViewFooter() {
        let version = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 70))

        let versionLabel = UILabel()
        versionLabel.textColor = .lightGray
        versionLabel.font = UIFont.boldSystemFont(ofSize: 10)
        versionLabel.adjustsFontSizeToFitWidth = true
        versionLabel.textAlignment = .center
        versionLabel.numberOfLines = 0
        versionLabel.text =  "version".localized + " " + version
        versionLabel.frame = footerView.bounds
        footerView.addSubview(versionLabel)
        self.ibTableView.tableFooterView = footerView
    }

    @IBAction private func ibCloseButtonTapped(_ sender: UIButton) {
        close()
    }
}

extension SettingsViewController {

    func selectSort() {
        let sheet = UIAlertController(title: "orderOf".localized, message: nil, preferredStyle: .actionSheet)

        let updateSortAction = UIAlertAction(title: "updatedOrder".localized, style: .destructive) { [weak self] _ in
            self?.viewModel.inputs.sort(.latest)
        }
        let registedSortAction = UIAlertAction(title: "registedOrder".localized, style: .destructive) { [weak self] _ in
            self?.viewModel.inputs.sort(.created)
        }
        let frequencySortAction = UIAlertAction(title: "frequencyOrder".localized, style: .destructive) { [weak self] _ in
            self?.viewModel.inputs.sort(.frequency)
        }
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .destructive) {
            _ in
        }

        sheet.addAction(updateSortAction)
        sheet.addAction(registedSortAction)
        sheet.addAction(frequencySortAction)
        sheet.addAction(cancelAction)
        present(sheet, animated: true, completion: nil)

    }

    func reload() {
        ibTableView.reloadData()
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.cellTap(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return viewModel
            .outputs
            .settings
            .cellType(from: indexPath)?
            .shouldHighlight == true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension SettingsViewController: Transitioner {
    var presentingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
    var dismissingAnimationTargetViews: [UIView] { return [view].compactMap { $0 } }
}
