//
//  Flux.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/17.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

protocol FluxProtocol {
    var actionCreator: ActionCreatorProtocol { get }
    var storiesStore: StoryStoreProtocol { get }
    var settingsStore: SettingsStoreProtocol { get }
}

class Flux: FluxProtocol {
    static let `default` = Flux()

    let dispatcher: DispatcherProtocol
    let actionCreator: ActionCreatorProtocol
    let storiesStore: StoryStoreProtocol
    let settingsStore: SettingsStoreProtocol

    init(dispatcher: DispatcherProtocol = Dispatcher.default,
         actionCreator: ActionCreatorProtocol = ActionCreator.default,
         storiesStore: StoryStoreProtocol = StoryStore.default,
         settingsStore: SettingsStoreProtocol = SettingsStore.default) {

        self.dispatcher = dispatcher
        self.actionCreator = actionCreator
        self.storiesStore = storiesStore
        self.settingsStore = settingsStore
    }

}
