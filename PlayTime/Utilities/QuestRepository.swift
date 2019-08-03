//
//  QuestRepository.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import DataStore
import PlayTimeObject

public protocol QuestRepositoryProtocol {
    var quests: [Quest] { get }
    func set(quests: [Quest])
}

public class QuestRepository: QuestRepositoryProtocol {
    let dataStore: DataStore
    public init(dataStore: DataStore = RealmManager.default) {
        self.dataStore = dataStore
    }

    public var quests: [Quest] {
        let questsData = dataStore.objects(QuestData.self)
        return questsData.compactMap { data in
            guard let quest = data.generateQuest() else {
                assertionFailure("Quest is invalid \n \(data)")
                return nil
            }
            return quest
        }
    }

    public func set(quests: [Quest]) {
        dataStore.update(quests.generateQuestsData())
    }

}
