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
    case start(Quest, FromType)
    case startDeletingQuests
    case selectDeleting(Quest)
    case excuteDeletingQuests
    case endDeletingQuests
    case varidated(by: Date, quests: [Quest])
    case setLimitTime(TimeInterval)
    case sort(SortType)
    case stop
    case stopWith(TimeInterval)
    case addStatus(ExplorerStatus)
    case userSetNotification(Bool)
    case osSetNotification(Bool)
    case resetAccurateDate
    case settingsError(SettingsError)
    case selected(Quest)

    case renameStory(Story, String)
    case deleteStory(Story)
    case editQuest(Quest)
    case cancel

    case didBecomeActive

    case newQuestName(String)
    case newQuestDragon(Dragon.Name)
    case newQuestStory(Story)
}
