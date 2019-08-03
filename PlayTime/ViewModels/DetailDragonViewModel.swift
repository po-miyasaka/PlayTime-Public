//
//  DetailDragonViewModel.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/07/07.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PlayTimeObject

protocol DetailDragonViewModelInput {
}

protocol DetailDragonViewModelOutput {
    var dragon: Dragon { get }
}

class DetailDragonViewModel {

    let _dragon: Dragon
    let flux: FluxProtocol
    let disposeBag = DisposeBag()

    init(flux: FluxProtocol = Flux.default,
         dragon: Dragon) {
        self._dragon = dragon
        self.flux = flux
    }
}

extension DetailDragonViewModel: DetailDragonViewModelInput {

}

extension DetailDragonViewModel: DetailDragonViewModelOutput {
    var dragon: Dragon { return _dragon }
}

protocol DetailDragonViewModelProtocol {
    var inputs: DetailDragonViewModelInput { get }
    var outputs: DetailDragonViewModelOutput { get }
}

extension DetailDragonViewModel: DetailDragonViewModelProtocol {
    var inputs: DetailDragonViewModelInput { return self }
    var outputs: DetailDragonViewModelOutput { return self }
}
