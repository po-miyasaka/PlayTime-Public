//
//  Story.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import Utilities

public struct Story: Codable, Diffable {

    public typealias Expression = String

    public var title: String
    public var id: StoryUniqueID
    public var isDeleted: Bool

    public var expression: String { return title }

    public init(title: String, id: StoryUniqueID, isDeleted: Bool) {
        self.title = title
        self.id = id
        self.isDeleted = isDeleted
    }
    
    public static func new(title: String) -> Story {
        return Story(title: title,
                     id: StoryUniqueID(),
                     isDeleted: false)
    }

    public func copy(title: String? = nil,
              id: StoryUniqueID? = nil,
              isDeleted: Bool? = nil
        ) -> Story {

        return Story(title: title ?? self.title,
                     id: id ?? self.id,
                     isDeleted: isDeleted ?? self.isDeleted)
    }

    public static func ==(lhs: Story, rhs: Story) -> Bool {
        return lhs.id == rhs.id
    }

}



public struct StoryUniqueID: UniqueID, Hashable {
    public var id: Date
    public init() {
        self.id = DateUtil.now()
    }

    public init(from: Date) {
        self.id = from
    }
    
    public var hashValue: Int { return Int(id.timeIntervalSince1970) }
    public func hash(into hasher: inout Hasher) { }
}

public protocol UniqueID: Codable, Comparable {
    var id: Date { get }
    init(from: Date)
}

extension UniqueID {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.id < rhs.id
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    public func getIDString() -> String {
        return DateUtil.full.formatter.string(from: id)
    }
}
