//
//  QuestRepository.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

protocol  QuestRepositoryProtocol {
    var quests: [Quest] { get }
    func set(quests: [Quest])
}

class QuestRepository: QuestRepositoryProtocol {
    let dataStore: DataStore
    init(dataStore: DataStore = RealmManager.default) {
        self.dataStore = dataStore
    }

    var quests: [Quest] {
        let questsData = dataStore.objects(QuestData.self)
        return questsData.compactMap { data in
            guard let quest = data.generateQuest() else {
                assertionFailure("Quest is invalid \n \(data)")
                return nil
            }
            return quest
        }
    }

    func set(quests: [Quest]) {
        dataStore.update(quests.generateQuestsData())
    }

}
