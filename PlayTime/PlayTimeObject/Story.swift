//
//  Story.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/04/23.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RealmSwift

struct Story: Codable, Diffable {

    typealias Expression = String

    let title: String
    let id: StoryUniqueID
    let isDeleted: Bool

    var expression: String { return title }

    static func new(title: String) -> Story {
        return Story(title: title,
                     id: StoryUniqueID(),
                     isDeleted: false)
    }

    func generateData() -> StoryData {
        let result = StoryData()
        result.title = title
        result.createdID = id.getIDString()
        result.isDeleted = isDeleted
        return result
    }

    func copy(title: String? = nil,
              id: StoryUniqueID? = nil,
              isDeleted: Bool? = nil
        ) -> Story {

        return Story(title: title ?? self.title,
                     id: id ?? self.id,
                     isDeleted: isDeleted ?? self.isDeleted)
    }

    static func ==(lhs: Story, rhs: Story) -> Bool {
        return lhs.id == rhs.id
    }

}

extension Story: Hashable {

    var hashValue: Int { return Int(id.id.timeIntervalSince1970) }
    func hash(into hasher: inout Hasher) {

    }

}

class StoryData: Object, IDStringToDate {
    @objc dynamic var title: String?
    @objc dynamic var createdID: String?
    @objc dynamic var isDeleted: Bool = false
    override static func primaryKey() -> String? {
        return "createdID"
    }

    func generate() -> Story? {
        guard let title = title,
            let idDate = getIDDate() else { return nil }

        return Story(title: title, id: StoryUniqueID(from: idDate), isDeleted: isDeleted)
    }

}

struct StoryUniqueID: UniqueID {
    var id: Date
    init() {
        self.id = DateUtil.now()
    }

    init(from: Date) {
        self.id = from
    }
}

protocol UniqueID: Codable, Comparable {
    var id: Date { get }
    init(from: Date)
}

extension UniqueID {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.id < rhs.id
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    func getIDString() -> String {
        return DateUtil.full.formatter.string(from: id)
    }
}

protocol IDStringToDate: NSObject {
    var createdID: String? { get }
}

extension IDStringToDate {
    func getIDDate() -> Date? {
        guard let idString = createdID else { return nil }
        return DateUtil.full.formatter.date(from: idString)
    }
}
