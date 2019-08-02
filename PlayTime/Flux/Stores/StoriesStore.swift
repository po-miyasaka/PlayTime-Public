//
//  StoryStore.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol StoryStoreProtocol {
    var selectedObservable: Observable<Quest?> { get }
    var storiesObservable: Observable<[Story]> { get }
    var stories: [Story] { get }
    var dragons: [Dragon] { get }
    var dragonsObservable: Observable<[Dragon]> { get }
    var isEditingQuestsObservable: Observable<Bool> { get }
    var isEditingQuests: Bool { get }
    var allQuest: [Quest] { get }
    var allQuestObservable: Observable<[Quest]> { get }
    var activeQuest: Quest? { get }
    var activeQuestObservable: Observable<Quest?> { get }
    func questsFor(_ story: Story) -> Observable<[Quest]>
    func questsFor(_ story: Story) -> [Quest]
    var activeReason: FromType? { get }
}

final class StoryStore: StoryStoreProtocol {

    private(set) lazy var _selected = BehaviorRelay<Quest?>(value: nil)
    private(set) lazy var _stories = BehaviorRelay<[Story]>(value: self.storiesRepository.stories)
    private(set) lazy var _dragons = BehaviorRelay<[Dragon]>(value: Dragon.create(meanTimes: self.questRepository.quests.allMeanTimes))
    private(set) lazy var _allQuest = BehaviorRelay<[Quest]>(value: self.questRepository.quests)
    private(set) lazy var _isEditingQuests = BehaviorRelay<Bool>(value: false)
    private(set) lazy var _selectedForEditing = BehaviorRelay<Story?>(value: nil)
    private(set) lazy var _activeQuest = BehaviorRelay<Quest?>(value: self._allQuest.value.tuple.active.first)
    private(set) lazy var _activeReason = BehaviorRelay<FromType?>(value: self._allQuest.value.tuple.active.first.flatMap { _ in .launch })
    private let dispatcher: DispatcherProtocol
    private let questRepository: QuestRepositoryProtocol
    private let storiesRepository: StoriesRepositoryProtocol
    private let disposeBag = DisposeBag()
    static let `default` = StoryStore()

    init(dispatcher: DispatcherProtocol = Dispatcher.default,
         questRepository: QuestRepositoryProtocol = QuestRepository(),
         storiesRepository: StoriesRepositoryProtocol = StoriesRepository()) {

        self.dispatcher = dispatcher
        self.questRepository = questRepository
        self.storiesRepository = storiesRepository

        dispatcher.register {[weak self] (action: Action) in
            guard let self = self else { return }
            switch action {
            case .selected(let quest):
                if let quest = self.allQuest.first(where: { $0 == quest }) {
                    self._selected.accept(quest)
                }

            case .cancel:
                let refreshed = self._allQuest.value.finishAllIfNeed(isCancelled: true)
                questRepository.set(quests: refreshed)
                self._allQuest.accept(refreshed)
                self._activeQuest.accept(nil)

            case .editQuest(let edited):
                let refreshed = self._allQuest.value.replace(targets: [edited])
                questRepository.set(quests: refreshed)

                if let _ = self._selected.value {
                    self._selected.accept(edited)
                }

                self._allQuest.accept(refreshed)

            case .addStory(let story):
                let refreshed = self._stories.value + [story]
                storiesRepository.set(stories: refreshed)
                self._stories.accept(refreshed)

            case .addQuest(let target):
                let refreshed = self._allQuest.value + [target]
                questRepository.set(quests: refreshed)
                self._allQuest.accept(refreshed)

            case .start(let target, let reason):
                let finishRefreshed = self._allQuest.value.finishAllIfNeed()
                let refreshed = finishRefreshed.start(target).refreshed //  配列にターゲットを渡している

                questRepository.set(quests: refreshed)
                self._activeReason.accept(reason)
                self._activeQuest.accept(refreshed.tuple.active.first)
                self._allQuest.accept(refreshed)

            case .stop:
                let refreshed = self._allQuest.value.finishAllIfNeed()
                questRepository.set(quests: refreshed)
                self._allQuest.accept(refreshed)
                self._activeQuest.accept(nil)

            case .stopWith(let limitTime):
                let refreshed = self._allQuest.value.finishAllIfNeed(limitTime)
                questRepository.set(quests: refreshed)
                self._allQuest.accept(refreshed)
                self._activeQuest.accept(nil)

            case .startDeletingQuests:
                self._isEditingQuests.accept(true)

            case .selectDeleting(let target):
                let refreshedTarget = target.copy(beingSelectedForDelete: !target.beingSelectedForDelete)
                let refreshed: [Quest] = self._allQuest.value.replace(targets: [refreshedTarget])

                self._allQuest.accept(refreshed)

            case .excuteDeletingQuests:
                let refreshed = self._allQuest.value.attachDeleteFlag()
                questRepository.set(quests: refreshed)
                self._allQuest.accept(refreshed)
                self._isEditingQuests.accept(false)

                self._stories.accept(self.storiesRepository.stories)

            case .endDeletingQuests:
                let refreshed: [Quest] = self._allQuest.value.map { $0.copy(beingSelectedForDelete: false) }
                self._allQuest.accept(refreshed)
                self._isEditingQuests.accept(false)
                self._stories.accept(self.storiesRepository.stories)

            case .varidated(by: _, quests: let quests):
                questRepository.set(quests: quests)
                self._allQuest.accept(quests)

            case .deleteStory(let target):
                let deletedTarget = target.copy(isDeleted: true)

                let refreshedStory = self._stories.value.replaceTo(stories: [deletedTarget])

                let deleteTargetQuests = self._allQuest.value.filter { $0.story == deletedTarget }.map {
                    $0.copy(beingSelectedForDelete: true)
                }
                let flagedTargets = deleteTargetQuests.attachDeleteFlag().map { $0.copy(story: deletedTarget) }
                let refreshedQuests: [Quest] = self._allQuest.value.replace(targets: flagedTargets)
                self._allQuest.accept(refreshedQuests)
                questRepository.set(quests: refreshedQuests)
                storiesRepository.set(stories: [deletedTarget]) // 親をあとに

                self._stories.accept(refreshedStory)

                // あるエンティティAを編集後に保存したあとにエンティティAをもつなにかを保存すると上書きされる。

            case .renameStory(let target, let name):
                let renamedTarget = target.copy(title: name)
                storiesRepository.set(stories: [renamedTarget])
                let refreshed = self._stories.value.replaceTo(stories: [renamedTarget])

                let targetQuests = self._allQuest.value.filter { $0.story == target }.map { $0.copy(story: renamedTarget) }

                let refreshedQuests = self._allQuest.value.replace(targets: targetQuests)

                self._stories.accept(refreshed)
                self._allQuest.accept(refreshedQuests)

            default:
                break
            }
        }.disposed(by: disposeBag)
    }

    var allQuest: [Quest] {
        return _allQuest.value
    }

    var allQuestObservable: Observable<[Quest]> {
        return _allQuest.asObservable()
    }

    var storiesObservable: Observable<[Story]> {
        return _stories.asObservable()
    }

    var stories: [Story] {
        return _stories.value
    }

    var activeQuest: Quest? {
        return _activeQuest.value
    }

    var activeReason: FromType? {
        return _activeReason.value
    }

    var activeQuestObservable: Observable<Quest?> {
        return _activeQuest.asObservable()
    }

    func questsFor(_ story: Story) -> Observable<[Quest]> {

        return _allQuest
            .map { all in
                all.filter { q in q.story == story }
            }
            .asObservable()
    }

    func questsFor(_ story: Story) -> [Quest] {
        return _allQuest.value.filter { $0.story == story }
    }

    var dragons: [Dragon] {
        return _dragons.value
    }

    var dragonsObservable: Observable<[Dragon]> {
        return _dragons.asObservable()
    }

    var isEditingQuestsObservable: Observable<Bool> {
        return _isEditingQuests.asObservable()
    }

    var isEditingQuests: Bool {
        return _isEditingQuests.value
    }

    var selectedForEditing: Story? {
        return _selectedForEditing.value
    }

    var selectedForEditingObservable: Observable<Story?> {
        return _selectedForEditing.asObservable()
    }

    var selectedObservable: Observable<Quest?> {
        return _selected.asObservable()
    }
}
