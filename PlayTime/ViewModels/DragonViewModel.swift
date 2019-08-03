//
//  DragonPresenter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

import PlayTimeObject
import Utilities

protocol DragonViewModelInput {
    func setUp()
    func close()
    func viewDidAppear()
}

protocol DragonViewModelOutput {
    var dragonsDriver: Driver<[Dragon]> { get }
    var dragons: [Dragon] { get }
    var router: DragonRouterProtocol { get }
    var tutorialSignal: Signal<Void> { get }
}

class DragonViewModel {
    private var _dragons = BehaviorRelay<[Dragon]>(value: [])
    private var _showTutorial = PublishRelay<Void>()

    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    let router: DragonRouterProtocol

    init(flux: FluxProtocol = Flux.default, router: DragonRouterProtocol) {
        self.router = router
        self.flux = flux
    }
}

extension DragonViewModel: DragonViewModelInput {
    func setUp() {
        _dragons.accept(Dragon.create(meanTimes: flux.storiesStore.allQuest.map { $0.meanTimes }.flatMap { $0 }))
    }

    func viewDidAppear() {
        if flux.settingsStore.userStatus.contains(.dragonShown) {
            flux.actionCreator.add(status: .dragonShown)
            _showTutorial.accept(())
        }
    }

    func close() {
        router.close()
    }
}

extension DragonViewModel: DragonViewModelOutput {
    var tutorialSignal: Signal<Void> {
        return _showTutorial.asSignal()
    }

    var dragonsDriver: Driver<[Dragon]> {
        return _dragons.asDriver()
    }

    var dragons: [Dragon] {
        return  _dragons.value
    }
}

protocol DragonViewModelProtocol {
    var inputs: DragonViewModelInput { get }
    var outputs: DragonViewModelOutput { get }
}

extension DragonViewModel: DragonViewModelProtocol {
    var inputs: DragonViewModelInput { return self }
    var outputs: DragonViewModelOutput { return self }
}
