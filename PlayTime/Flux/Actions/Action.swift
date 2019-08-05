//
//  Action.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/15.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import PlayTimeObject

enum Action {
    case addQuest(Quest)
    case addStory(Story)
    case explore(QuestUniqueID, ActiveRoot)
    case returnBase
    case startDeletingQuests
    case endDeletingQuests
    case sort(SortType)
    case addStatus(ExplorerStatus)
    case userSetNotification(Bool)
    case osSetNotification(Bool)
    case settingsError(SettingsError)
    case selected(QuestUniqueID)

    case editStory(Story)
    case deleteStory(Story)
    case editQuest([Quest])

    case didBecomeActive

    case newQuestName(String)
    case newQuestDragon(Dragon.Name)
    case newQuestStory(Story)
}
