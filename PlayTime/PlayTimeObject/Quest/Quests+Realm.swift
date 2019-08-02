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
            let data = QuestData()
            data.title = $0.title
            data.createdID = $0.id.getIDString()
            data.deleted = $0.deleted
            data.activeTime = $0.activeDate
            data.meanTimesData = $0.meanTimes.generateData()
            data.storyData = $0.story.generateData()
            data.dragonName = $0.dragonName.rawValue
            data.isNotify = $0.isNotify
            data.limitTime = $0.limitTime
            data.commentsData = $0.comments.generateCommentData()
            return data
        }

        let result = List<QuestData>()
        questDatas.forEach { result.append($0) }
        return result
    }
}
