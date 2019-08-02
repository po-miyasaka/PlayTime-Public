//
//  SettingsViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UserNotifications
import UIKit

protocol SettingsViewModelInput {
    func cellTap(indexPath: IndexPath)
    func sort(_ sortType: SortType)
    func setUp()
}

protocol SettingsViewModelOutput {
    var settings: SettingTableViewData { get }
    var settingsDriver: Driver<SettingTableViewData> { get }
    var sortType: SortType { get }
    var allTimeDriver: Driver<TimeInterval> { get }
    var sortTypeDriver: Driver<SortType> { get }
    var showAlertSignal: Signal<(title: String, message: String)> { get }
    var showSortActionSignal: Signal<Void> { get }
}

class SettingsViewModel {

    private lazy var _settings = BehaviorRelay<SettingTableViewData>(value: cellData)
    private lazy var _isActive = BehaviorRelay<Bool>(value: flux.storiesStore.allQuest.isActive)
    private lazy var _allTime = BehaviorRelay<TimeInterval>(value: 0)
    private lazy var _sortType = BehaviorRelay<SortType>(value: .created)
    private var _showAlert = PublishRelay<(title: String, message: String)>()
    private var _showSortAction = PublishRelay<Void>()
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    let router: SettingsRouterProtocol

    init(flux: FluxProtocol = Flux.default,
         router: SettingsRouterProtocol) {
        self.router = router
        self.flux = flux
    }
}

extension SettingsViewModel {

    func setUp() {
        flux
            .settingsStore
            .sortObservable
            .bind(to: _sortType)
            .disposed(by: disposeBag)

        flux.storiesStore
            .allQuestObservable
            .map {[weak self] questsAll in
                self?._allTime.accept(questsAll.allTime(withActive: true))
            }.subscribe().disposed(by: disposeBag)

        flux.settingsStore
            .settingsErrorObservable
            .map { [weak self] error in
                self?._showAlert.accept((title: error.display.title, message: error.display.message))
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private var cellData: SettingTableViewData {
        var data = SettingTableViewData()

        let playTime: [SettingCellType] = [
            .playTime(.init(time: self.allTimeDriver))
        ]

        var quests: [SettingCellType] = []
        quests.append(
            .sort(.init(title: "orderOf".localized,
                        sort: self.sortTypeDriver,
                        userAction: { [weak self] in
                            self?._showSortAction.accept(())
            }))
        )

        quests.append(
            .text(.init(title: "delete".localized,
                        isShownAccessary: true,
                        userAction: {[weak self] in
                            self?.flux.actionCreator.startDeleting()
                            self?.router.close()
            }))
        )

        quests.append(
            .text(.init(title: "storyEditAddDelete".localized,
                        isShownAccessary: true,
                        userAction: { [weak self] in
                            self?.router.toEditStories()
            }))
        )

        let about: [SettingCellType] = [
            .text(.init(title: "aboutThisAppWithLink".localized,
                        isShownAccessary: true,
                        userAction: {
                            if let url = URL(string: "aboutURL".localized),
                                UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
            }))
        ]

        data.data.append(SettingSectionType.playTime(playTime))
        data.data.append(SettingSectionType.quests(quests))

        if flux.settingsStore.rStatus?.shouldAboutApp == true {
            data.data.append(SettingSectionType.about(about))
        }

        return data
    }

}

extension SettingsViewModel: SettingsViewModelInput {
    func cellTap(indexPath: IndexPath) {
        self._settings.value.cellType(from: indexPath)?.action()
    }

    func sort(_ sortType: SortType) {
        self.flux.actionCreator.sort(type: sortType)
    }

}
extension SettingsViewModel: SettingsViewModelOutput {

    var showSortActionSignal: Signal<Void> {
        return self._showSortAction.asSignal()
    }

    var sortType: SortType {
        return self._sortType.value
    }

    var sortTypeDriver: Driver<SortType> {
        return self._sortType.asDriver()
    }

    var allTimeDriver: Driver<TimeInterval> {
        return _allTime.asDriver()
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }

    var settings: SettingTableViewData {
        return _settings.value
    }

    var settingsDriver: Driver<SettingTableViewData> {
        return _settings.asDriver()
    }

}

struct SettingTableViewData {

    typealias SettingsTableViewData = [SettingSectionType]
    var data: SettingsTableViewData = []

    func cellType(from indexPath: IndexPath) -> SettingCellType? {
        guard let sectionType = getSectionType(section: indexPath.section) else {
            return nil
        }
        guard let cellType = sectionType.getCellWith(row: indexPath.row) else {
            return nil
        }
        return cellType
    }

    func getSectionType(section: Int) -> SettingSectionType? {
        guard section < data.count else {
            return nil
        }
        return data[section]
    }
}

enum SettingSectionType {
    case playTime([SettingCellType])
    case quests([SettingCellType])
    case about([SettingCellType])

    func getCellWith(row: Int) -> SettingCellType? {
        let cells: [SettingCellType] = getCells()
        guard row < cells.count else {
            return nil
        }
        return cells[row]
    }

    func getCells() -> [SettingCellType] {
        let cells: [SettingCellType]
        switch self {
        case .playTime(let c):
            cells = c
        case .quests(let c):
            cells = c
        case .about(let c):
            cells = c
        }
        return cells
    }

    var sectionName: String {
        switch self {
        case .playTime:
            return "totalPlayTime".localized
        case .quests:
            return "aQuest".localized
        case .about:
            return "aboutThisApp".localized
        }
    }

}

enum SettingCellType {
    case playTime(PlayTimeCellData)
    case sort(SortCellData)
    case text(TextCellData)

    func dequeue(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .playTime( let d):
            let cell = tableView.dequeue(t: PlayTimeCell.self, indexPath: indexPath)
            cell.configure(data: d, indexPath: indexPath)
            return cell
        case .sort(let d):
            let cell = tableView.dequeue(t: SortCell.self, indexPath: indexPath)
            cell.configure(data: d, indexPath: indexPath)
            return cell
        case .text(let d):
            let cell = tableView.dequeue(t: TextCell.self, indexPath: indexPath)
            cell.configure(data: d, indexPath: indexPath)
            return cell
        }
    }

    func action() {
        switch self {
        case .playTime:
            break
        case .sort(let d):
            d.userAction()
        case .text(let d):
            d.userAction()
        }
    }

    var shouldHighlight: Bool {
        switch  self {
        case .playTime:
            return false
        case .sort, .text:
            return true
        }
    }
}

protocol SettingsViewModelProtocol {
    var outputs: SettingsViewModelOutput { get }
    var inputs: SettingsViewModelInput { get }
}

extension SettingsViewModel: SettingsViewModelProtocol {
    var inputs: SettingsViewModelInput { return self }
    var outputs: SettingsViewModelOutput { return self }
}
