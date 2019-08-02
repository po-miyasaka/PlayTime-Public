//
//  SettingsRepository.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxSwift
protocol SettingsRepositoryProtocol {
    func get<T: RealmDataMaker>(type: T.Type) -> T where T.EntityData.Entity == T
    func set<T: RealmDataMaker>(settings: T)
}

class SettingsRepository: SettingsRepositoryProtocol {
    static let `default` = SettingsRepository()
    let dataStore: DataStore

    init(dataStore: DataStore = RealmManager.default) {
        self.dataStore = dataStore
    }

    func get<T>(type: T.Type) -> T where T: RealmDataMaker,
        T.EntityData.Entity == T {

            if let value = dataStore.objects(type.EntityData.self).first?.generate() {
                return value
            } else {
                let result = type.defaultValue()
                set(settings: result)
                return result
            }
    }

    func set<T>(settings: T) where T: RealmDataMaker {
        return dataStore.update(settings.generateData())
    }

}
