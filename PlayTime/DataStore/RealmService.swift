//
//  RealmService.swift
//  playTime
//
//  Created by miyasakakazutoshi on 2018/02/23Friday.
//  Copyright © 2018 po-miyasaka. All rights reserved.
//

import Foundation
import RealmSwift

protocol DataStore {
    func update<T: Object>(_ objects: List<T>)
    func objects<T: Object>(_ type: T.Type) -> [T]
}

class RealmManager: DataStore {
    private var realm: Realm?
    static let `default` = RealmManager()
    private init() {
        do {
            self.realm = try Realm()
        } catch {
            var config = Realm.Configuration()
            config.deleteRealmIfMigrationNeeded = true
            self.realm = try? Realm(configuration: config)
        }
    }

    func update<T: Object>(_ objects: List<T>) {
        try? realm?.write {
            realm?.add(objects, update: true)
        }
    }

    func objects<T: Object>(_ type: T.Type) -> [T] {
        guard let objectList = realm?.objects(type) else { return [] }
        return Array(objectList)
    }
}
