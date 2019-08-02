//
//  storiesStore.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/15.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol AddQuestStoreOutputProtocol {
    var questName: String { get }
    var story: Story { get }
    var dragon: Dragon.Name { get }

    var questNameObservable: Observable<String> { get }
    var storyObservable: Observable<Story> { get }
    var dragonObservable: Observable<Dragon.Name> { get }
}

protocol AddQuestStoreProtocol {
    var outputs: AddQuestStoreOutputProtocol { get }
}

final class AddQuestStore: AddQuestStoreProtocol {
    var outputs: AddQuestStoreOutputProtocol { return self }

    private(set) lazy var _questName = BehaviorRelay<String>(value: "")
    private(set) lazy var _dragon = BehaviorRelay<Dragon.Name>(value: defaultDragon)
    private(set) lazy var _story = BehaviorRelay<Story>(value: defaultStory)

    let defaultStory: Story
    let defaultDragon: Dragon.Name
    private let dispatcher: DispatcherProtocol
    private let repository: QuestRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(dispatcher: DispatcherProtocol = Dispatcher.default,
         repository: QuestRepositoryProtocol = QuestRepository(),
         defaultStory: Story, dragonName: Dragon.Name) {

        self.defaultStory = defaultStory
        self.defaultDragon = dragonName

        self.dispatcher = dispatcher
        self.repository = repository

        dispatcher.register {[weak self] action in
            guard let self = self else { return }
            switch action {
            case .newQuestName(let title):
                self._questName.accept(title)
            case .newQuestDragon(let dragon):
                self._dragon.accept(dragon)
            case .newQuestStory(let story):
                self._story.accept(story)
            default:
                break
            }
        }.disposed(by: disposeBag)
    }

}

extension AddQuestStore: AddQuestStoreOutputProtocol {
    var storyObservable: Observable<Story> {
        return _story.asObservable()
    }

    var questName: String {
        return _questName.value
    }

    var story: Story {
        return _story.value
    }

    var questNameObservable: Observable<String> {
        return _questName.asObservable()
    }

    var dragon: Dragon.Name {
        return _dragon.value
    }

    var dragonObservable: Observable<Dragon.Name> {
        return _dragon.asObservable()
    }
}
