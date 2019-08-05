//
//  Stories.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

extension Sequence where Element == Story {
    
    public func fetch(from id: StoryUniqueID) -> Story? {
        return first(where: { $0.id == id })
    }
    
    public func replaceTo(stories: [Story]) -> [Story] {
        return map { story in
            guard let repracing = stories.first(where: { target in target.id == story.id }) else { return story }
            return repracing
        }
    }

    public var tuple: (living: [Story], deleted: [Story]) {
        var living: [Story] = []
        var deleted: [Story] = []

        self.forEach { story in
            if story.isDeleted {
                deleted.append(story)
            } else {
                living.append(story)
            }
        }
        return (living: living, deleted: deleted)
    }

}
