//
//  StartingQuestRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/15.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit

protocol StartingQuestRouterProtocol: Router {
    func close()
    func toPlayingQuest()
}

class StartingQuestRouter: NSObject, StartingQuestRouterProtocol {

    weak var transitioner: Transitioner?
    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func close() {
        transitioner?.pop(true, delegate: (transitioner as? UIViewController)?.navigationController?.delegate)
    }

    func toPlayingQuest() {
        let viewModel = PlayingQuestViewModel(fromType: .detail)
        let viewController = PlayingQuestViewController(viewModel: viewModel)
        viewModel.router = PlayingQuestRouter(transitiner: viewController)
        transitioner?.push(viewController, true, delegate: nil)
    }

}
