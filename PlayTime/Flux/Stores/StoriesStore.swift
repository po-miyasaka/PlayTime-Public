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
import PlayTimeObject
import Utilities

protocol StoryStoreProtocol {
    var selectedObservable: Observable<QuestUniqueID?> { get }
    var storiesObservable: Observable<[Story]> { get }
    var stories: [Story] { get }
    var dragons: [Dragon] { get }
    var dragonsObservable: Observable<[Dragon]> { get }
    var isEditingQuestsObservable: Observable<Bool> { get }
    var isEditingQuests: Bool { get }
    var allQuest: [Quest] { get }
    var allQuestObservable: Observable<[Quest]> { get }
    var activeQuest: QuestUniqueID? { get }
    var activeQuestObservable: Observable<QuestUniqueID?> { get }
    func questsFor(_ story: Story) -> Observable<[Quest]>
    func questsFor(_ story: Story) -> [Quest]
    var activeReason: ActiveRoot? { get }
}

final class StoryStore: StoryStoreProtocol {

    private(set) lazy var _selected = BehaviorRelay<QuestUniqueID?>(value: nil)
    private(set) lazy var _stories = BehaviorRelay<[Story]>(value: self.storiesRepository.stories)
    private(set) lazy var _dragons = BehaviorRelay<[Dragon]>(value: Dragon.create(meanTimes: self.questRepository.quests.allMeanTimes))
    private(set) lazy var _allQuest = BehaviorRelay<[Quest]>(value: self.questRepository.quests)
    private(set) lazy var _isEditingQuests = BehaviorRelay<Bool>(value: false)
    private(set) lazy var _selectedForEditing = BehaviorRelay<Story?>(value: nil)
    private(set) lazy var _activeQuest = BehaviorRelay<QuestUniqueID?>(value: self._allQuest.value.tuple.active.first?.id)
    private(set) lazy var _activeReason = BehaviorRelay<ActiveRoot?>(value: self._allQuest.value.tuple.active.first.flatMap { _ in .launch })
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

                
            case .addQuest(let target):
                questRepository.set(quests: [target])
                let refreshed = self._allQuest.value + [target]
                self._allQuest.accept(refreshed)
                
            case .editQuest(let edited):
                let refreshed = self._allQuest.value.replace(targets: edited)
                questRepository.set(quests: refreshed)
                self._allQuest.accept(refreshed)

            case .selected(let quest):
                self._selected.accept(quest)

            case .explore(let quest, let reason):
                self._activeReason.accept(reason)
                self._activeQuest.accept(quest)

            case .returnBase:
                self._activeReason.accept(nil)
                self._activeQuest.accept(nil)

            case .startDeletingQuests:
                self._isEditingQuests.accept(true)

            case .endDeletingQuests:
                self._isEditingQuests.accept(false)

                
            case .addStory(let story):
                let refreshed = self._stories.value + [story]
                storiesRepository.set(stories: refreshed)
                self._stories.accept(refreshed)
                // エンティティAを編集後に保存したあとにエンティティAをもつ何かを保存すると上書きされる。
            case .editStory(let target):
                let refreshed = self._stories.value.replaceTo(stories: [target])
                storiesRepository.set(stories: [target])
                self._stories.accept(refreshed)

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

    var activeQuest: QuestUniqueID? {
        return _activeQuest.value
    }

    var activeReason: ActiveRoot? {
        return _activeReason.value
    }

    var activeQuestObservable: Observable<QuestUniqueID?> {
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

    var selectedObservable: Observable<QuestUniqueID?> {
        return _selected.asObservable()
    }
}
