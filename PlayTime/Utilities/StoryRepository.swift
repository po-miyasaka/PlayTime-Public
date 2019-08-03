//
//  StoryRepository.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import DataStore
import PlayTimeObject

public protocol StoriesRepositoryProtocol {
    var  stories: [Story] { get }
    func set(stories: [Story])
}

public class StoriesRepository: StoriesRepositoryProtocol {
    public let dataStore: DataStore
    public init(dataStore: DataStore = RealmManager.default) {
        self.dataStore = dataStore
    }

    public var stories: [Story] {
        let storysData = dataStore.objects(StoryData.self)
        return storysData.compactMap { $0.generate() }
    }

    public func set(stories: [Story]) {
        dataStore.update(stories.generateData())
    }

}
