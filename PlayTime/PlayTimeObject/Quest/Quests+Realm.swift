//
//  Quests+Realm.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/24.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RealmSwift
extension Sequence where Element == Quest {
    func generateQuestsData() -> List<QuestData> {
        let questDatas: [QuestData] = map {
            $0.generateQuestData()
        }

        let result = List<QuestData>()
        questDatas.forEach { result.append($0) }
        return result
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
        let dragonToRaise = Dragon.Name(rawValue: self.dragonName) ?? Dragon.Name.nii
        let limitTime = self.limitTime

        let times: [MeanTime] = self.meanTimesData.compactMap { $0.generateMeanTime() }

        let comments: [Comment] = self.commentsData.compactMap { $0.generateComment() }

        return Quest(title: title,
                     id: QuestUniqueID(from: idDate),
                     meanTimes: times,
                     activeDate: activeTime,
                     deleted: deleted,
                     limitTime: limitTime,
                     isNotify: isNotify,
                     dragonName: dragonToRaise,
                     story: story,
                     comments: comments)
    }
}

extension MeanTime {
    func generateMeanTimeData() -> MeanTimeData {
        let meanTimeData = MeanTimeData()
        meanTimeData.start = start
        meanTimeData.end = end
        meanTimeData.isValid = isValid.rawValue
        meanTimeData.dragon = dragonName.rawValue
        return meanTimeData
    }
}

extension Sequence where Element == MeanTime {
    func generateMeanTimesData() -> List<MeanTimeData> {
        let datas: [MeanTimeData] = compactMap { time in
            time.generateMeanTimeData()
        }
        let result = List<MeanTimeData>()
        datas.forEach { result.append($0) }
        return result
    }
}

class MeanTimeData: Object {
    @objc dynamic var start: Date?
    @objc dynamic var end: Date?
    @objc dynamic var isValid: Int = 0
    @objc dynamic var dragon: Int = 0

    func generateMeanTime() -> MeanTime? {
        guard let start = start else { return nil }
        guard let end = end else { return nil }
        guard isValid != MeanTimeStatus.injustice.rawValue else { return nil }
        let dragonName = Dragon.Name(rawValue: dragon) ?? .nii
        return MeanTime(start: start,
                        end: end,
                        isValid: MeanTimeStatus(statusInt: isValid),
                        dragonName: dragonName)
    }
}

extension Sequence where Element == Comment {
    func generateCommentsData() -> List<CommentData> {
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

class CommentData: Object, IDStringToDate {
    @objc dynamic var expression: String?
    @objc dynamic var createdID: String?
    @objc dynamic var type: Int = 0
    @objc dynamic var isDeleted: Bool = false

    override static func primaryKey() -> String? {
        return "createdID"
    }

    func generateComment() -> Comment? {
        guard let expression = expression else { return  nil }
        // ここで間違えてQuestDataのgetIDDateが呼ばれてた。注意
        guard let idDate = getIDDate() else { return nil }
        guard let type = CommentType(rawValue: type) else { return nil }
        guard !isDeleted else { return nil }
        return Comment(id: CommentID(from: idDate),
                       expression: expression,
                       type: type,
                       isDeleted: false)
    }

}
