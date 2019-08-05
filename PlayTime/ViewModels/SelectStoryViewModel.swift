//
//  SelectStoryViewModel.swift
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

protocol SelectStoryViewModelInput {
    func setUp()
    func selected(story: Story)
}

protocol SelectStoryViewModelOutput {
    var stories: [Story] { get }
    var storiesObservable: Observable<[Story]> { get }
}

class SelectStoryViewModel {
    private var _stories = BehaviorRelay<[Story]>(value: [])

    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    var _selected = BehaviorRelay<Quest?>(value: nil)

    private let type: DragonEditType

    init(flux: FluxProtocol = Flux.default, type: DragonEditType) {
        self.type = type
        self.flux = flux
    }

    func setUp() {
        flux.storiesStore
            .storiesObservable
            .map {[weak self] stories in
                self?._stories.accept(stories.tuple.living)
            }
            .subscribe()
            .disposed(by: disposeBag)

        flux.storiesStore.selectedObservable
            .map {[weak self] in
                let quest = self?.flux.storiesStore.allQuest.fetch(from: $0)
                self?._selected.accept(quest)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension SelectStoryViewModel: SelectStoryViewModelInput {

    func selected(story: Story) {

        switch type {
        case .detail:
            if let quest = _selected.value {
                flux.actionCreator.change(story: story.id, for: quest.id)
            }
        case .add:
            flux.actionCreator.setNewQuest(story: story)
        }
    }
}

extension SelectStoryViewModel: SelectStoryViewModelOutput {
    var stories: [Story] {
        return _stories.value
    }

    var storiesObservable: Observable<[Story]> {
        return _stories.asObservable()
    }
}

protocol SelectStoryViewModelProtocol {
    var inputs: SelectStoryViewModelInput { get }
    var outputs: SelectStoryViewModelOutput { get }
}

extension SelectStoryViewModel: SelectStoryViewModelProtocol {
    var inputs: SelectStoryViewModelInput { return self }
    var outputs: SelectStoryViewModelOutput { return self }
}
