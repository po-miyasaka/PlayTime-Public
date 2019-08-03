//
//  SettingsRepository.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import PlayTimeObject
import DataStore
import RealmSwift

public protocol SettingsRepositoryProtocol {
    var uuid: PlayTimeObject.UUID { get }
    var build: Build { get }
    var sortType: SortType { get }
    var status: ExplorerStatus { get }

    func set(uuid: PlayTimeObject.UUID)
    func set(sortType: SortType)
    func set(status: ExplorerStatus)
}

public class SettingsRepository: SettingsRepositoryProtocol {

    public static let `default` = SettingsRepository()
    let dataStore: DataStore

    public init(dataStore: DataStore = RealmManager.default) {
        self.dataStore = dataStore
    }

    public var status: ExplorerStatus {
        return dataGet(type: ExplorerStatus.self)
    }

    public var uuid: PlayTimeObject.UUID {
        return dataGet(type: PlayTimeObject.UUID.self)
    }

    public var build: Build {
        return Build()
    }

    public var sortType: SortType {
        return dataGet(type: SortType.self)
    }

    public var userStatus: ExplorerStatus {
        return dataGet(type: ExplorerStatus.self)
    }

    public func set(uuid: PlayTimeObject.UUID) {
        dataSet(settings: uuid)
    }

    public func set(sortType: SortType) {
        dataSet(settings: sortType)
    }

    public func set(status: ExplorerStatus) {
        dataSet(settings: status)
    }

}

extension SettingsRepository {
    private func dataGet<T>(type: T.Type) -> T where T: RealmDataMaker,
        T.EntityData.Entity == T {

            if let value = dataStore.objects(type.EntityData.self).first?.generate() {
                return value
            } else {
                let result = type.defaultValue()
                dataSet(settings: result)
                return result
            }
    }

    private func dataSet<T>(settings: T) where T: RealmDataMaker {
        return dataStore.update(settings.generateData())
    }
}
