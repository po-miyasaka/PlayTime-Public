//
//  EditStoriesRouter.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/05/12.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

protocol EditStoriesRouterProtocol: Router {
    func pop()
    func toEditStory(_ story: Story?)
}

class EditStoriesRouter: EditStoriesRouterProtocol {

    weak var transitioner: Transitioner?
    required init(transitioner: Transitioner?) {
        self.transitioner = transitioner
    }

    func pop() {
        self.transitioner?.pop(true, delegate: nil)
    }

    func toEditStory(_ story: Story?) {
        let viewController: EditStoryViewController?
        let viewModel = EditStoryViewModel(selected: story)
        viewController = EditStoryViewController(viewModel: viewModel)
        viewModel.router = EditStoryRouter(transitioner: viewController)
        self.transitioner?.push(viewController, true, delegate: nil)
    }
}
