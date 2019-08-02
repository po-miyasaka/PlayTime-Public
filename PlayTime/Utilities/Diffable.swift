//
//  Diffable.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/06/09.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

struct Diff<T: Diffable> {
    let old: [T]
    let new: [T]

    func classifyIndice(section: Int = 0) -> (reloaded: [IndexPath], deleted: [IndexPath], inserted: [IndexPath]) {

        let reloaded = old.enumerated().compactMap { beforeElement -> Int? in
            if new.contains(where: { afterElement in afterElement == beforeElement.element && afterElement.expression != beforeElement.element.expression }) {
                return beforeElement.offset
            } else {
                return nil
            }
        }.map { IndexPath(row: $0, section: section) }

        let deleted = old.enumerated().compactMap {beforeElement -> Int? in
            if !new.contains(where: { afterElement in afterElement == beforeElement.element }) {
                return beforeElement.offset
            } else {
                return nil
            }
        }.map { IndexPath(row: $0, section: section) }

        let inserted = new.enumerated().compactMap { afterElement -> Int? in
            if !old.contains(where: { beforeElement in beforeElement == afterElement.element }) {
                return afterElement.offset
            } else {
                return nil
            }
        }.map { IndexPath(row: $0, section: section) }

        return (reloaded: reloaded, deleted: deleted, inserted: inserted)
    }

}

protocol Diffable: Equatable {
    associatedtype Expression: Equatable
    var expression: Expression { get }
}
