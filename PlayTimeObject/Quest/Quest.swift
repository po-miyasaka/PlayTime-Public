//
//  Quest.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/02/23Friday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import Utilities

public struct Quest: Codable, Equatable {
    public static let maxTitleLength = 25
    public var id: QuestUniqueID
    public var title: String
    public var meanTimes: [MeanTime]
    public var deleted: Bool
    public var beingSelectedForDelete: Bool
    public var activeDate: Date?
    public var limitTime: TimeInterval
    public var isNotify: Bool
    public var dragonName: Dragon.Name
    public var story: Story
    public var comments: [Comment]

    public init (title: String,
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

    public static func new(title: String,
                    isNotify: Bool,
                    dragonName: Dragon.Name,
                    story: Story) -> Quest {

        return Quest(title: title,
                     id: QuestUniqueID(),
                     isNotify: isNotify,
                     dragonName: dragonName,
                     story: story)
    }

    public var isActive: Bool {
        return activeDate != nil
    }

    public func playTime(_ withActive: Bool = true) -> TimeInterval {
        return meanTimes.sum + (withActive ? activeMeanTime : 0.0)
    }

    public var activeMeanTime: TimeInterval {
        return activeDate.flatMap { DateUtil.now().timeIntervalSince($0) } ?? 0.0
    }

    public var latestDate: Date? {
        let displayDate = activeDate ?? meanTimes.getLatest()?.end
        return displayDate
    }

    public var firstDate: Date? {
        return  meanTimes.getFirst()?.start ?? activeDate
    }

    //    func meanTime(onlyAt: Date) -> Double {
    //        return  meanTimes.sum(onlyIn: onlyAt)
    //    }

    public static func ==(lhs: Quest, rhs: Quest) -> Bool {
        return lhs.id == rhs.id
    }

    public func copy(title: String? = nil,
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

    public func record(with limitTime: TimeInterval?) -> Quest {

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

    public func start() -> Quest {
        guard self.activeDate == nil else { return self }
        return self.copy(activeDate: DateUtil.now())
    }

    public var shouldVaridateMeantimes: Bool {
        return self.meanTimes.shouldVaridateMeanTime
    }

    public func continueCount(from: Date = DateUtil.now()) -> Int {
        return meanTimes.continueCount()
    }

    public func maxContinueCount() -> Int {
        return meanTimes.maxContinueCount()
    }
}

public struct QuestUniqueID: UniqueID {
    public var id: Date

    public init(from: Date) {
        self.id = from
    }

    public init() {
        self.id = DateUtil.now()
    }
}

public struct Comment: Codable, Diffable {
    public let id: CommentID
    public var expression: String
    public var type: CommentType
    public var isDeleted: Bool

    public var isEditing: Bool {
        return type.isEditing
    }

    public init(id: CommentID, expression: String, type: CommentType, isDeleted: Bool) {
        self.id = id
        self.expression = expression
        self.type = type
        self.isDeleted = isDeleted
    }
    
    public static func new(text: String, type: CommentType) -> Comment {
        let comment = Comment(id: CommentID(),
                              expression: text,
                              type: type,
                              isDeleted: false)
        return comment
    }

    public static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }

}

public struct CommentID: UniqueID {
    public var id: Date

    public init() {
        self.id = DateUtil.now()
    }

    public init(from: Date) {
        self.id = from
    }
}

public enum CommentType: Int, Codable {
    case archive
    case changed
    case user
    case creating
    case finishQuest

    public var isEditing: Bool {
        return  .user == self
    }
}
