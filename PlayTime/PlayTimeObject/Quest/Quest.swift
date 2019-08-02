//
//  Quest.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/02/23Friday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import RealmSwift

struct Quest: Codable, Equatable {
    static let maxTitleLength = 25
    var id: QuestUniqueID
    var title: String
    var meanTimes: [MeanTime]
    var deleted: Bool
    var beingSelectedForDelete: Bool
    var activeDate: Date?
    var limitTime: TimeInterval
    var isNotify: Bool
    var dragonName: Dragon.Name
    var story: Story
    var comments: [Comment]

    init (title: String,
          id: QuestUniqueID,
          meanTimes: [MeanTime] = [],
          activeDate: Date? = nil,
          deleted: Bool = false,
          beingSelectedForDelete: Bool = false,
          limitTime: TimeInterval = 60 * 25,
          isNotify: Bool = false,
          dragonName: Dragon.Name,
          story: Story,
          comments: [Comment] = []
        ) {

        self.title = title
        self.id = id
        self.deleted = deleted
        self.beingSelectedForDelete = beingSelectedForDelete
        self.activeDate = activeDate
        self.meanTimes = meanTimes
        self.limitTime = limitTime
        self.isNotify = isNotify
        self.dragonName = dragonName
        self.story = story
        self.comments = comments
    }

    static func new(title: String,
                    isNotify: Bool,
                    dragonName: Dragon.Name,
                    story: Story) -> Quest {

        return Quest(title: title,
                     id: QuestUniqueID(),
                     isNotify: isNotify,
                     dragonName: dragonName,
                     story: story)
    }

    var isActive: Bool {
        return activeDate != nil
    }

    func playTime(_ withActive: Bool = true) -> TimeInterval {
        return meanTimes.sum + (withActive ? activeMeanTime : 0.0)
    }

    var activeMeanTime: TimeInterval {
        return activeDate.flatMap { DateUtil.now().timeIntervalSince($0) } ?? 0.0
    }

    var latestDate: Date? {
        let displayDate = activeDate ?? meanTimes.getLatest()?.end
        return displayDate
    }

    var firstDate: Date? {
        return  meanTimes.getFirst()?.start ?? activeDate
    }

    //    func meanTime(onlyAt: Date) -> Double {
    //        return  meanTimes.sum(onlyIn: onlyAt)
    //    }

    static func ==(lhs: Quest, rhs: Quest) -> Bool {
        return lhs.id == rhs.id
    }

    func copy(title: String? = nil,
              id: QuestUniqueID? = nil,
              meanTimes: [MeanTime]? = nil,
              activeDate: Date? = nil,
              deleted: Bool? = nil,
              beingSelectedForDelete: Bool? = nil,
              limitTime: TimeInterval? = nil,
              isNotify: Bool? = nil,
              dragonName: Dragon.Name? = nil,
              story: Story? = nil,
              comments: [Comment]? = nil,
              shouldActiveDateToNil: Bool = false
        ) -> Quest {

        return Quest(title: title ?? self.title,
                     id: id ?? self.id,
                     meanTimes: meanTimes ?? self.meanTimes,
                     activeDate: shouldActiveDateToNil ? nil : activeDate ?? self.activeDate,
                     deleted: deleted ?? self.deleted,
                     beingSelectedForDelete: beingSelectedForDelete ?? self.beingSelectedForDelete,
                     limitTime: limitTime ?? self.limitTime,
                     isNotify: isNotify ?? self.isNotify,
                     dragonName: dragonName ?? self.dragonName,
                     story: story ?? self.story,
                     comments: comments ?? self.comments )
    }

    func record(with limitTime: TimeInterval?) -> Quest {

        guard let startDate = activeDate else { return self }

        var settingTimes = self.meanTimes
        let finishDate: Date

        if let limitTime = limitTime {
            finishDate = startDate.addingTimeInterval(limitTime)
        } else {
            finishDate = DateUtil.now()
        }

        if startDate < finishDate {
            let new = MeanTime(start: startDate,
                               end: finishDate,
                               isValid: .shouldVaridate,
                               dragonName: dragonName)
            settingTimes.append(new)
        }

        let quest = self.copy(meanTimes: settingTimes, shouldActiveDateToNil: true)

        return quest
    }

    func start() -> Quest {
        guard self.activeDate == nil else { return self }
        return self.copy(activeDate: DateUtil.now())
    }

    var shouldVaridateMeantimes: Bool {
        return self.meanTimes.shouldVaridateMeanTime
    }

    func continueCount(from: Date = DateUtil.now()) -> Int {
        return meanTimes.continueCount()
    }

    func maxContinueCount() -> Int {
        return meanTimes.maxContinueCount()
    }

    func generateQuestData() -> QuestData {
        let data = QuestData()
        data.title = title
        data.createdID = id.getIDString()
        data.deleted = deleted
        data.activeTime = activeDate
        data.meanTimesData = meanTimes.generateMeanTimesData()
        data.storyData = story.generateData()
        data.dragonName = dragonName.rawValue
        data.isNotify = isNotify
        data.limitTime = limitTime
        data.commentsData = comments.generateCommentsData()
        return data
    }

}

struct QuestUniqueID: UniqueID {
    var id: Date

    init(from: Date) {
        self.id = from
    }

    init() {
        self.id = DateUtil.now()
    }
}

struct Comment: Codable, Diffable {
    let id: CommentID
    var expression: String
    var type: CommentType
    var isDeleted: Bool

    var isEditing: Bool {
        return type.isEditing
    }

    static func new(text: String, type: CommentType) -> Comment {
        let comment = Comment(id: CommentID(),
                              expression: text,
                              type: type,
                              isDeleted: false)
        return comment
    }

    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }

}

struct CommentID: UniqueID {
    var id: Date

    init() {
        self.id = DateUtil.now()
    }

    init(from: Date) {
        self.id = from
    }
}

enum CommentType: Int, Codable {
    case archive
    case changed
    case user
    case creating
    case finishQuest

    var isEditing: Bool {
        return  .user == self
    }
}
