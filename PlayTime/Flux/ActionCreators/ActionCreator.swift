//
//  ActionCreator.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UserNotifications

protocol ActionCreatorProtocol {
    func add(storyName: String)
    func add(quest: Quest)
    func start(quest: Quest, activeReason: FromType)
    func changeStory(quest: Quest, to story: Story)
    func changeDragon(quest: Quest, to name: Dragon.Name)
    func cancel()
    
    func userSetNotification(userWill: Bool, quest: Quest)
    func osNotificationSet(isOn: Bool)
    func add(status: ExplorerStatus)
    func selectForDetail(quest: Quest)
    func stop(with limitTime: TimeInterval?)
    func setLimitTime(_ limitTime: TimeInterval)
    
    func startDeleting()
    func selectDeleting(_ target: Quest)
    func excuteDeleting()
    func endDeleting()
    func cancelDeleting()
    
    func varidate(by date: Date, quests: [Quest])
    func resetAccurateDate()
    func sort(type: SortType)
    
    func newQuest(name: String)
    func newQuest(dragon: Dragon.Name)
    func newQuest(story: Story)
    
    func renameStory(_ story: Story, newName: String)
    func deleteStory(_ story: Story)
    
    func editLimitTime(quest: Quest, _ timeInterval: TimeInterval)
    func editQuestTitle(quest: Quest, _ title: String)
    
    func editComment(quest: Quest, comment: Comment, expression: String)
    func deleteComment(quest: Quest, comment: Comment)
    func addComment(quest: Quest, text: String, type: CommentType)
    
    func didBecomeActive()
    
    #if DEBUG
    func testDataInput()
    #endif
}

class ActionCreator {
    
    static let `default` = ActionCreator()
    let dispatcher: DispatcherProtocol
    
    init(dispatcher: Dispatcher = Dispatcher.default) {
        self.dispatcher = dispatcher
    }
}

extension ActionCreator: ActionCreatorProtocol {
    
    func testDataInput() {
        
        let story = Story.new(title: "english".localized)
        dispatcher.dispatch(action: .addStory(story))
        
        // quest作成
        let reading = Quest.new(title: "reading".localized, isNotify: false, dragonName: .nii, story: story)
        sleep(2)
        let writing = Quest.new(title: "writing".localized, isNotify: false, dragonName: .travan, story: story)
        sleep(2)
        let listening = Quest.new(title: "listening".localized, isNotify: false, dragonName: .leo, story: story)
        sleep(2)
        let speaking = Quest.new(title: "speaking".localized, isNotify: false, dragonName: .momo, story: story)
        
        [reading, writing, listening, speaking].forEach { quest in
            
            var meanTimes = [MeanTime]()
            var comments = [Comment]()
            (0...20).forEach {index in
                sleep(2)
                let dayAgoOrigin = DateUtil.now().addingTimeInterval(TimeInterval(-60 * 60 * 24 * (20 - index)))
                let random = 4.random
                
                let endDate = dayAgoOrigin.addingTimeInterval(TimeInterval(60 * (60 - random) * random))
                var meanTime = MeanTime(start: dayAgoOrigin,
                                        end: endDate, isValid: .varidated, dragonName: quest.dragonName)
                let commentID = CommentID(from: endDate)
                let comment = Comment(id: commentID, expression: "comment\(index)".localized, type: .user, isDeleted: false)
                
                comments.append(comment)
                meanTimes.append(meanTime)
            }
            
            let quest = quest.copy(meanTimes: meanTimes, comments: comments)
            
            self.dispatcher.dispatch(action: .addQuest(quest))
            
        }
        
    }
    
    func didBecomeActive() {
        dispatcher.dispatch(action: .didBecomeActive)
    }
    func osNotificationSet(isOn: Bool) {
        dispatcher.dispatch(action: .osSetNotification(isOn))
    }
    
    func deleteComment(quest: Quest, comment: Comment) {
        let refreshedComments = quest.comments.filter { $0 != comment }
        let refreshedQuest = quest.copy(comments: refreshedComments)
        dispatcher.dispatch(action: .editQuest(refreshedQuest))
    }
    
    func addComment(quest: Quest, text: String, type: CommentType) {
        let comment = Comment.new(text: text, type: type)
        let refreshed = quest.copy(comments: quest.comments + [comment])
        dispatcher.dispatch(action: .editQuest(refreshed))
    }
    
    func changeDragon(quest: Quest, to name: Dragon.Name) {
        dispatcher.dispatch(action: .editQuest(quest.copy(dragonName: name)))
    }
    
    func cancel() {
        dispatcher.dispatch(action: .cancel)
        notificationService().cancel()
        
    }
    
    func changeStory(quest: Quest, to story: Story) {
        dispatcher.dispatch(action: .editQuest(quest.copy(story: story)))
    }
    
    func editLimitTime(quest: Quest, _ timeInterval: TimeInterval) {
        dispatcher.dispatch(action: .editQuest(quest.copy(limitTime: timeInterval)))
    }
    
    func editQuestTitle(quest: Quest, _ title: String) {
        dispatcher.dispatch(action: .editQuest(quest.copy(title: title)))
    }
    
    func editComment(quest: Quest, comment target: Comment, expression: String) {
        
        var commentEditing = target
        commentEditing.expression = expression
        let refreshed: [Comment] = quest.comments.map { comment in
            guard comment.id == target.id else { return comment }
            return commentEditing
        }
        
        dispatcher.dispatch(action: .editQuest(quest.copy(comments: refreshed)))
        
    }
    
    func renameStory(_ story: Story, newName: String) {
        dispatcher.dispatch(action: .renameStory(story, newName))
    }
    
    func deleteStory(_ story: Story) {
        dispatcher.dispatch(action: .deleteStory(story))
    }
    
    func newQuest(name: String) {
        dispatcher.dispatch(action: .newQuestName(name))
    }
    
    func newQuest(dragon: Dragon.Name) {
        dispatcher.dispatch(action: .newQuestDragon(dragon))
    }
    
    func newQuest(story: Story) {
        dispatcher.dispatch(action: .newQuestStory(story))
    }
    
    func add(storyName: String) {
        dispatcher.dispatch(action: .addStory(Story.new(title: storyName)))
    }
    
    func resetAccurateDate() {
        dispatcher.dispatch(action: .resetAccurateDate)
    }
    
    func add(quest: Quest) {
        dispatcher.dispatch(action: .addQuest(quest))
    }
    
    func start(quest: Quest, activeReason: FromType) {
        dispatcher.dispatch(action: .start(quest, activeReason))
        if quest.isNotify {
            notificationService().cancel()
            notificationService().set(quest: quest, limitTime: quest.limitTime)
        }
    }
    
    func stop(with limitTime: TimeInterval?) {
        
        if let limitTime = limitTime {
            dispatcher.dispatch(action: .stopWith(limitTime))
        } else {
            dispatcher.dispatch(action: .stop)
        }
        
        notificationService().cancel()
    }
    
    func setLimitTime(_ limitTime: TimeInterval) {
        dispatcher.dispatch(action: .setLimitTime(limitTime))
    }
    
    func sort(type: SortType) {
        dispatcher.dispatch(action: .sort(type))
    }
    
    func startDeleting() {
        dispatcher.dispatch(action: .startDeletingQuests)
    }
    
    func selectDeleting(_ target: Quest) {
        dispatcher.dispatch(action: .selectDeleting(target))
    }
    
    func excuteDeleting() {
        dispatcher.dispatch(action: .excuteDeletingQuests)
    }
    
    func endDeleting() {
        dispatcher.dispatch(action: .endDeletingQuests)
    }
    
    func finishDeleting(_ targets: [Quest]) {
        dispatcher.dispatch(action: .excuteDeletingQuests)
        dispatcher.dispatch(action: .endDeletingQuests)
    }
    
    func cancelDeleting() {
        dispatcher.dispatch(action: .endDeletingQuests)
    }
    
    func add(status: ExplorerStatus) {
        dispatcher.dispatch(action: .addStatus(status))
    }
    
    func varidate(by date: Date, quests: [Quest]) {
        
        let refreshed = quests.validateAll(accurateDate: date)
        dispatcher.dispatch(action: .varidated(by: date, quests: refreshed))
    }
    
    func userSetNotification(userWill: Bool, quest: Quest) {
        if userWill == false {
            dispatcher.dispatch(action: .editQuest(quest.copy(isNotify: false)))
            notificationService().cancel()
            return
        }
        
        notificationService().isUserAcceptNotification(shouldAuthorizeIfneed: true) {[weak self] result in
            self?.dispatcher.dispatch(action: .osSetNotification(result))
            self?.dispatcher.dispatch(action: .editQuest(quest.copy(isNotify: true)))
            
            if !result {
                self?.dispatcher.dispatch(action: .settingsError(SettingsError.osDeniedNotification))
            }
        }
    }
    
    func selectForDetail(quest: Quest) {
        dispatcher.dispatch(action: .selected(quest))
    }
}

extension ActionCreator {
    func notificationService() -> NotificationServiceProtocol {
        return NotificationService.default
    }
}
