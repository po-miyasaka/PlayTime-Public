//
//  QuestListViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/13.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import PlayTimeObject
import Utilities

protocol QuestListViewModelInput {
    func setUp()
    func viewWillAppear()
    func itemTapped(indexPath: IndexPath, itemFrame: CGRect)
    func startNow(indexPath: IndexPath)
}

protocol QuestListViewModelOutput {

    var itemsDriver: Driver<Diff<QuestListItemType>> { get }
    var items: [QuestListItemType] { get }

    var isEditingQuestDriver: Driver<Bool> { get }
    var isEditingQuests: Bool { get }

    var showAlertSignal: Signal<(title: String, message: String)> { get }
    var story: Story { get }
}

class QuestListViewModel {

    private var _items = BehaviorRelay<Diff<QuestListItemType>>(value: Diff<QuestListItemType>(old: [], new: []))
    private var _isEditing = BehaviorRelay<Bool>(value: false)
    private var _showAlert = PublishRelay<(title: String, message: String)>()

    private var _showAdd = PublishRelay<AddQuestViewModel>()

    let storiesRouter: StoriesRouterProtocol
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    var _story: BehaviorRelay<Story>

    init(flux: FluxProtocol = Flux.default,
         story: Story,
         storiesRouter: StoriesRouterProtocol) {

        self._story = BehaviorRelay<Story>(value: story)
        self.storiesRouter = storiesRouter
        self.flux = flux
    }
}

extension QuestListViewModel {
    func setUp() {
        flux.storiesStore
            .storiesObservable
            .map { $0.first(where: { $0 == self.story }) }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: _story)
            .disposed(by: disposeBag)

        flux.storiesStore
            .isEditingQuestsObservable
            .bind(to: _isEditing)
            .disposed(by: disposeBag)

        Observable.combineLatest(flux.storiesStore
            .questsFor(story), flux.settingsStore.sortObservable).subscribe(onNext: {[weak self] quests, sort in
                guard let self = self else { return }
                let living = quests.livingQuests.sort(with: sort)

                var items: [QuestListItemType] = living.map {[weak self] quest in
                    let dragon = self?.flux
                        .storiesStore
                        .dragons
                        .first(where: { dragon in quest.dragonName == dragon.name })
                    let item = QuestItemData(quest: quest, dragon: dragon)
                    return QuestListItemType.quest(item)
                }

                if items.isEmpty {
                    items += [.add]
                }

                self._items.accept(Diff(old: self._items.value.new, new: items))

            }).disposed(by: disposeBag)
    }
}

extension QuestListViewModel: QuestListViewModelInput {

    func startNow(indexPath: IndexPath) {

        guard  let type = _items.value.new.safeFetch(indexPath.row) else {
            _showAlert.accept((title: "inexpected error".localized, message: ""))
            return
        }

        if case .quest(let quest) = type {
            flux.actionCreator.start(quest: quest.quest.id, activeReason: .list)
        }

    }

    func itemTapped(indexPath: IndexPath, itemFrame: CGRect) {
        guard  let type = items.safeFetch(indexPath.row) else {
            _showAlert.accept((title:"inexpected error".localized, message: ""))
            return
        }

        switch type {
        case .quest(let questItem):
            questTapped(quest: questItem.quest, itemFrame: itemFrame)
        case .add:
            break
        }
    }

    func viewWillAppear() {
        _isEditing.accept(isEditingQuests)
    }

    func questTapped(quest: Quest, itemFrame: CGRect) {
        if !self.flux.storiesStore.isEditingQuests {
            storiesRouter.toDetail(originFrame: itemFrame, for: false)
            flux.actionCreator.selectForDetail(quest: quest.id)
        } else {
            flux.actionCreator.selectForDeleting(quest.id)
        }
    }

    func deleteCancel() {
        flux.actionCreator.cancelDeleting()
    }
}

extension QuestListViewModel: QuestListViewModelOutput {
    var story: Story {
        return _story.value
    }

    var itemsDriver: Driver<Diff<QuestListItemType>> {
        return _items.asDriver()
    }

    var showAddSignal: Signal<AddQuestViewModel> {
        return _showAdd.asSignal()
    }

    var items: [QuestListItemType] {
        return _items.value.new
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }

    var isEditingQuestDriver: Driver<Bool> {
        return _isEditing.asDriver()
    }

    var isEditingQuests: Bool {
        return _isEditing.value
    }
}

typealias Title = String

enum QuestListItemType: Diffable {
    case quest(QuestItemData)
    case add

    typealias Expression = String
    var expression: String {
        switch self {
        case .quest(let data):
            return data.quest.title +
                "\(data.quest.dragonName.rawValue)" +
                data.quest.activeMeanTime.description + "\(data.quest.beingSelectedForDelete)" + (data.quest.comments.last?.expression ?? "")

        default:
            return "add"
        }
    }

    var id: String { return quest?.id.getIDString() ?? "add" }

    var quest: Quest? {
        switch self {
        case .quest(let data):
            return data.quest
        default:
            return nil
        }
    }

    static func == (lhs: QuestListItemType, rhs: QuestListItemType) -> Bool {
        switch (lhs, rhs) {
        case (.quest(let lhsData), .quest(let rhsData)):
            return lhsData.quest == rhsData.quest
        default:
            return false
        }

    }
}

struct QuestItemData {
    var quest: Quest
    var dragon: Dragon?
}

protocol QuestListViewModelProtocol {
    var inputs: QuestListViewModelInput { get }
    var outputs: QuestListViewModelOutput { get }
}

extension QuestListViewModel: QuestListViewModelProtocol {
    var inputs: QuestListViewModelInput { return self }
    var outputs: QuestListViewModelOutput { return self }
}
