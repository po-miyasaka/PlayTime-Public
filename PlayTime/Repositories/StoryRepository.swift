//
//  StoryRepository.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

protocol StoriesRepositoryProtocol {
    var  stories: [Story] { get }
    func set(stories: [Story])
}

class StoriesRepository: StoriesRepositoryProtocol {
    let dataStore: DataStore
    init(dataStore: DataStore = RealmManager.default) {
        self.dataStore = dataStore
    }

    var stories: [Story] {
        let storysData = dataStore.objects(StoryData.self)
        return storysData.compactMap { $0.generate() }
    }

    func set(stories: [Story]) {
        dataStore.update(stories.generateData())
    }

}
