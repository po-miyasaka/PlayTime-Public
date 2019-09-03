//
//  ChartPresenter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import PlayTimeObject
import Utilities

protocol DetailQuestViewModelInput {
    func setUp()
    func start()
    func editLimitTime(_ timeInterval: TimeInterval)
    func editQuestName(_ name: String)

    func add(comment: String)
    func editing(_ comment: Comment?)
    func delete(_ comment: Comment)
    func close()
    func segmentChanged(at: SegmentType)
}

protocol DetailQuestViewModelOutput {
    var showAlertSignal: Signal<(title: String, message: String)> { get }
    var selected: Quest? { get }
    var selectedDriver: Driver<Quest?> { get }
    var dragon: Dragon? { get }
    var dragonDriver: Driver<Dragon?> { get }
    var commentsDriver: Driver<Diff<Comment>> { get }
    var comments: [Comment] { get }
    func items(section: Int) -> [DetailQuestCellType]
    var itemsAll: [DetailQuestSectionType] { get }
    var itemsAllDriver: Driver<[DetailQuestSectionType]> { get }

    var dragonIllust: UIImage? { get }
    var dragonIllustDriver: Driver<UIImage?> { get }
    var editingCommentDriver: Driver<Comment?> { get }
    var editingComment: Comment? { get }
}

class DetailQuestViewModel {

    private var _selected = BehaviorRelay<Quest?>(value: nil)
    private var _items = BehaviorRelay<[DetailQuestSectionType]>(value: [])

    private var _dragon = BehaviorRelay<Dragon?>(value: nil)
    private var _dragonImage = BehaviorRelay<UIImage?>(value: nil)
    private var _editing = BehaviorRelay<Comment?>(value: nil)
    private var _comments = BehaviorRelay<Diff<Comment>>(value: .init(old: [], new: []))
    private var _segment = BehaviorRelay<SegmentType>(value: .user)

    private var _showAlert = PublishRelay<(title: String, message: String)>()

    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    let router: DetailQuestRouterProtocol
    let isFinished: Bool

    init(flux: FluxProtocol = Flux.default,
         router: DetailQuestRouterProtocol,
         isFinished: Bool) {
        self.router = router
        self.flux = flux
        self.isFinished = isFinished
    }

    func setUp() {
        flux.settingsStore.isOsNotificationObservable.map {[weak self] _ in
            guard let self = self else { return }
            self._items.accept(self.cellData)
        }.subscribe().disposed(by: disposeBag)

        let questObservable = Observable.combineLatest(flux.storiesStore.allQuestObservable, flux.storiesStore.selectedObservable) { quests, selected in
            quests.fetch(from: selected)
        }
            .filter { $0 != nil }
            .map { $0! }

        questObservable.map {[weak self] quest in
            guard let self = self else { return }

            self._selected.accept(quest)
            self._items.accept(self.cellData)

            let dragon = self.flux.storiesStore.dragons.first(where: { dragon in quest.dragonName == dragon.name })
            self._dragon.accept(dragon)
            self._dragonImage.accept(dragon?.images.illust)

            let sorted = quest.comments.sorted(by: {lhs, rhs in
                lhs.id.id > rhs.id.id
            })

            self._comments.accept(Diff(old: self._comments.value.new, new: sorted))
        }
            .subscribe()
            .disposed(by: disposeBag)

        Observable.combineLatest(questObservable, _segment.asObservable()).map {[weak self] quest, segment in
            guard let self = self else { return }
            let sorted = quest.comments
                .filter { comment in
                    switch segment {
                    case .user:
                        return comment.type == .user
                    case .play:
                        return comment.type == .finishQuest
                    case .all:
                        return true

                    }

                }
                .sorted(by: {lhs, rhs in
                    lhs.id.id > rhs.id.id
                })

            self._comments
                .accept(Diff(old: self._comments.value.new, new: sorted))
        }.subscribe().disposed(by: disposeBag)
    }

    var cellData: [DetailQuestSectionType] {
        guard let quest = self._selected.value else {
            return []
        }

        let questInfo: [DetailQuestCellType] = [
            .timer(
                SubTextCellData(subject: "timer".localized,
                                subText: quest.limitTime.displayOnlyMinutesText()
                )
            ),

            .notify(
                SwitchCellData(subject: "notify".localized,
                               value: quest.isNotify && flux.settingsStore.isOsNotification,
                               userAction: {[weak self] value in
                                self?.flux.actionCreator.userSetNotification(userWill: value, for: quest.id)
                    }
                )
            )
        ]

        return [
            DetailQuestSectionType.items(questInfo.compactMap { $0 }),
            DetailQuestSectionType.items([])
        ]
    }
}

extension DetailQuestViewModel: DetailQuestViewModelInput {
    func segmentChanged(at: SegmentType) {
        self._segment.accept(at)
    }

    func delete(_ comment: Comment) {
        guard let quest = _selected.value else { return }

        let diff = Diff(old: _comments.value.new, new: _comments.value.new.filter { $0.id != comment.id })
        _comments.accept(diff)
        flux.actionCreator.deleteComment(quest: quest.id, comment: comment.id)
    }

    func editing(_ comment: Comment?) {
        _editing.accept(comment)

        router.toEditingComment(viewModel: self)

    }

    func add(comment text: String) {
        guard let quest = _selected.value else { return }
        guard !text.isEmpty else { return }

        switch _editing.value {
        case .some(let comment) where comment.type == .user:
            flux.actionCreator.editComment(quest: quest.id, comment: comment.id, expression: text)
        default:
            flux.actionCreator.addComment(quest: quest.id, text: text, type: .user)
        }
    }

    func close() {
        router.close()
    }

    func editLimitTime(_ timeInterval: TimeInterval) {
        if let quest = _selected.value {
            flux.actionCreator.edit(limitTime: timeInterval, for: quest.id)
        }
    }

    func editQuestName(_ title: String) {

        guard title.count <= Quest.maxTitleLength else {
            _showAlert.accept((title:"overNameCount".localized, message: ""))
            return
        }

        if let quest = _selected.value {
            flux.actionCreator.edit(title: title, for: quest.id)
        }
    }

    func editStory(to story: Story) {
        if let quest = _selected.value {
            flux.actionCreator.change(story: story.id, for: quest.id)
        }
    }

    func changeDragon(to dragonName: Dragon.Name) {
        if let quest = _selected.value {
            flux.actionCreator.change(dragon: dragonName, for: quest.id)
        }
    }

    func start() {
        if let quest = _selected.value {
            flux.actionCreator.start(quest: quest.id, activeReason: .detail)
            router.toStart()
        }
    }
}

extension DetailQuestViewModel: DetailQuestViewModelOutput {
    var editingComment: Comment? {
        return _editing.value
    }

    var editingCommentDriver: Driver<Comment?> {
        return _editing.asDriver()
    }

    var comments: [Comment] {
        return _comments.value.new
    }

    var commentsDriver: Driver<Diff<Comment>> {
        return _comments.asDriver()
    }

    var dragonDriver: Driver<Dragon?> {
        return _dragon.asDriver()
    }

    var dragonIllust: UIImage? {
        return _dragonImage.value
    }

    var dragonIllustDriver: Driver<UIImage?> {
        return _dragonImage.asDriver()
    }

    var dragon: Dragon? {
        return _dragon.value
    }

    var itemsAll: [DetailQuestSectionType] {
        return _items.value
    }
    var itemsAllDriver: Driver<[DetailQuestSectionType]> {
        return _items.asDriver()
    }

    func items(section: Int) -> [DetailQuestCellType] {
        return _items.value.safeFetch(section)?.items ?? []
    }

    var selectedDriver: Driver<Quest?> {
        return _selected.asDriver()
    }

    var selected: Quest? {
        return _selected.value
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }

}

enum DetailQuestSectionType {
    case items([DetailQuestCellType])
    var items: [DetailQuestCellType] {
        switch self {
        case .items(let types):
            return types
        }
    }
}

enum DetailQuestCellType {
    case notify(SwitchCellData)
    case timer(SubTextCellData)

    func dequeue(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch self {

        case .notify(let data):
            let cell = tableView.dequeue(t: SwitchCell.self, indexPath: indexPath)
            cell.configure(data: data, indexPath: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell

        case .timer(let data):
            let cell = tableView.dequeue(t: SubTextCell.self, indexPath: indexPath)
            cell.configure(data: data, indexPath: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell
        }
    }

    var sholudHighlight: Bool {
        switch self {
        case .timer :
            return true
        default:
            return false
        }
    }
}

enum SegmentType: Int {
    case user
    case play
    case all
}

protocol DetailQuestViewModelProtocol {
    var inputs: DetailQuestViewModelInput { get }
    var outputs: DetailQuestViewModelOutput { get }
}

extension DetailQuestViewModel: DetailQuestViewModelProtocol {
    var inputs: DetailQuestViewModelInput { return self }
    var outputs: DetailQuestViewModelOutput { return self }
}
