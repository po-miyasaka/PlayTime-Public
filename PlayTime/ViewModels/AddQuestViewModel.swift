//
//  AddQuestViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/01.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PlayTimeObject
import Utilities

protocol AddQuestViewModelInput {
    func quest(_ name: String)
    func dragon(_ name: Dragon.Name)
    func story(_ story: Story)
    func make()
    func setUp()
}

protocol AddQuestViewModelOutput {
    var showAlertSignal: Signal<(title: String, message: String)> { get }
    var story: Story { get }
    var storyDriver: Driver<Story> { get }
    var questName: String { get }
    var questNameDriver: Driver<String> { get }
    var dragonDriver: Driver<Dragon> { get }
}

class AddQuestViewModel {

    private var _showAlert = PublishRelay<(title: String, message: String)>()
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    let addStore: AddQuestStoreProtocol
    var _dragon: BehaviorRelay<Dragon>
    let _questName: BehaviorRelay<String>
    let _story: BehaviorRelay<Story>
    var router: AddQuestRouter?

    init?(flux: FluxProtocol = Flux.default, addStore: AddQuestStoreProtocol) {
        self.flux = flux
        self.addStore = addStore
        guard let dragon = self.flux
            .storiesStore
            .dragons
            .first(where: { dragon in addStore.outputs.dragon == dragon.name }) else {
                assertionFailure()
                return nil
        }

        self._dragon = BehaviorRelay<Dragon>(value: dragon)
        self._story = BehaviorRelay<Story>(value: addStore.outputs.story)
        self._questName = BehaviorRelay<String>(value: addStore.outputs.questName)
    }
}

extension AddQuestViewModel {
    func setUp() {
        addStore.outputs.dragonObservable.map {[weak self] dragonName in
            if let d = self?.flux.storiesStore.dragons.first(where: { dragonName == $0.name }) {
                self?._dragon.accept(d)
            }
        }.subscribe().disposed(by: disposeBag)

        addStore.outputs.questNameObservable.map {[weak self] questName in
            self?._questName.accept(questName)
        }.subscribe().disposed(by: disposeBag)

        addStore.outputs.storyObservable.map {[weak self] story in
            self?._story.accept(story)
        }.subscribe().disposed(by: disposeBag)
    }
}

extension AddQuestViewModel: AddQuestViewModelInput {

    func story(_ story: Story) {
        self.flux.actionCreator.setNewQuest(story: story)
    }

    func dragon(_ name: Dragon.Name) {
        self.flux.actionCreator.setNewQuest(dragon: name)
    }

    func make() {
        guard !addStore.outputs.questName.isEmpty else {
            _showAlert.accept((title: "emptyQuestName".localized, message: ""))
            return
        }

        guard addStore.outputs.questName.count <= Quest.maxTitleLength else {
            _showAlert.accept((title:"overNameCount".localized, message: ""))
            return
        }

        flux.actionCreator.add(quest: Quest.new(title: addStore.outputs.questName,
                                                isNotify: flux.settingsStore.isOsNotification,
                                                dragonName: addStore.outputs.dragon,
                                                story: addStore.outputs.story))
        router?.dismiss()
    }

    func quest(_ name: String) {
        self.flux.actionCreator.setNewQuest(name: name)
    }

}

extension AddQuestViewModel: AddQuestViewModelOutput {

    var dragonDriver: Driver<Dragon> {
        return _dragon.asDriver()
    }

    var storyDriver: Driver<Story> {
        return _story.asDriver()
    }

    var story: Story {
        return _story.value
    }

    var questNameDriver: Driver<String> {
        return _questName.asDriver()
    }

    var questName: String {
        return _questName.value
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }

}

protocol AddQuestViewModelProtocol {
    var inputs: AddQuestViewModelInput { get }
    var outputs: AddQuestViewModelOutput { get }
}

extension AddQuestViewModel: AddQuestViewModelProtocol {
    var inputs: AddQuestViewModelInput { return self }
    var outputs: AddQuestViewModelOutput { return self }
}
