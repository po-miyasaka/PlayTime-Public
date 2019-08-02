//
//  EditStoriesViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/10.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift

protocol EditStoriesViewModelInput {
    func setUp()
    func selected(story: Story)
    func back()
    func add()
    func delete(_ cellData: TextFieldCellData)
}

protocol EditStoriesViewModelOutput {
    var cellDatas: [TextFieldCellData] { get }
    var cellDatasObservable: Observable<Diff<TextFieldCellData>> { get }
}

class EditStoriesViewModel {

    private var _cellDatas = BehaviorRelay<Diff<TextFieldCellData>>(value: .init(old:[], new: []))
    private var _showAlert = PublishRelay<(title: String, message: String)>()
    private var _showDetail = PublishRelay<DetailQuestViewModel>()
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    var router: EditStoriesRouter?

    init(flux: FluxProtocol = Flux.default) {
        self.flux = flux
    }

    func setUp() {
        flux.storiesStore
            .storiesObservable
            .map {[weak self] stories -> Void in
                guard let self = self else { return () }
                let cellDatas: [TextFieldCellData] = stories.tuple.living.map { story in
                    let data = TextFieldCellData(uniqueID: story.id.getIDString(), subject: story.title, textFieldValue: story.title, placeHolderValue: story.title, tapAction: {  }, userAction: {
                        self.flux.actionCreator.renameStory(story, newName: $0)
                    })
                    return data
                }

                self._cellDatas.accept(.init(old: self._cellDatas.value.new, new: cellDatas))
                return ()

            }.subscribe().disposed(by: disposeBag)
    }
}

extension EditStoriesViewModel: EditStoriesViewModelInput {
    func add() {
        guard !self.cellDatas.contains(where: { $0.uniqueID.isEmpty }) else { return }
        let new = TextFieldCellData(uniqueID: "", subject: "", textFieldValue: "", placeHolderValue: "newStory".localized, tapAction: { }, userAction: {[weak self] in
            guard let self = self else { return }
            if !$0.isEmpty {
                self.flux.actionCreator.add(storyName: $0)
            } else {
                self._cellDatas.accept(.init(old: self._cellDatas.value.new, new: self._cellDatas.value.new))
            }
        })
        self._cellDatas.accept(.init(old: self._cellDatas.value.new, new: [new] + self._cellDatas.value.new))
    }

    func back() {
        router?.pop()
    }

    func selected(story: Story) {
        router?.toEditStory(story)
    }

    func delete(_ cellData: TextFieldCellData) {
        guard let target = flux.storiesStore.stories.first(where: { cellData.uniqueID == $0.id.getIDString() }) else { return }
        flux.actionCreator.deleteStory(target)
    }
}

extension EditStoriesViewModel: EditStoriesViewModelOutput {
    var cellDatas: [TextFieldCellData] {
        return _cellDatas.value.new
    }

    var cellDatasObservable: Observable<Diff<TextFieldCellData>> {
        return _cellDatas.asObservable()
    }

    var showAlertSignal: Signal<(title: String, message: String)> {
        return _showAlert.asSignal()
    }
}

protocol EditStoriesViewModelProtocol {
    var inputs: EditStoriesViewModelInput { get }
    var outputs: EditStoriesViewModelOutput { get }
}

extension EditStoriesViewModel: EditStoriesViewModelProtocol {
    var inputs: EditStoriesViewModelInput { return self }
    var outputs: EditStoriesViewModelOutput { return self }
}
