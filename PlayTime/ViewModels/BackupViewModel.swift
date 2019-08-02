//
//  BackupViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/24.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UserNotifications
//import FirebaseUI
//import FirebaseFirestore

protocol BackupViewModelInput {
    func restore()
    func backup()
    func logout()
    func back()
    func reset()
    func viewDidAppear()
}

protocol BackupViewModelOutput {
    var showAlertSignal: Signal<(title: String, message: String)> { get }
    var showLoadingViewDriver: Driver<Bool> { get }
    var showNotHostedView: Driver<Bool> { get }
    var saveTimeDriver: Driver<String> { get }
    var playTimeDriver: Driver<String> { get }
    var backupEnableDriver: Driver<Bool> { get }
    var restoreEnableDriver: Driver<Bool> { get }
    var reloadStoryName: Signal<Void> { get }

    var backupEntity: BackupEntity { get }
    var backupEntityDriver: Driver<BackupEntity> { get }

}

protocol BackupViewModelProtocol {
    var inputs: BackupViewModelInput { get }
    var outputs: BackupViewModelOutput { get }
}

class BackupViewModel: BackupViewModelProtocol {
    var inputs: BackupViewModelInput { return self }
    var outputs: BackupViewModelOutput { return self }
    let flux: FluxProtocol

    let disposeBag = DisposeBag()
    var repository: FireStoreRepositoryProtocol?
    var _backupEntity = BehaviorRelay<BackupEntity>(value: BackupEntity())
    var _showLoadingView = BehaviorRelay<Bool>(value: true)
    var _saveTime = BehaviorRelay<String>(value: "")
    var _playTime = BehaviorRelay<String>(value: "")
    var _backupEnable = BehaviorRelay<Bool>(value: false)
    var _restoreEnable = BehaviorRelay<Bool>(value: false)
    var _showNotHostedLabel = BehaviorRelay<Bool>(value: false)
    var _reloadStoryNames = PublishRelay<Void>()
    var authService: AuthServiceProtocol
    var backupStore: BackupStoreProtocol
    private var _showAlert = PublishRelay<(title: String, message: String)>()
    var _viewDidAppear = BehaviorRelay<Bool>(value: false)
    var router: BackupRouterProtocol?
    var didTryLogin: Bool
    var didTryLogout: Bool
    init(flux: FluxProtocol = Flux.default,
         backupStore: BackupStoreProtocol = BackupStore(),
         authService: AuthServiceProtocol = AuthService(),
         timeService: TimeService.Type = TimeService.self) {
        self.flux = flux
        self.backupStore = backupStore
        self.authService = authService
        didTryLogout = false
        didTryLogin = false

        authService.login()

        timeService.accurateTime().single().subscribe (
            onNext: { time in
                flux.actionCreator.varidate(by: time, quests: flux.storiesStore.allQuest)
        }, onError: {_ in
            flux.actionCreator.backupError(error: .network)
        }).disposed(by: disposeBag)

        Observable.combineLatest(backupStore.outputs.entityObservable, _viewDidAppear) {
            [weak self] entity, didAppear -> Void in
            guard let self = self else { return }
            self._backupEntity.accept(entity)
            if self.repository == nil && !entity.uid.isEmpty {
                self.repository = FireStoreRepository(uid: entity.uid)
                self.repository?.inputs.fetchMetaData()
            }

            self._playTime.accept(entity.hostedQuestData?.totalPlayTime.displayText() ?? "")
            if let savedDate = entity.hostedQuestData?.saveTime {
                let saveTimeString = DateUtil.displayDetail.formatter.string(from: savedDate)
                self._saveTime.accept(saveTimeString)
                self._reloadStoryNames.accept(())
            }

            self._showLoadingView.accept(entity.status == .undefined ||
                entity.status == .notLogined ||
                entity.varidatedQuestsData == nil)

            self._showNotHostedLabel.accept(entity.status == .neverHosted)

            if entity.status == .hosted {
                self._reloadStoryNames.accept(())
            }

            switch entity.status {
            case .restored:
                self.router?.close()
            case .logoutNow:
                self.didTryLogout = true
                self.router?.pop()
            default:
                break
            }

            if entity.status == .notLogined,
                let nvc = authService.authUIMaker?.loginViewController,
                !self.didTryLogin,
                !self.didTryLogout,
                !didAppear {
                self.didTryLogin = true
                self.router?.auth(nvc: nvc)
            }

            if case .success = entity.backupVaridate() {
                self._backupEnable.accept(true)
            } else {
                self._backupEnable.accept(false)
            }

            if case .success = entity.restoreVaridate() {
                self._restoreEnable.accept(true)
            } else {
                self._restoreEnable.accept(false)
            }

        }.subscribe().disposed(by: disposeBag)

        backupStore.outputs
            .errorObservable
            .map { $0.display }
            .bind(to: _showAlert)
            .disposed(by: disposeBag)
    }
}

extension BackupViewModel: BackupViewModelInput {
    func viewDidAppear() {
        _viewDidAppear.accept(true)
    }

    func restore() {
        self.repository?.inputs.restore(entity: _backupEntity.value)
        //        router?.close()
    }

    func backup() {
        self.repository?.inputs.backup(entity: _backupEntity.value, uuid: flux.settingsStore.uuid)
    }

    func logout() {
        authService.logout()
        router?.pop()
    }

    func back() {
        router?.pop()
    }

    func reset() {
        self.repository?.inputs.resetData()
    }

}

extension BackupViewModel: BackupViewModelOutput {
    var reloadStoryName: Signal<Void> {
        return _reloadStoryNames.asSignal()
    }

    var showNotHostedView: Driver<Bool> {
        return _showNotHostedLabel.asDriver()
    }

    var showLoadingViewDriver: Driver<Bool> {
        return _showLoadingView.asDriver()
    }

    var backupEnableDriver: Driver<Bool> {
        return _backupEnable.asDriver()
    }

    var restoreEnableDriver: Driver<Bool> {
        return _restoreEnable.asDriver()
    }

    var saveTimeDriver: Driver<String> {
        return _saveTime.asDriver()
    }

    var playTimeDriver: Driver<String> {
        return _playTime.asDriver()
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }

    var backupEntity: BackupEntity {
        return _backupEntity.value
    }

    var backupEntityDriver: Driver<BackupEntity> {
        return _backupEntity.asDriver()
    }
}
