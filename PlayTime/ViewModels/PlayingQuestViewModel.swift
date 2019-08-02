//
//  PlayingQuestViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/04.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol PlayingQuestViewModelInput {
    func finish(with limitTime: TimeInterval?)
    func countDownDone()
    func cancel()
}

protocol PlayingQuestViewModelOutput {
    var dragonDriver: Driver<Dragon?> { get }
    var countDownDoneSignal: Signal<Void> { get }
    var fromType: FromType { get }
    var activeQuestDriver: Driver<Quest?> { get }
    var activeQuest: Quest? { get }
}

class PlayingQuestViewModel {

    private var _questsForList = BehaviorRelay<[Quest]>(value: [])
    private var _isUpdatingTableview = BehaviorRelay<Bool>(value: false)
    private var _activeQuest = BehaviorRelay<Quest?>(value: nil)
    private var _dragon = BehaviorRelay<Dragon?>(value: nil)
    private lazy var _status = BehaviorRelay<ExplorerStatus>(value: flux.settingsStore.userStatus)
    private var _startPlayingSignal: PublishRelay<Void> = .init()
    private var _countDownDoneSignal: PublishRelay<Void> = .init()

    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    var router: PlayingQuestRouterProtocol?
    let fromType: FromType

    init(flux: FluxProtocol = Flux.default,
         fromType: FromType) {

        self.flux = flux
        self.fromType = fromType
        let activeQuest = flux.storiesStore.activeQuestObservable

        Observable.combineLatest(_countDownDoneSignal.asObservable(), activeQuest)
            .filter { _, quest in quest == nil }
            .map { [weak self] _ in self?.close() }
            .subscribe()
            .disposed(by: disposeBag)

        activeQuest.filter { $0 != nil }
            .map {[weak self] quest in
                guard let self = self else { return }

                let dragon = self.flux.storiesStore.dragons.first(where: { dragon in quest!.dragonName == dragon.name })
                self._activeQuest.accept(quest)
                self._dragon.accept(dragon)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension PlayingQuestViewModel: PlayingQuestViewModelInput {

    func close() {
        router?.close()
    }

    func finish(with limitTime: TimeInterval?) {
        _countDownDoneSignal.accept(())

        if let quest = self._activeQuest.value {
            let expression: String
            let expressionTime = limitTime?.displayMunitesAndSecondText() ?? quest.activeMeanTime.displayMunitesAndSecondText()
            expression = String(format: "finishQuestComment".localized, expressionTime)
            flux.actionCreator.addComment(quest: quest, text: expression, type: .finishQuest)
        }

        flux.actionCreator.stop(with: limitTime)
    }

    func countDownDone() {
        _countDownDoneSignal.accept(())
    }

    func cancel() {
        flux.actionCreator.cancel()
        if fromType == .detail {
            router?.pop()
        } else if fromType == .launch {
            router?.close()
        } else if fromType == .list {
            router?.fadeClose()
        }
    }
}

extension PlayingQuestViewModel: PlayingQuestViewModelOutput {
    var countDownDoneSignal: Signal<Void> {
        return _countDownDoneSignal.asSignal()
    }

    var dragonDriver: Driver<Dragon?> {
        return _dragon.asDriver()
    }

    var activeQuestDriver: Driver<Quest?> {
        return _activeQuest.asDriver()
    }

    var activeQuest: Quest? {
        return _activeQuest.value
    }

    var questsForListDriver: Driver<[Quest]> {
        return _questsForList.asDriver()
    }

}

enum FromType {
    case launch
    case list
    case detail
}

protocol PlayingQuestViewModelProtocol {
    var inputs: PlayingQuestViewModelInput { get }
    var outputs: PlayingQuestViewModelOutput { get }
}

extension PlayingQuestViewModel: PlayingQuestViewModelProtocol {
    var inputs: PlayingQuestViewModelInput { return self }
    var outputs: PlayingQuestViewModelOutput { return self }
}
