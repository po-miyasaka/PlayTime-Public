//
//  EditStoryRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/12.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

protocol EditStoryRouterProtocol: Router {
    func pop()
}

class EditStoryRouter: EditStoryRouterProtocol {

    weak var transitioner: Transitioner?
    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func pop() {
        self.transitioner?.pop(true, delegate: nil)
    }
}
