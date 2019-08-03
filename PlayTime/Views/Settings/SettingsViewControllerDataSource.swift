//
//  SettingViewControllerDataSource.swift
//  pennet
//
//  Created by miyasakakazutoshi on 2018/01/21Sunday.
//  Copyright © 2018 pennet. All rights reserved.
//

import Foundation
import UIKit
class SettingViewControllerDataSource: NSObject, UITableViewDataSource {

    var viewModel: SettingsViewModelProtocol
    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.settings.getSectionType(section: section)?.getCells().count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.outputs.settings.getSectionType(section: section)?.sectionName
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.outputs.settings.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel
            .outputs
            .settings
            .cellType(from: indexPath)?
            .dequeue(tableView: tableView, indexPath: indexPath) ?? UITableViewCell()
    }
}
