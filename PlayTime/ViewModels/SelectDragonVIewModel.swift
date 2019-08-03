//
//  SelectDragonVIewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/26.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift

import PlayTimeObject
import Utilities

protocol SelectDragonViewModelInput {
    func selected(dragon: Dragon.Name)
}

protocol SelectDragonViewModelOutput {
    var dragons: [Dragon] { get }
    var dragonsObservable: Observable<[Dragon]> { get }
}

class SelectDragonViewModel {
    private var _dragons = BehaviorRelay<[Dragon]>(value: [])
    var _selected = BehaviorRelay<Quest?>(value: nil)
    let flux: FluxProtocol
    let disposeBag = DisposeBag()

    private let type: DragonEditType
    init(flux: FluxProtocol = Flux.default, type: DragonEditType) {
        self.type = type
        self.flux = flux

        flux.storiesStore
            .dragonsObservable
            .bind(to: Binder(self) {[weak self] _, dragons in
                self?._dragons.accept(dragons)
            }).disposed(by: disposeBag)

        flux.storiesStore.selectedObservable
            .map {[weak self] in
                self?._selected.accept($0)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension SelectDragonViewModel: SelectDragonViewModelInput {
    func selected(dragon: Dragon.Name) {
        switch type {
        case .detail:
            if let quest = _selected.value {
                flux.actionCreator.changeDragon(quest: quest, to: dragon)
            }
        case .add:
            flux.actionCreator.newQuest(dragon: dragon)
        }
    }

}

extension SelectDragonViewModel: SelectDragonViewModelOutput {

    var dragons: [Dragon] {
        return _dragons.value
    }

    var dragonsObservable: Observable<[Dragon]> {
        return _dragons.asObservable()
    }

}

enum DragonEditType {
    case detail
    case add
}

protocol SelectDragonViewModelProtocol {
    var inputs: SelectDragonViewModelInput { get }
    var outputs: SelectDragonViewModelOutput { get }
}

extension SelectDragonViewModel: SelectDragonViewModelProtocol {
    var inputs: SelectDragonViewModelInput { return self }
    var outputs: SelectDragonViewModelOutput { return self }
}
