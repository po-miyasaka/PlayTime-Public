//
//  ChartPresenter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 forceUnwrap. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol DetailQuestViewModelInput {
    func start()
    func editLimitTime(_ timeInterval: TimeInterval)
    func editQuestName(_ name: String)
    func editNotifying(_ shouldNotify: Bool)
    func editComment(_ comment: Comment, expression: String)
    func editType(_ type: QuestType)
    func close()
}

protocol DetailQuestViewModelOutput {
    var selectedDriver: Driver<Quest?> { get }
}

protocol DetailQuestViewModelProtocol {
    var inputs: DetailQuestViewModelInput { get }
    var outputs: DetailQuestViewModelOutput { get }
}

class DetailQuestViewModel: DetailQuestViewModelProtocol {
    var inputs: DetailQuestViewModelInput { return self }
    var outputs: DetailQuestViewModelOutput { return self }

    private var _selected = BehaviorRelay<Quest?>(value: nil)
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    let router: DetailQuestRouterProtocol
    init(flux: FluxProtocol = Flux.default,
         router: DetailQuestRouterProtocol
        ) {

        self.router = router
        self.flux = flux

        flux.storiesStore
            .selectedObservable
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: _selected)
            .disposed(by: disposeBag)
    }
}

extension DetailQuestViewModel: DetailQuestViewModelInput {
    func close() {
        router.close()
    }

    func editType(_ type: QuestType) {
        if let quest = _selected.value {
            flux.actionCreator.editType(quest: quest, type)
        }
    }

    func editLimitTime(_ timeInterval: TimeInterval) {
        if let quest = _selected.value {
            flux.actionCreator.editLimitTime(quest: quest, timeInterval)
        }
    }

    func editQuestName(_ name: String) {
        if let quest = _selected.value {
            flux.actionCreator.editQuestTitle(quest: quest, name)
        }
    }

    func editNotifying(_ shouldNotify: Bool) {
        if let quest = _selected.value {
            flux.actionCreator.editNotifying(quest: quest, shouldNotify)
        }
    }

    func editComment(_ comment: Comment, expression: String) {
        if let quest = _selected.value {
            flux.actionCreator.editComment(quest: quest, comment, expression: expression)
        }
    }

    func start() {
        if let quest = _selected.value {
            flux.actionCreator.start(quest: quest)
            router.toStart()
        }
    }
}

extension DetailQuestViewModel: DetailQuestViewModelOutput {
    var selectedDriver: Driver<Quest?> {
        return _selected.asDriver()
    }
}
