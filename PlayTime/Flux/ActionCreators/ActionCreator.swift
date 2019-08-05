//
//  ActionCreator.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UserNotifications
import PlayTimeObject
import Utilities
import PlayTimeObject
import Utilities

protocol ActionCreatorProtocol {

    // クエスト作成
    func add(quest: Quest)

    func setNewQuest(name: String)
    func setNewQuest(dragon: Dragon.Name)
    func setNewQuest(story: Story)

    // クエスト編集
    func change(story: StoryUniqueID, for quest: QuestUniqueID)
    func change(dragon: Dragon.Name, for quest: QuestUniqueID)
    func edit(limitTime: TimeInterval, for quest: QuestUniqueID)
    func edit(title: String, for quest: QuestUniqueID)
    func userSetNotification(userWill: Bool, for quest: QuestUniqueID)

    // クエスト削除
    func startDeleting()
    func selectForDeleting(_ target: QuestUniqueID)
    func excuteDeleting()
    func cancelDeleting()

    // クエストバリデーション
    func varidateQuests(by date: Date)

    // クエスト操作
    func start(quest: QuestUniqueID, activeReason: ActiveRoot)
    func stop(with limitTime: TimeInterval?)
    func cancel()

    // クエストソート
    func sort(type: SortType)

    // ストーリー作成
    func add(storyName: String)

    // ストーリー編集・削除
    func renameStory(_ story: StoryUniqueID, newName: String)
    func deleteStory(_ story: StoryUniqueID)

    // 通知全体設定ON
    func osNotificationSet(isOn: Bool)

    // ユーザー状況の変更
    func add(status: ExplorerStatus)

    // クエスト詳細表示対象
    func selectForDetail(quest: QuestUniqueID)

    // コメント追加
    func addComment(quest: QuestUniqueID, text: String, type: CommentType)
    // コメント編集
    func editComment(quest: QuestUniqueID, comment: CommentID, expression: String)
    // コメント削除
    func deleteComment(quest: QuestUniqueID, comment: CommentID)

    // didBecomeActive
    func didBecomeActive()
}

class ActionCreator {

    static let `default` = ActionCreator()
    let dispatcher: DispatcherProtocol

    init(dispatcher: Dispatcher = Dispatcher.default) {
        self.dispatcher = dispatcher
    }
}

extension ActionCreator: ActionCreatorProtocol {

    func selectForDetail(quest: QuestUniqueID) {
        dispatcher.dispatch(action: .selected(quest))
    }

    func start(quest: QuestUniqueID, activeReason: ActiveRoot) {
        if let targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest)?.start() {
            dispatcher.dispatch(action: .editQuest([targetQuest]))
            dispatcher.dispatch(action: .explore(targetQuest.id, activeReason))

            if targetQuest.isNotify {
                notificationService().cancel()
                notificationService().set(quest: targetQuest, limitTime: targetQuest.limitTime)
            }
        }
    }

    func addComment(quest: QuestUniqueID, text: String, type: CommentType) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            let comment = Comment.new(text: text, type: type)
            targetQuest.comments += [comment]
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func editComment(quest: QuestUniqueID, comment: CommentID, expression: String) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            targetQuest.comments = targetQuest.comments.map {
                guard $0.id == comment else { return $0 }
                var refreshed = $0
                refreshed.expression = expression
                return refreshed
            }
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func deleteComment(quest: QuestUniqueID, comment: CommentID) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            targetQuest.comments = targetQuest.comments.filter { $0.id != comment }
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func change(story: StoryUniqueID, for quest: QuestUniqueID) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest),
            let targetStory = Flux.default.storiesStore.stories.fetch(from: story) {
            targetQuest.story = targetStory
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func change(dragon: Dragon.Name, for quest: QuestUniqueID) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            targetQuest.dragonName = dragon
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func edit(limitTime: TimeInterval, for quest: QuestUniqueID) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            targetQuest.limitTime = limitTime
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func edit(title: String, for quest: QuestUniqueID) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            targetQuest.title = title
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func userSetNotification(userWill: Bool, for quest: QuestUniqueID) {

        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: quest) {
            targetQuest.isNotify = userWill
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }

        if userWill == false {
            notificationService().cancel()
            return
        }

        notificationService().isUserAcceptNotification(shouldAuthorizeIfneed: true) {[weak self] result in
            self?.dispatcher.dispatch(action: .osSetNotification(result))

            if !result {
                self?.dispatcher.dispatch(action: .settingsError(SettingsError.osDeniedNotification))
            }
        }
    }

    func selectForDeleting(_ target: QuestUniqueID) {
        if var targetQuest = Flux.default.storiesStore.allQuest.fetch(from: target) {
            targetQuest.beingSelectedForDelete = !targetQuest.beingSelectedForDelete
            dispatcher.dispatch(action: .editQuest([targetQuest]))
        }
    }

    func varidateQuests(by date: Date) {
        let varidated = Flux.default.storiesStore.allQuest.validateAll(accurateDate: date)
        dispatcher.dispatch(action: .editQuest(varidated))
    }

    func didBecomeActive() {
        dispatcher.dispatch(action: .didBecomeActive)
    }

    func osNotificationSet(isOn: Bool) {
        dispatcher.dispatch(action: .osSetNotification(isOn))
    }

    func cancel() {
        let quests = Flux.default.storiesStore.allQuest.finishAllIfNeed(nil, isCancelled: true)
        dispatcher.dispatch(action: .editQuest(quests))
        dispatcher.dispatch(action: .returnBase)
        notificationService().cancel()

    }

    func stop(with limitTime: TimeInterval?) {
        let quests = Flux.default.storiesStore.allQuest.finishAllIfNeed(limitTime, isCancelled: false)
        dispatcher.dispatch(action: .editQuest(quests))
        dispatcher.dispatch(action: .returnBase)
        notificationService().cancel()
    }

    func renameStory(_ story: StoryUniqueID, newName: String) {
        guard var targetStory = Flux.default.storiesStore.stories.fetch(from: story) else { return }
        targetStory.title = newName
        dispatcher.dispatch(action: .editStory(targetStory))

        let refreshed = Flux.default.storiesStore.questsFor(targetStory).map { $0.copy(story: targetStory) }
        dispatcher.dispatch(action: .editQuest(refreshed))

    }

    func deleteStory(_ story: StoryUniqueID) {

        guard var targetStory = Flux.default.storiesStore.stories.fetch(from: story) else { return }
        targetStory.isDeleted = true
        dispatcher.dispatch(action: .editStory(targetStory))

        let deleted = Flux.default.storiesStore.questsFor(targetStory).map { $0.copy(beingSelectedForDelete: true, story: targetStory) }.attachDeleteFlag()
        dispatcher.dispatch(action: .editQuest(deleted))

    }

    func setNewQuest(name: String) {
        dispatcher.dispatch(action: .newQuestName(name))
    }

    func setNewQuest(dragon: Dragon.Name) {
        dispatcher.dispatch(action: .newQuestDragon(dragon))
    }

    func setNewQuest(story: Story) {
        dispatcher.dispatch(action: .newQuestStory(story))
    }

    func add(storyName: String) {
        dispatcher.dispatch(action: .addStory(Story.new(title: storyName)))
    }

    func add(quest: Quest) {
        dispatcher.dispatch(action: .addQuest(quest))
    }

    func sort(type: SortType) {
        dispatcher.dispatch(action: .sort(type))
    }

    func startDeleting() {
        dispatcher.dispatch(action: .startDeletingQuests)
    }

    func excuteDeleting() {
        let deleted = Flux.default.storiesStore.allQuest.attachDeleteFlag()
        dispatcher.dispatch(action: .editQuest(deleted))
        dispatcher.dispatch(action: .endDeletingQuests)
    }

    func cancelDeleting() {
        dispatcher.dispatch(action: .endDeletingQuests)
    }

    func add(status: ExplorerStatus) {
        dispatcher.dispatch(action: .addStatus(status))
    }
}

extension ActionCreator {
    func notificationService() -> NotificationServiceProtocol {
        return NotificationService.default
    }
}
