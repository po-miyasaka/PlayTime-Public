//
//  AddQuestRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/02.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

protocol AddQuestRouterProtocol: Router {
    func dismiss()
}

class AddQuestRouter: AddQuestRouterProtocol {

    weak var transitioner: Transitioner?
    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func dismiss() {
        self.transitioner?.dismiss()
    }
}
