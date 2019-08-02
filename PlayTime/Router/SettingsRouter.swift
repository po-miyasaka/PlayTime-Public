//
//  SettingsRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/11.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsRouterProtocol: Router {
    func toEditStories()
    func close()
}

class SettingsRouter: SettingsRouterProtocol {
    weak var transitioner: Transitioner?
    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func toEditStories() {
        let viewModel = EditStoriesViewModel()
        let viewController = EditStoriesViewController(viewModel: viewModel)
        viewModel.router = EditStoriesRouter(transitioner: viewController)
        viewController.title = "storyEdit".localized
        transitioner?.push(viewController, true, delegate: nil)
    }

    func close() {
        transitioner?.dismissFromRoot(true)
    }
}
