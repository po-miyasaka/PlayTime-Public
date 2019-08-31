//
//  DragonLibraryViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/05.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift
import PlayTimeObject

protocol DragonLibraryViewModelInput {
    func setUp()
    func selected(dragon: Dragon)
}

protocol DragonLibraryViewModelOutput {
    var views: [DragonLibrarySection] { get }
    var viewsDriver: Driver<[DragonLibrarySection]> { get }
}

class DragonLibraryViewModel {

    private var _views = BehaviorRelay<[DragonLibrarySection]>(value: [])
    let flux: FluxProtocol
    let disposeBag = DisposeBag()
    let router: DragonRouterProtocol
    init(flux: FluxProtocol = Flux.default, router: DragonRouterProtocol) {
        self.router = router
        self.flux = flux
    }

    func setUp() {
        flux.storiesStore
            .dragonsObservable.map {[weak self] dragons in

                let allDragon: [[Dragon]] =
                    Dragon.Name.allCases.map { name in
                        Dragon.Process.allCases.compactMap { process -> Dragon? in
                            Dragon(name: name, process: process, playTimeHour: 0)
                        }
                    }

                let dragonItems: [DragonLibraryItemType] = allDragon.flatMap { tmp -> [DragonLibraryItemType] in
                    let items: [DragonLibraryItemType] = tmp.map { tmpDragon in

                        if let save = dragons.first(where: { dragon in tmpDragon.name == dragon.name }),
                            save.playTimeHour >= tmpDragon.process.necessaryExperienceForShowingLibrary {
                            return DragonLibraryItemType.item(tmpDragon, ImageCellData(image: tmpDragon.images.illust))
                        }

                        return DragonLibraryItemType.hatena(tmpDragon, ImageCellData(image: UIImage(named: "hatena")))
                    }

                    return items
                }

                self?._views.accept([DragonLibrarySection.items(dragonItems)])

            }.subscribe().disposed(by: disposeBag)
    }
}

extension DragonLibraryViewModel: DragonLibraryViewModelInput {
    func selected(dragon: Dragon) {
        router.showDetail(dragon: dragon)
    }
}

extension DragonLibraryViewModel: DragonLibraryViewModelOutput {

    var views: [DragonLibrarySection] {
        return _views.value
    }

    var viewsDriver: Driver<[DragonLibrarySection]> {
        return _views.asDriver()
    }

}

enum DragonLibrarySection {
    case items([DragonLibraryItemType])

    var items: [DragonLibraryItemType] {
        if case .items(let tmps) = self {
            return tmps
        }
        return []
    }
}

enum DragonLibraryItemType {
    case item(Dragon, ImageCellData)
    case hatena(Dragon, ImageCellData)

    var dragon: Dragon? {
        switch self {
        case .item(let tuple):
            return tuple.0

        case .hatena(let tuple):
            return tuple.0
        default:
            return nil
        }
    }
}

protocol DragonLibraryViewModelProtocol {
    var inputs: DragonLibraryViewModelInput { get }
    var outputs: DragonLibraryViewModelOutput { get }
}

extension DragonLibraryViewModel: DragonLibraryViewModelProtocol {
    var inputs: DragonLibraryViewModelInput { return self }
    var outputs: DragonLibraryViewModelOutput { return self }
}
