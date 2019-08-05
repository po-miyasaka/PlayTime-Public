//
//  EditStoryViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/11.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift
import PlayTimeObject
import Utilities

protocol EditStoryViewModelInput {
    func input(text: String)
    func done()
    func delete()
    func back()
}

protocol EditStoryViewModelOutput {
    var selected: Story? { get }
    var isStoriesViewController: Bool { get }
    var storyNameStatus: StoryNameStatus { get }
    var storyNameStatusDriver: Driver<StoryNameStatus> { get }
}

class EditStoryViewModel {
    private var _showAlert = PublishRelay<(title: String, message: String)>()
    lazy var _input = BehaviorRelay<StoryNameStatus>(value: StoryNameStatus.create(with: self.selected?.title))

    let selected: Story?
    var router: EditStoryRouterProtocol?
    var isStoriesViewController: Bool
    let flux: FluxProtocol
    let disposeBag = DisposeBag()

    init(flux: FluxProtocol = Flux.default, selected: Story?, isStoriesViewController: Bool = false) {
        self.flux = flux
        self.selected = selected
        self.isStoriesViewController = isStoriesViewController
    }
}

extension EditStoryViewModel: EditStoryViewModelInput {
    func done() {
        guard case .ok(let name) = _input.value else { return }
        if let target = selected {
            flux.actionCreator.renameStory(target.id, newName: name)
        } else {
            flux.actionCreator.add(storyName: name)
        }
        router?.pop()
    }

    func delete() {
        if let target = selected {
            flux.actionCreator.deleteStory(target.id)
            router?.pop()
        }
    }

    func input(text: String) {
        self._input.accept(StoryNameStatus.create(with: text))
    }

    func back() {
        router?.pop()
    }
}

extension EditStoryViewModel: EditStoryViewModelOutput {
    var storyNameStatusDriver: Driver<StoryNameStatus> {
        return _input.asDriver()
    }

    var storyNameStatus: StoryNameStatus {
        return _input.value
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }
}

enum StoryNameStatus {
    case empty
    case too
    case ok(String)

    static func create(with input: String?) -> StoryNameStatus {
        switch input ?? "" {
        case let t where t.isEmpty:
            return .empty
        case let t where t.count > 10:
            return .too
        case let t:
            return ok(t)
        }
    }

    var displayText: String {
        switch self {
        case .empty:
            return ""
        case .too:
            return ""
        case .ok(let string):
            return string
        }
    }
}

protocol EditStoryViewModelProtocol {
    var inputs: EditStoryViewModelInput { get }
    var outputs: EditStoryViewModelOutput { get }
}

extension EditStoryViewModel: EditStoryViewModelProtocol {
    var inputs: EditStoryViewModelInput { return self }
    var outputs: EditStoryViewModelOutput { return self }
}
