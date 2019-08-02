//
//  Dispatcher.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/02/15.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias ActionHandler = (Action) -> Void
protocol  DispatcherProtocol {
    func register(actionHandler: @escaping ActionHandler) -> Disposable
    func dispatch(action: Action)
}

class Dispatcher: DispatcherProtocol {
    static let `default` = Dispatcher()
    private init() {}
    let _actionHandler = PublishRelay<Action>()

    func register(actionHandler: @escaping ActionHandler) -> Disposable {
        return _actionHandler.subscribe(onNext: actionHandler)
    }

    func dispatch(action: Action) {
        if Thread.isMainThread {
            self._actionHandler.accept(action)
        } else {
            DispatchQueue.main.async {
                self._actionHandler.accept(action)
            }
        }
    }

}
