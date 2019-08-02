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
        return meanTimes.sumPlayTimeInterval + (withActive ? activeMeanTime : 0.0)
    }

    var activeMeanTime: TimeInterval {
        return activeDate.flatMap { DateUtil.now().timeIntervalSince($0) } ?? 0.0
    }

    var latestDate: Date? {
        let displayDate = activeDate ?? meanTimes.getLatestEndTime()
        return displayDate
    }

    var firstDate: Date? {
        return  meanTimes.min { lhs, rhs in lhs.start < rhs.start }?.start ?? activeDate
    }

    func meanTime(onlyAt: Date) -> Double {
        return  meanTimes.sum(onlyIn: onlyAt)
    }

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

class QuestData: Object, IDStringToDate {
    @objc dynamic var title: String?
    @objc dynamic var deleted: Bool = false
    @objc dynamic var createdID: String?
    @objc dynamic var activeTime: Date?
    @objc dynamic var limitTime: TimeInterval = 60 * 25 * 1
    @objc dynamic var isNotify: Bool = false
    @objc dynamic var dragonName: Int = 0
    @objc dynamic var storyData: StoryData?

    var meanTimesData = List<MeanTimeData>()
    var commentsData = List<CommentData>()

    override static func primaryKey() -> String? {
        return "createdID"
    }

    func generateQuest() -> Quest? {
        //        guard self.deleted == false else { /*RealmManager.delete(self);*/ return nil }
        guard let title = self.title else { return nil }
        guard let idDate = getIDDate() else { return nil }
        guard let story = storyData?.generate()  else { return nil }

        let isNotify = self.isNotify
        let dragonName = Dragon.Name(rawValue: self.dragonName) ?? Dragon.Name.nii
        let limitTime = self.limitTime

        let times: [MeanTime] = self.meanTimesData.compactMap {
            guard let start = $0.start else { return nil }
            guard let end = $0.end else { return nil }
            guard $0.isValid != 2 else { return nil }
            return MeanTime(start: start,
                            end: end,
                            isValid: MeanTimeStatus(statusInt: $0.isValid),
                            dragonName: dragonName

            )
        }

        let comments: [Comment] = self.commentsData.compactMap {
            guard let expression = $0.expression else { return  nil }
            // ここで間違えてQuestDataのgetIDDateが呼ばれてた。注意
            guard let idDate = $0.getIDDate() else { return nil }
            guard let type = CommentType(rawValue: $0.type) else { return nil }
            guard !$0.isDeleted else { return nil }
            return Comment(id: CommentID(from: idDate),
                           expression: expression,
                           type: type,
                           isDeleted: false)
        }

        return Quest(title: title,
                     id: QuestUniqueID(from: idDate),
                     meanTimes: times,
                     activeDate: activeTime,
                     deleted: deleted,
                     limitTime: limitTime,
                     isNotify: isNotify,
                     dragonName: dragonName,
                     story: story,
                     comments: comments)
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

class CommentData: Object, IDStringToDate {
    @objc dynamic var expression: String?
    @objc dynamic var createdID: String?
    @objc dynamic var type: Int = 0
    @objc dynamic var isDeleted: Bool = false

    override static func primaryKey() -> String? {
        return "createdID"
    }
}

extension Sequence where Element == Comment {

    func generateCommentData() -> List<CommentData> {
        let commentDatas: [CommentData] = map {
            let data = CommentData()
            data.createdID = $0.id.getIDString()
            data.type = $0.type.rawValue
            data.expression = $0.expression
            data.isDeleted = $0.isDeleted
            return data
        }
        let result = List<CommentData>()
        commentDatas.forEach { result.append($0) }
        return result
    }
}
