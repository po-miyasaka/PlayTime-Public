//
//  StoryViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/27.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//
import UIKit
import Foundation
import RxCocoa
import RxSwift

import PlayTimeObject
import Utilities

protocol StoriesViewModelInput {
    func viewDidAppear(animated: Bool)
    func deleteCancel()
    func excuteDeleting()
    func addStory(name: String)
    func settingButtonTapped()
    func dragonButtonTapped()
    func select(vcType: VCType,
                reason: SelectReason)
    func addQuest()
    func finishViewTapOn()
}

protocol StoriesViewModelOutput {
    var views: [VCType] { get }
    var viewsObservable: Driver<[VCType]> { get }
    var stories: [Story] { get }
    var storiesDriver: Driver<[Story]> { get }
    var selectedStoryDriver: Driver <(before: VCType?,
        after: VCType?,
        reason: SelectReason)> { get }

    var selectedStory: (before: VCType?,
        after: VCType?,
        reason: SelectReason) { get }

    var activeQuestDriver: Driver<Quest?> { get }
    var activeQuest: Quest? { get }
    var activeReason: FromType? { get }
    var isEditingQuestDriver: Driver<Bool> { get }
    var isEditingQuests: Bool { get }
    var isUpdatingTableview: Bool { get }
    var showAlertSignal: Signal<(title: String, message: String)> { get }
    var showFinishedDriver: Driver<(Quest, Dragon)?> { get }
    var showFinished: (quest: Quest, dragon: Dragon)? { get }
    var status: ExplorerStatus { get }
    var statusDriver: Driver<ExplorerStatus> { get }
    var showTutorialSignal: Signal<Void> { get }
}

class StoriesViewModel {
    private var _stories = BehaviorRelay<[Story]>(value: [])
    private var _views = BehaviorRelay<[VCType]>(value: [])

    private lazy var _selectedStory = BehaviorRelay<(before: VCType?, after: VCType?, reason: SelectReason)>(value: (nil, .add, .launch))

    private var _questsForList = BehaviorRelay<[Quest]>(value: [])
    private var _isEditing = BehaviorRelay<Bool>(value: false)
    private var _isUpdatingTableview = BehaviorRelay<Bool>(value: false)
    private var _activeQuest = BehaviorRelay<Quest?>(value: nil)
    private lazy var _sort = BehaviorRelay<SortType>(value: flux.settingsStore.sort)
    private var _showAlert = PublishRelay<(title: String, message: String)>()
    private var _showFinished = BehaviorRelay<(Quest, Dragon)?>(value: nil)
    private var _showTutorial = PublishRelay<Void>()

    private var _activeReason = BehaviorRelay<FromType?>(value: nil)
    private lazy var _status = BehaviorRelay<ExplorerStatus>(value: flux.settingsStore.userStatus)

    var router: StoriesRouterProtocol
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    init(flux: FluxProtocol = Flux.default, router: StoriesRouterProtocol) {
        self.flux = flux
        self.router = router
    }
}

extension StoriesViewModel {
    func setUp() {
        flux.storiesStore
            .isEditingQuestsObservable
            .bind(to: _isEditing)
            .disposed(by: disposeBag)

        flux.storiesStore
            .storiesObservable
            .bind(to: Binder(self) {_, stories in

                let living = stories.tuple.living
                self._stories.accept(living)
                var vcTypes = living.map { VCType.story($0) }
                if vcTypes.isEmpty { vcTypes += [.add] }
                self._views.accept(vcTypes)

                self._selectedStory.accept((
                    before: nil,
                    after: vcTypes.first,
                    reason: .select))

            }).disposed(by: disposeBag)

        flux.settingsStore
            .userStatusObservable
            .map { $0 }
            .bind(to: _status)
            .disposed(by: disposeBag)

        flux.settingsStore
            .sortObservable
            .map { $0 }
            .bind(onNext: { sort in
                if self._questsForList.value.isEmpty == false {
                    let refreshed = self.questsForList.sort(with: sort)
                    self._questsForList.accept(refreshed)
                }})
            .disposed(by: disposeBag)

        flux.storiesStore.activeQuestObservable.map { [weak self] quest -> Quest? in
            guard let self = self else { return nil }

            if let finishedQuest = self._activeQuest.value,
                quest == nil,
                let dragon = self.flux.storiesStore.dragons.first(where: { dragon in finishedQuest.dragonName == dragon.name }) {
                self._showFinished.accept((finishedQuest, dragon))
            } else if let _ = quest, let activeReason = self.flux.storiesStore.activeReason, activeReason != .detail {
                self.router.toPlayingQuest(fromType: activeReason)
            }
            return quest
        }.bind(to: _activeQuest)
            .disposed(by: disposeBag)
    }
}

extension StoriesViewModel: StoriesViewModelInput {
    func finishViewTapOn() {
        if let quest = _showFinished.value?.0 {
            router.toDetail(originFrame: .zero, for: true)
            flux.actionCreator.selectForDetail(quest: quest)
        }
    }

    func select(vcType: VCType, reason: SelectReason) {
        _selectedStory.accept((before: selectedStory.after,
                               after: vcType, reason: reason))
    }

    func addStory(name: String) {
        flux.actionCreator.add(storyName: name)
    }

    func endUpdatingTableview() {
        _isUpdatingTableview.accept(false)
    }

    func dragonButtonTapped() {
        router.toDragon()
    }

    func addQuest() {
        if let current = _selectedStory.value.after?.story {
            router.toAddQuest(story: current)
        }
    }

    func viewDidAppear(animated: Bool) {
        _isEditing.accept(isEditingQuests)

        if let _ = activeQuest {
            router.toPlayingQuest(fromType: .launch)
        }

        if !flux.settingsStore.userStatus.contains(.tutorialShown) {
            flux.actionCreator.add(status: .tutorialShown)
            _showTutorial.accept(())
        }
    }

    func deleteCancel() {
        flux.actionCreator.cancelDeleting()
    }

    func excuteDeleting() {
        flux.actionCreator.excuteDeleting()
    }

    func settingButtonTapped() {
        router.toSettings()
    }
}

extension StoriesViewModel: StoriesViewModelOutput {
    var showTutorialSignal: Signal<Void> {
        return _showTutorial.asSignal()
    }

    var activeReason: FromType? {
        return _activeReason.value
    }

    var showFinished: (quest: Quest, dragon: Dragon)? {
        return _showFinished.value
    }

    var showFinishedDriver: Driver<(Quest, Dragon)?> {
        return _showFinished.asDriver()
    }

    var views: [VCType] {
        return _views.value
    }

    var viewsObservable: Driver<[VCType]> {
        return _views.asDriver()
    }

    var selectedStory: (before: VCType?, after: VCType?, reason: SelectReason) {
        return _selectedStory.value
    }

    var selectedStoryDriver: Driver<(before: VCType?, after: VCType?, reason: SelectReason)> {
        return _selectedStory.asDriver()
    }

    var stories: [Story] {
        return _stories.value
    }

    var storiesDriver: Driver<[Story]> {
        return _stories.asDriver()
    }

    var status: ExplorerStatus {
        return _status.value
    }

    var statusDriver: Driver<ExplorerStatus> {
        return _status.asDriver()
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }

    var activeQuestDriver: Driver<Quest?> {
        return _activeQuest.asDriver()
    }

    var activeQuest: Quest? {
        return _activeQuest.value
    }

    var questsForListDriver: Driver<[Quest]> {
        return _questsForList.asDriver()
    }

    var questsForList: [Quest] {
        return _questsForList.value
    }

    var isEditingQuestDriver: Driver<Bool> {
        return _isEditing.asDriver()
    }

    var isEditingQuests: Bool {
        return _isEditing.value
    }

    var isUpdatingTableview: Bool {
        return _isUpdatingTableview.value
    }
}

enum VCType {
    case story(Story)
    case add

    func isEqual(type: VCType) -> Bool {
        return self.story == type.story
    }

    var story: Story? {
        switch self {
        case .story(let dto):
            return dto
        default:
            return nil
        }
    }

    var title: String {
        switch self {
        case .story(let dto):
            return dto.title
        case .add:
            return "新規作成"
        }
    }
}

extension Array where Element == VCType {
    func indexOf(vcType: VCType?) -> Int {
        guard let vcType = vcType else { return 0 }
        return self.index (where: { type in
            type.isEqual(type: vcType)
        }) ?? 0
    }
}

enum SelectReason {
    case swipe
    case select
    case launch
}

protocol StoriesViewModelProtocol {
    var inputs: StoriesViewModelInput { get }
    var outputs: StoriesViewModelOutput { get }
}

extension StoriesViewModel: StoriesViewModelProtocol {
    var inputs: StoriesViewModelInput { return self }
    var outputs: StoriesViewModelOutput { return self }
}
