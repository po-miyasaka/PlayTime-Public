//
//  Diffable.swift
//  playTime
//
//  Created by kazutoshi miyasaka on 2019/06/09.
//  Copyright © 2019 po-miyasaka. All rights reserved.
//

import Foundation

public struct MovedIndexPath {
    public let before: IndexPath
    public let after: IndexPath
    
    init(_ before: IndexPath, _ after: IndexPath) {
        self.before = before
        self.after = after
    }
}

public typealias ClassifiedIndexPaths = (reloaded: [IndexPath],
    moved: [MovedIndexPath],
    deleted: [IndexPath],
    inserted: [IndexPath])

public struct Diff<T: Diffable> {
    public let old: [T]
    public let new: [T]
    
    public init(old: [T], new: [T]) {
        self.old = old
        self.new = new
    }
    
    func classifyIndice(section: Int = 0) -> ClassifiedIndexPaths {
        
        var reloaded = [IndexPath]()
        var moved = [MovedIndexPath]()
        
        new.enumerated().forEach { afterElement in
            old.enumerated().forEach { beforeElement in
                if afterElement.element == beforeElement.element {
                    
                    if beforeElement.offset != afterElement.offset {
                        moved.append(MovedIndexPath(IndexPath(row: beforeElement.offset, section: section),
                                      IndexPath(row: afterElement.offset, section: section)))
                    } else if afterElement.element.expression != beforeElement.element.expression {
                        // 変更がある。
                        reloaded.append(IndexPath(row: afterElement.offset, section: section))
                        reloaded.append(IndexPath(row: beforeElement.offset, section: section))
                    }
                }
            }
        }
        
        let deleted = old.enumerated()
            .compactMap {beforeElement -> Int? in
                if !new.contains(where: { afterElement in afterElement == beforeElement.element }) {
                    return beforeElement.offset
                } else {
                    return nil
                }
            }
            .map { IndexPath(row: $0, section: section) }
        
        let inserted = new.enumerated()
            .compactMap { afterElement -> Int? in
                if !old.contains(where: { beforeElement in beforeElement == afterElement.element }) {
                    return afterElement.offset
                } else {
                    return nil
                }
            }
            .map { IndexPath(row: $0, section: section) }
        
        return (reloaded: reloaded.toSet.toArray, moved: moved, deleted: deleted, inserted: inserted)
    }
    
}

public protocol Diffable: Equatable {
    associatedtype Expression: Equatable
    var expression: Expression { get }
}
