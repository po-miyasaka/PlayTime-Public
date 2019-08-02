//
//  SettingsStore.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol SettingsStoreProtocol {
    var uuid: String { get }
    var uuidObservable: Observable<UUID> { get }

    var rStatus: RStatus? { get }
    var rStatusObservable: Observable<RStatus?> { get }

    var userStatus: ExplorerStatus { get }
    var userStatusObservable: Observable<ExplorerStatus> { get }

    var sortObservable: Observable<SortType> { get }
    var sort: SortType { get }

    var isOsNotification: Bool { get }
    var isOsNotificationObservable: Observable<Bool> { get }

    var didBecomeActive: Observable<Void> { get }

    var settingsErrorObservable: Observable<SettingsError> { get }
}

final class SettingsStore {

    let dispatcher: DispatcherProtocol
    static let `default` = SettingsStore()
    private(set) lazy var _uuid = BehaviorRelay<UUID>(value: repository.get(type: UUID.self))
    private(set) lazy var _rStatus = BehaviorRelay<RStatus?>(value: nil)
    private let repository: SettingsRepositoryProtocol
    private let disposeBag = DisposeBag()
    private(set) lazy var _settingsError = PublishRelay<SettingsError>()
    private(set) lazy var _didBecomeActive = PublishRelay<Void>()

    private(set) lazy var _sort = BehaviorRelay<SortType>(value: repository.get(type: SortType.self))
    private(set) lazy var _isOsNotification = BehaviorRelay<Bool>(value: false)
    private(set) lazy var _userStatus = BehaviorRelay<ExplorerStatus>(value: repository.get(type: ExplorerStatus.self))

    init(dispatcher: DispatcherProtocol = Dispatcher.default,
         repository: SettingsRepositoryProtocol = SettingsRepository.default) {

        self.dispatcher = dispatcher
        self.repository = repository

        dispatcher.register {[weak self] action in
            guard let self = self else { return }
            switch action {
            case .sort(let type):
                self._sort.accept(type)
                self.repository.set(settings: type)
            case .osSetNotification(let isOn):
                self._isOsNotification.accept(isOn)
            case .addStatus(let status):
                let refreshed = self._userStatus.value.union(status)
                self.repository.set(settings: refreshed)
                self._userStatus.accept(refreshed)
            case .settingsError(let e):
                self._settingsError.accept(e)
            case .didBecomeActive:
                self._didBecomeActive.accept(())
            default:
                return
            }

        }.disposed(by: disposeBag)
    }

}

extension SettingsStore: SettingsStoreProtocol {
    var didBecomeActive: Observable<Void> {
        return _didBecomeActive.asObservable()
    }

    var uuidObservable: Observable<UUID> {
        return _uuid.asObservable()
    }

    var rStatusObservable: Observable<RStatus?> {
        return _rStatus.asObservable()
    }

    var uuid: String {
        return _uuid.value.value
    }

    var rStatus: RStatus? {
        return _rStatus.value
    }

    var userStatus: ExplorerStatus {
        return _userStatus.value
    }

    var userStatusObservable: Observable<ExplorerStatus> {
        return _userStatus.asObservable()
    }

    var sortObservable: Observable<SortType> {
        return _sort.asObservable()
    }

    var sort: SortType {
        return _sort.value
    }

    var isOsNotification: Bool {
        return _isOsNotification.value
    }

    var isOsNotificationObservable: Observable<Bool> {
        return _isOsNotification.asObservable()
    }

    var settingsErrorObservable: Observable<SettingsError> {
        return _settingsError.asObservable()
    }
}
